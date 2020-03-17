#!/usr/bin/env bash

DRIVER=virtualbox
PREFIX=ft_services
SRCDIR=srcs

# Start minikube
minikube start --driver=$DRIVER

# Enable ingress
minikube addons enable ingress

# Use minikube docker-env
eval $(minikube docker-env)

# Build docker images
docker build -t $PREFIX/mysql $SRCDIR/mysql
docker build -t $PREFIX/wordpress $SRCDIR/wordpress

# Apply kustomization
kubectl apply -k $SRCDIR