#!/usr/bin/env bash

set -e              # Abort on error

DRIVER=${DRIVER:-docker}	# Driver to use with minikube
NAME=ft.services	# Minikube profile
PREFIX=ft_services  # Docker build prefix
SRCDIR=srcs         # Directory which contains the deployments

KEYDIR=keys         # Directory where keys and certs will be stored
KEYHOST=ft.services # Load balancer hostname

# Container units
UNITS=("mysql" "wordpress" "phpmyadmin" "nginx" "ftps" "influxdb" "grafana" "telegraf")
ADDONS=("metrics-server" "dashboard")

element_in () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

start_minikube()
{
	# Start minikube
	minikube -p "${NAME}" start --driver="${DRIVER}" --extra-config=kubeadm.pod-network-cidr=10.244.0.0/16
}

stop_minikube()
{
	# Stop minikube
	minikube -p "${NAME}" stop
}

delete_minikube()
{
	read -p "Are you sure you want to delete the cluster? [y/N] " -n1 -r ANSWER
	echo

	if [[ ${ANSWER} =~ ^[Yy]$ ]]; then
		# Delete the minikube cluster
		minikube -p "${NAME}" delete
		rm -rf "${KEYDIR}"
	fi
}

setup_minikube()
{
	# Start minikube
	start_minikube

	# Enable addons
	for ADDON in ${ADDONS[@]}; do
		minikube -p "${NAME}" addons enable "${ADDON}"
	done

	# Setup MetalLB
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml

	# Setup namespaces
	kubectl apply -f ${SRCDIR}/namespaces.yaml
}

setup_networking()
{
	# Split IP by '.'
	OLDIFS=${IFS}
	# $(minikube -p "${NAME}" ip)
	IFS=.; set --  $(kubectl get node -o=custom-columns='DATA:status.addresses[0].address' | sed -n 2p)
	# Assign free range to MetalLB
	if [ "${4}" -gt 127 ]; then
		LB_RANGE="${1}.${2}.${3}.1/32"
	else
		LB_RANGE="${1}.${2}.${3}.128/32"
	fi
	# Restore IFS
	IFS=${OLDIFS}

	CONFIGMAP=$(cat <<- EOF
		address-pools:
		- name: default
		  protocol: layer2
		  addresses:
		  - ${LB_RANGE}
	EOF
	)

	# Update MetalLB configmap
	kubectl --namespace metallb-system delete configmap config || :
	kubectl --namespace metallb-system create configmap config --from-literal="config=${CONFIGMAP}"
}

start_dashboard()
{
	# Show web dashboard url
	minikube -p "${NAME}" dashboard --url
}

build_unit()
{
	echo "Building ${1}..."
	docker build -qt "${PREFIX}/${1}" "${SRCDIR}/${1}" 
}

build_units()
{
	# Use minikube docker-env
	eval $(minikube -p "${NAME}" docker-env)

	# Build docker images
	for UNIT in ${UNITS[@]}; do
		build_unit "${UNIT}"
	done
}

build_certs()
{
	ANSWER="Y"
	if [ -f "${KEYDIR}/${KEYHOST}.csr" ] || [ -f "${KEYDIR}/${KEYHOST}.key" ]; then
		read -p "Do you want to overwrite the existing certificates? [y/N] " -n1 -r ANSWER
		echo
	fi

	if [[ ${ANSWER} =~ ^[Yy]$ ]]; then
		# Generate TLS keys
		mkdir -p "${KEYDIR}"

		openssl req -x509 -nodes -days 365\
			-newkey rsa:2048\
			-keyout "${KEYDIR}/${KEYHOST}.key"\
			-out "${KEYDIR}/${KEYHOST}.csr"\
			-subj "/CN=*.${KEYHOST}/O=${KEYHOST}"
	fi

	# Update TLS secret
	kubectl delete secret default-tls || :
	kubectl create secret tls default-tls --key "${KEYDIR}/${KEYHOST}.key" --cert "${KEYDIR}/${KEYHOST}.csr"
	kubectl delete secret -n monitoring default-tls || :
	kubectl create secret -n monitoring tls default-tls --key "${KEYDIR}/${KEYHOST}.key" --cert "${KEYDIR}/${KEYHOST}.csr"

	# Update MetalLB secret
	kubectl delete secret -n metallb-system memberlist || :
	kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

	# Update Grafana secret
	kubectl delete secret -n monitoring grafana-secretkey || :
	kubectl create secret generic -n monitoring grafana-secretkey --from-literal=secretkey="$(openssl rand -base64 20)"
}

update_unit()
{
	if [[ "${1}" = "" ]]; then
		echo -e "Usage: ${0} update [UNIT]

Units:"
		printf '	%s\n' ${UNITS[@]}
		exit 1
	fi
	if element_in "${1}" "${UNITS[@]}"; then
		eval $(minikube -p "${NAME}" docker-env)
		build_unit "${1}"
		kubectl delete -f "${SRCDIR}/${1}/deployment.yaml" || :
		kubectl apply -k "${SRCDIR}"
	else
		echo "${1} is not a valid unit!"
		exit 1
	fi
}

setup()
{
	setup_minikube
	setup_networking
	build_units
	build_certs
	kubectl apply -k "${SRCDIR}"
	echo "To open the Kubernetes dashboard, please run 'minikube -p \"${NAME}\" dashboard' in your terminal."
}

print_help()
{
	echo -e "Usage: ${0} [COMMAND]

Commands:
	setup		Setup and start the cluster
	start		Start an existing cluster and apply changes
	stop		Stop the running cluster
	restart		Restart the running cluster
	update		Update an unit's image
	delete		Delete the cluster
	dashboard	Show the Kubernetes dashboard
	help		Show this help message

If no argument is provided, 'setup' will be assumed."
}

case "${1}" in 
  "setup" | ""	)	setup;;
  "start"		)	start_minikube;;
  "stop"		)	stop_minikube;;
  "restart"		)	stop_minikube; start_minikube;;
  "delete"		)	delete_minikube;;
  "dashboard"	)	start_dashboard;;
  "update"		)	update_unit "${2}";;
  * 			)	print_help;;
esac
