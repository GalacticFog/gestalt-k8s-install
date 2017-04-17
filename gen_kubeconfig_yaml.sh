#!/bin/bash

if [ -z "$1" ]; then
  echo "Run with a kubeconfig file as argument"
  exit 1
fi

data=`base64 $1`
outfile=kube_provider_config.yaml

cat > $outfile << EOF
# data encoded from $1
kubeconfig: $data
EOF

echo "Encoded $1 to $outfile. Pass with '-f' to helm install command, e.g."
echo ""
echo "    helm install ./gestalt -n gestalt-platform -f kube_provider_config.yaml"
echo ""

# cat > create_kube_provider_payload.json << EOF
# {
#   "name": "KubernetesProvider-1",
#   "description": "A Kubernetes Cluster.",
#   "resource_type": "Gestalt::Configuration::Provider::CaaS::Kubernetes",
#   "properties": {
#     "config": {
#       "env": {
#         "public": {},
#         "private": {}
#       }
#     },
#     "services": [],
#     "locations": [],
#     "data": "$data"
#   }
# }
