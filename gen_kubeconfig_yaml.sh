#!/bin/bash

if [ -z "$1" ]; then
  echo "Run with a kubeconfig file as argument"
  exit 1
fi

os=`uname`

if [ "$os" == "Darwin" ]; then
  data=`base64 $1`
elif [ "$os" == "Linux" ]; then
  data=`base64 -w0 $1`
else
  echo "Could not handle OS type '$os', aborting."
  exit 1
fi

outfile=kube_provider_config.yaml
namespace=gestalt-system

cat > $outfile << EOF
# data encoded from $1
kubeconfig: $data
EOF

echo "Encoded kubernetes config file ($1) to $outfile. "
echo ""
echo "Pass with '-f' to helm install command, e.g."
echo ""
echo "    helm install --namespace $namespace ./gestalt -n gestalt-platform -f kube_provider_config.yaml"
echo ""
