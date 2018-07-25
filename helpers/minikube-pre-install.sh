# Workaround for issue https://github.com/kubernetes/minikube/issues/2256 found in minikube v0.24

echo "==========================================="
echo "   Minikube Pre-Install Configuration"
echo "==========================================="

pvPath='/tmp/gestalt-postgresql-volume'

# First, create a directory for the PV on the minikube node. If already exists remove and re-create.

echo "Checking for leftover directory $pvPath from previous installs."
cleanupMe=$(minikube ssh "if [ -d $pvPath ]; then echo "yes"; else echo "no"; fi")
exit_on_error "Unable determine presence of directory: $pvPath on minikube node for Kubernetes PV"
echo 'Done.'
echo

if [ "$cleanupMe" = "yes" ]; then
  echo "Removing $pvPath"
  minikube ssh "sudo rm -rf $pvPath"
  exit_on_error "Could not remove leftover directory on minikube node for Kubernetes PV. Please attempt manually remove: sudo rm -rf $pvPath"
  echo 'Done.'
  echo
else
  echo "Nothing to do: $pvPath not present"
  echo
fi

echo "Creating $pvPath on minikube node"
minikube ssh "sudo mkdir $pvPath && sudo chmod 777 $pvPath && sudo chown docker:docker $pvPath"
exit_on_error "Could not create and permission directory on minikube node for Kubernetes PV"
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
