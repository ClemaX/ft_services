#!/usr/bin/env bash

DRIVER=kvm2         # Driver to use with minikube
PREFIX=ft_services  # Docker build prefix
SRCDIR=srcs         # Directory which contains the deployments

KEYDIR=keys         # Directory where keys and certs will be generated
KEYHOST=ft.services # Load balancer hostname

# Start minikube
minikube start --driver=${DRIVER}

# Enable addons
minikube addons enable metrics-server
minikube addons enable dashboard
minikube addons enable ingress

# Use minikube docker-env
eval $(minikube docker-env)

# Build docker images
docker build -t ${PREFIX}/mysql ${SRCDIR}/mysql
docker build -t ${PREFIX}/wordpress ${SRCDIR}/wordpress
docker build -t ${PREFIX}/phpmyadmin ${SRCDIR}/phpmyadmin
docker build -t ${PREFIX}/nginx ${SRCDIR}/nginx
docker build -t ${PREFIX}/ftps ${SRCDIR}/ftps

# Generate TLS keys
mkdir -p ${KEYDIR}

openssl req -x509 -nodes -days 365\
    -newkey rsa:2048\
    -keyout ${KEYDIR}/${KEYHOST}.key\
    -out ${KEYDIR}/${KEYHOST}.csr\
    -subj "/CN=${KEYHOST}/O=${KEYHOST}"

kubectl delete secret ${KEYHOST}-tls
kubectl create secret tls ${KEYHOST}-tls --key ${KEYDIR}/${KEYHOST}.key --cert ${KEYDIR}/${KEYHOST}.csr

# Apply kustomization
kubectl apply -k ${SRCDIR}

# Show web dashboard url
minikube dashboard --url
