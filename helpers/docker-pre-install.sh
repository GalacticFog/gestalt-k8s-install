# Manually provision a PV

echo "==========================================="
echo "   Docker Local Pre-Install Configuration"
echo "==========================================="

#
# # First, create a directory for the PV on the host
# echo "Creating /tmp/gestalt-postgresql-volume on minikube node"
# mkdir /tmp/gestalt-postgresql-volume
# chmod 777 /tmp/gestalt-postgresql-volume
#
# exit_on_error "Could not create directory on minikube node for Kubernetes PV"
# echo 'Done.'
# echo

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
