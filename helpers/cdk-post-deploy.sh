# This file is sourced into the installer

exit_with_error() {
  echo "[Error] $@"
  exit 1
}

exit_on_error() {
  if [ $? -ne 0 ]; then
    exit_with_error $1
  fi
}

echo "==========================================="
echo "   CDK Post-Install Configuration"
echo "==========================================="
echo
echo "Copying Ceph secret from 'default' namespace to '$install_namespace', otherwise"
echo "Ceph volumes will not be able to be mounted."

mkdir -p ./tmp
exit_on_error "Could not create ./tmp"

kubectl get secret ceph-secret --namespace default -oyaml > ./tmp/ceph-secret.yaml
exit_on_error "Could not get ceph secret"

cat ./tmp/ceph-secret.yaml | sed 's/namespace: default/namespace: $install_namespace/g' > ./tmp/ceph-secret-copy.yaml
exit_on_error "Could not process ceph secret"

kubectl create -f ./tmp/ceph-secret-copy.yaml --namespace $install_namespace
exit_on_error "Could not create ceph secret in '$install_namespace' namespace"

rm ./tmp/ceph-secret*

echo "Done."
