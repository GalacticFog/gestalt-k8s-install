#!/bin/bash

exit_with_error() {
  echo "[Error] $@"
  exit 1
}

exit_on_error() {
  if [ $? -ne 0 ]; then
    exit_with_error $1
  fi
}

echo "Copying Ceph secret from 'default' namespace to 'gestalt-system', otherwise"
echo "Ceph volumes will not be able to be mounted."

mkdir -p ./tmp
exit_on_error "Could not create ./tmp"

kubectl get secret ceph-secret --namespace default -oyaml > ./tmp/ceph-secret.yaml
exit_on_error "Could not get ceph secret"

cat ./tmp/ceph-secret.yaml | sed 's/namespace: default/namespace: gestalt-system/g' > ./tmp/ceph-secret-copy.yaml
exit_on_error "Could not process ceph secret"

kubectl create -f ./tmp/ceph-secret-copy.yaml --namespace gestalt-system
exit_on_error "Could not create ceph secret in 'gestalt-system' namespace"

rm ./tmp/ceph-secret*

echo "Done."
