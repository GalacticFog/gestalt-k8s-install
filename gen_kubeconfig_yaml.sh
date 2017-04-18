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

echo "Encoded $1 to $outfile. "
echo ""
echo "Pass with '-f' to helm install command, e.g."
echo ""
echo "    helm install --namespace gestalt-system ./gestalt -n gestalt-platform -f kube_provider_config.yaml"
echo ""
