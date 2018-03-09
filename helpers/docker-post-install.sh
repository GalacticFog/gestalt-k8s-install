# This file is sourced into the installer

# Form the Gateway URL
kong_namespace=$(kubectl get svc --all-namespaces -ojsonpath='{.items[?(@.metadata.name=="kng")].metadata.namespace}')
kong_port=$(kubectl get svc -n $kong_namespace kng -ojsonpath='{.spec.ports[?(@.name=="public-url")].nodePort}')
gestalt_api_gateway_url=$external_gateway_protocol://$external_gateway_host:$kong_port
