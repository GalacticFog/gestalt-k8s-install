# Manually provision a PV

echo "==========================================="
echo "   Docker EE Pre-Install Configuration"
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

pvname="hostpath-volume-`random [:lower:] 8`"

# Next, create a PV using that volume
echo "Creating PV for /mnt/$pvname"
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: $pvname
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 100Mi
  hostPath:
    path: /mnt/$pvname
    type: ""
  persistentVolumeReclaimPolicy: Delete
  storageClassName: hostpath
EOF
exit_on_error "Could not create Kubernetes PV '$pvname'"
echo 'Done.'
echo
