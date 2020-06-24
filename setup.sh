#!/usr/bin/env bash

set -e              # Abort on error

DRIVER=${DRIVER:-virtualbox} # Driver to use with minikube
PREFIX=ft_services  # Docker build prefix
SRCDIR=srcs         # Directory which contains the deployments

KEYDIR=keys         # Directory where keys and certs will be generated
KEYHOST=ft.services # Load balancer hostname

# Container units
UNITS=("mysql" "wordpress" "phpmyadmin" "nginx" "ftps")

setup_minikube()
{
	# Start minikube
	minikube start --driver=${DRIVER}

	# Enable addons
	minikube addons enable metrics-server
	minikube addons enable dashboard
	minikube addons enable ingress
}

setup_wait()
{
	# Wait for ingress controller
	kubectl wait --namespace kube-system \
		--for=condition=ready pod \
		--selector=app.kubernetes.io/component=controller \
		--timeout=-1s
}

start_dashboard()
{
	# Show web dashboard url
	minikube dashboard --url
}

build_units()
{
	# Use minikube docker-env
	eval $(minikube docker-env)

	# Build docker images
	for UNIT in ${UNITS[@]}; do
		docker build -t ${PREFIX}/${UNIT} ${SRCDIR}/${UNIT}
	done
}

build_certs()
{
	# Generate TLS keys
	mkdir -p ${KEYDIR}

	openssl req -x509 -nodes -days 365\
		-newkey rsa:2048\
		-keyout ${KEYDIR}/${KEYHOST}.key\
		-out ${KEYDIR}/${KEYHOST}.csr\
		-subj "/CN=${KEYHOST}/O=${KEYHOST}"

	kubectl delete secret ${KEYHOST}-tls || :
	kubectl create secret tls ${KEYHOST}-tls --key ${KEYDIR}/${KEYHOST}.key --cert ${KEYDIR}/${KEYHOST}.csr
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
	kubectl apply -k ${SRCDIR}

	start_dashboard
}

stop()
{
	# Stop minikube
	minikube stop
}

delete()
{
	# Delete the minikube cluster
	minikube delete
	rm -rf keys/
}

print_help()
{
	echo -e "Usage: $0 [COMMAND]

Commands:
	setup		Setup and start the cluster
	start		Start an existing cluster and apply changes
	stop		Stop the running cluster
	restart		Restart the running cluster
	delete		Delete the cluster
	dashboard	Show the Kubernetes dashboard
	help		Show this help message

If no argument is provided, 'setup' will be assumed."
}

case "$1" in 
  "start"		)	start;;
  "stop"		)	stop;;
  "restart"		)	stop; start;;
  "delete"		)	delete;;
  "dashboard"	)	start_dashboard;;
  "setup" | ""	)	setup; start;;
  * 			)	print_help;;
esac
