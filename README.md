# ft_services
Deploying containerized services using Kubernetes.

# Requirements
This project uses `minikube` to provide a local K8 environment, as well as `kubectl` to administrate the cluster.

## macOS
### Using `brew`:
```shell
brew install kubectl minikube
```

### Using `ports`:
```shell
sudo port selfupdate
sudo port install kubectl minikube
```

### Manual installation:
#### kubectl
```shell
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl"

chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin/kubectl
```

#### minikube
```shell
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64

chmod +x minikube

sudo mv ./minikube /usr/local/bin/minikube
```

## Arch
```shell
sudo pacman -Sy kubectl minikube
```

## Ubuntu/Debian/HypriotOS
#### kubectl
```shell
sudo apt-get update
sudo apt-get install -y apt-transport-https gnupg2

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubectl
```

#### minikube
```shell
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb

sudo dpkg -i minikube_latest_amd64.deb
```


## CentOS/RHEL/Fedora
#### kubectl
```shell
cat << EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum install -y kubectl
```

#### minikube
```shell
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm

sudo rpm -ivh minikube-latest.x86_64.rpm
```

## Using `snap`
```shell
sudo snap install kubectl minikube --classic
```

# Usage
```
./setup.sh [COMMAND]

Commands:
		setup			Setup and start the cluster
		start			Start an existing cluster and apply changes
		stop			Stop the running cluster
		restart			Restart the running cluster
		delete			Delete the cluster
		dashboard		Show the Kubernetes dashboard
		frontend		Show the web frontend
		help			Show this help message
		trust			Attempt to install certificates
		untrust			Attempt to uninstall certificates

If no argument is provided, 'setup' will be assumed.
```
