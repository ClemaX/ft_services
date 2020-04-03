#!/usr/bin/env bash

DRIVER=kvm2
PREFIX=ft_services
SRCDIR=srcs

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
docker build -t ${PREFIX}/ftps ${SRCDIR}/ftps

# Apply kustomization
kubectl apply -k ${SRCDIR}

# Show web dashboard url
minikube dashboard --url
