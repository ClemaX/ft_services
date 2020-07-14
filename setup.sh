#!/usr/bin/env bash

set -e              # Abort on error

DRIVER=${DRIVER:-virtualbox}	# Driver to use with minikube
PREFIX=ft_services  # Docker build prefix
SRCDIR=srcs         # Directory which contains the deployments

KEYDIR=keys         # Directory where keys and certs will be stored
KEYHOST=ft.services # Load balancer hostname

KEYS_DARWIN="$HOME/Library/Keychains/login.keychain"	# macOS Keychain location

# Container units
UNITS=("mysql" "wordpress" "phpmyadmin" "nginx" "ftps")
ADDONS=("metrics-server" "dashboard")

setup_minikube()
{
	# Start minikube
	minikube start --driver=${DRIVER}

	# Enable addons
	for ADDON in ${ADDONS[@]}; do
		minikube addons enable "${ADDON}"
	done

	# Setup flannel
	kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
}

setup_wait()
{
	# Wait for ingress controller
	# kubectl wait --namespace kube-system \
	#	--for=condition=ready pod \
	#	--selector=app.kubernetes.io/component=controller \
	#	--timeout=-1s
	echo "Waiting for addons..."
}

start_dashboard()
{
	# Show web dashboard url
	minikube dashboard --url
}

show_frontend()
{
	# Show web frontend url
	echo "https://${KEYHOST}"
}

build_units()
{
	# Use minikube docker-env
	eval $(minikube docker-env)

	# Build docker images
	for UNIT in ${UNITS[@]}; do
		docker build -t "${PREFIX}/${UNIT}" "${SRCDIR}/${UNIT}"
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

	kubectl delete secret "${KEYHOST}-tls" || :
	kubectl create secret tls "${KEYHOST}-tls" --key "${KEYDIR}/${KEYHOST}.key" --cert "${KEYDIR}/${KEYHOST}.csr"
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

setup()
{
	setup_minikube
	build_units
	build_certs
	setup_wait
}

start()
{
	# Start minikube
	setup_minikube
	setup_wait

	# Apply kustomization
	kubectl apply -k "${SRCDIR}"

	start_dashboard
}

stop()
{
	# Stop minikube
	minikube stop
}

delete()
{
	read -p "Are you sure you want to delete the cluster? [y/N] " -n1 -r ANSWER
	echo

	if [[ ${ANSWER} =~ ^[Yy]$ ]]; then
		# Delete the minikube cluster
		minikube delete
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
  * 			)	print_help;;
esac
