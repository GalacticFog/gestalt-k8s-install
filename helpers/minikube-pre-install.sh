# Workaround for issue https://github.com/kubernetes/minikube/issues/2256 found in minikube v0.24

echo "==========================================="
echo "   Minikube Pre-Install Configuration"
echo "==========================================="

pvPath='/tmp/gestalt-postgresql-volume'

# First, create a directory for the PV on the minikube node. If already exists remove and re-create.
echo "Setup $pvPath on minikube node"

echo "Creating / Re-creating and permissioning $pvPath on minikube node"

miniStatus=""
miniStatus=$(minikube ssh "
if [ -d $pvPath ]; then sudo rm -rf $pvPath; fi &&
sudo mkdir $pvPath &&
sudo chmod 777 $pvPath &&
sudo chown docker:docker $pvPath &&
echo 'Successfully created and permissioned.'
")

echo "$miniStatus" | grep 'Successfully created and permissioned.' > /dev/null
if [ $? -ne 0 ]; then
  echo
  echo "Could not create and permission directory on minikube node for Kubernetes PV"
  echo "$miniStatus"
  exit_with_error "Installation failed, aborting."
fi
echo 'Done.'
echo

# Next, create a PV using that volume
echo "Creating PV for /tmp/gestalt-postgresql-volume"
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gestalt-postgresql-volume
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 100Mi
  hostPath:
    path: /tmp/gestalt-postgresql-volume
    type: ""
  persistentVolumeReclaimPolicy: Delete
  storageClassName: gestalt-postgresql-volume
EOF
exit_on_error "Could not create Kubernetes PV"
echo 'Done.'
echo
