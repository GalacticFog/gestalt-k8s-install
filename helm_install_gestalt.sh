helm install ./gestalt -n gestalt-platform -f kube_provider_config.yaml

sleep 2

kubectl get pods
