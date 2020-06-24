# ft_services
Deploying containerized services using Kubernetes.

# Usage
```
./setup.sh [COMMAND]

Commands:
        setup           Setup and start the cluster
        start           Start an existing cluster and apply changes
        stop            Stop the running cluster
        restart         Restart the running cluster
        delete          Delete the cluster
        dashboard       Show the Kubernetes dashboard
        help            Show this help message
        trust           Attempt to install certificates
        untrust         Attempt to uninstall certificates

If no argument is provided, 'setup' will be assumed.
```