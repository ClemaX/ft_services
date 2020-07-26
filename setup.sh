#!/usr/bin/env bash

set -e              # Abort on error

DRIVER=${DRIVER:-docker}	# Driver to use with minikube
NAME=minikube		# Minikube Name
PREFIX=ft_services  # Docker build prefix
SRCDIR=srcs         # Directory which contains the deployments

KEYDIR=keys         # Directory where keys and certs will be stored
KEYHOST=ft.services # Load balancer hostname

KEYS_DARWIN="$HOME/Library/Keychains/login.keychain"	# macOS Keychain location

# Container units
UNITS=("mysql" "wordpress" "phpmyadmin" "nginx" "ftp" "influxdb" "grafana" "telegraf")
ADDONS=("metrics-server" "dashboard")

setup_minikube()
{
	# Start minikube
	minikube -p ${NAME} start --driver=${DRIVER}

	# Enable addons
	for ADDON in ${ADDONS[@]}; do
		minikube -p ${NAME} addons enable "${ADDON}"
	done

	# Setup flannel
	kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

	# Setup MetalLB
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
}

setup_init()
{
	OLDIFS=$IFS
	IFS=.; set -- $(minikube ip)
	if [ "$4" -gt 127 ]; then
		LB_RANGE="$1.$2.$3.1-$1.$2.$3.127"
	else
		LB_RANGE="$1.$2.$3.129-$1.$2.$3.254"
	fi
	IFS=OLDIFS
	CONFIGMAP=$(cat <<- EOF
		address-pools:
		- name: default
		  protocol: layer2
		  addresses:
		  - $LB_RANGE
	EOF
	)

	# Update MetalLB configmap
	kubectl --namespace metallb-system delete configmap config || :
	kubectl --namespace metallb-system create configmap config --from-literal=config=$CONFIGMAP

	# Create 'monitoring' namespace
	kubectl create namespace monitoring || :

	# Restore IFS
	IFS=$OLDIFS
}

start_dashboard()
{
	# Show web dashboard url
	minikube -p ${NAME} dashboard --url
}

show_frontend()
{
	# Show web frontend url
	echo "https://${KEYHOST}"
}

build_unit()
{
	echo "Building ${1}..."
	docker build -qt "${PREFIX}/${1}" "${SRCDIR}/${1}" 
}

build_units()
{
	# Use minikube docker-env
	eval $(minikube -p ${NAME} docker-env)

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
			-subj "/CN=${KEYHOST}/O=${KEYHOST}"
	fi

	# Update TLS secret
	kubectl delete secret "${KEYHOST}-tls" || :
	kubectl create secret tls "${KEYHOST}-tls" --key "${KEYDIR}/${KEYHOST}.key" --cert "${KEYDIR}/${KEYHOST}.csr"

	# Update MetalLB secret
	kubectl delete secret -n metallb-system memberlist || :
	kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

	# Update Grafana secret
	kubectl delete secret -n monitoring grafana-secret || :
	kubectl create secret generic -n monitoring grafana-secretkey --from-literal=secretkey="$(openssl rand -base64 20)"
}

trust_certs()
{
	if [[ "$OSTYPE" = "darwin"* ]]; then
		security add-trusted-cert -d -r trustRoot -k "${KEYS_DARWIN}" "${KEYDIR}/${KEYHOST}.csr"
	else
		sudo trust anchor --store "${KEYDIR}/${KEYHOST}.csr"
	fi
}

untrust_certs()
{
	if [[ "$OSTYPE" = "darwin"* ]]; then
		security delete-certificate -c "${KEYHOST}"
	else
		sudo trust anchor --remove "${KEYDIR}/${KEYHOST}.csr"
	fi
}

update_unit()
{
	if printf '%s\n' ${UNITS[@]} | grep -q -P "^${1}\$"; then
		eval $(minikube -p ${NAME} docker-env)
		build_unit "${1}"
		kubectl delete -f "${SRCDIR}/${1}/deployment.yaml"
		kubectl apply -k srcs
	else
		echo "${1} is not a valid unit!"
		exit 1
	fi
}

setup()
{
	setup_minikube
	build_units
	build_certs
	setup_init
}

start()
{
	# Start minikube
	setup_minikube
	setup_init

	# Update units
	build_units

	# Apply kustomization
	kubectl apply -k "${SRCDIR}"

	# Start the Kubernetes dashboard
	start_dashboard
}

stop()
{
	# Stop minikube
	minikube -p ${NAME} stop
}

delete()
{
	read -p "Are you sure you want to delete the cluster? [y/N] " -n1 -r ANSWER
	echo

	if [[ ${ANSWER} =~ ^[Yy]$ ]]; then
		# Delete the minikube cluster
		minikube -p ${NAME} delete
		rm -rf keys/
	fi
}

print_help()
{
	echo -e "Usage: ${0} [COMMAND]

Commands:
	setup		Setup and start the cluster
	start		Start an existing cluster and apply changes
	stop		Stop the running cluster
	restart		Restart the running cluster
	delete		Delete the cluster
	dashboard	Show the Kubernetes dashboard
	frontend	Show the web frontend
	help		Show this help message
	trust		Attempt to install certificates
	untrust		Attempt to uninstall certificates
	update		Update an unit's image

If no argument is provided, 'setup' will be assumed."
}

case "${1}" in 
  "setup" | ""	)	setup; start;;
  "start"		)	start;;
  "stop"		)	stop;;
  "restart"		)	stop; start;;
  "delete"		)	delete;;
  "dashboard"	)	start_dashboard;;
  "frontend"	)	show_frontend;;
  "trust"		)	trust_certs;;
  "untrust"		)	untrust_certs;;
  "update"		)	update_unit "${2}";;
  * 			)	print_help;;
esac
