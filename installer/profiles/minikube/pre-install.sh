# Workaround for issue https://github.com/kubernetes/minikube/issues/2256 found in minikube v0.24
# Check and minikube configuration change if needed https://github.com/kubernetes/minikube/issues/2367 for Elasticsearch

echo "==========================================="
echo "   Minikube Pre-Install Configuration"
echo "==========================================="

echo "Getting current vm.max_map_count minikube node"
miniStatus=$(minikube ssh 'sysctl vm.max_map_count')
echo "$miniStatus" | grep 'vm.max_map_count' > /dev/null
if [ $? -ne 0 ]; then
  echo
  echo "Unable determine current minikube vm.max_map_count value"
  echo "$miniStatus"
  exit_with_error "Installation failed, aborting."
fi

if [ `echo $miniStatus | sed 's/[^0-9]*//g'` -lt 262144 ]; then

  echo "Elasticsearch requires that the vm.max_map_count be set to at least 262144."
  echo "Your minikube: $miniStatus"
  echo
  do_prompt_to_continue "Please confirm to proceed of setup vm.max_map_count=262144 and minikube restart. Installation will abort if you choose not to."
  #User confirmed ok to proceed
  #Set vm.max_map_count=262144
  echo "Setting persistant vm.max_map_count=262144"
  miniStatus=$(minikube ssh 'echo "sysctl -w vm.max_map_count=262144" | sudo tee -a /var/lib/boot2docker/bootlocal.sh && echo "Setting persistant vm.max_map_count=262144"')
  echo "$miniStatus" | grep 'Setting persistant vm.max_map_count=262144' > /dev/null
  if [ $? -ne 0 ]; then
    echo
    echo "Unable update minikube vm.max_map_count value"
    echo "minikube ssh 'echo \"sysctl -w vm.max_map_count=262144\" | sudo tee -a /var/lib/boot2docker/bootlocal.sh'"
    echo "$miniStatus"
    exit_with_error "Installation failed, aborting."
  fi

  #Restart minkube: stop + start
  echo "Restart minikube: stop"
  minikube stop
  if [ $? -ne 0 ]; then
    echo
    echo "Unable stop minikube"
    exit_with_error "Installation failed, aborting."
  fi

  echo "Restart minikube: start"
  minikube start
  if [ $? -ne 0 ]; then
    echo
    echo "Unable stop minikube"
    exit_with_error "Installation failed, aborting."
  fi

  #Post-restart vm.max_map_count check
  echo "Getting current vm.max_map_count minikube node"
  miniStatus=$(minikube ssh 'sysctl vm.max_map_count')
  echo "$miniStatus" | grep 'vm.max_map_count = 262144' > /dev/null
  if [ $? -ne 0 ]; then
    echo
    echo "Setting vm.max_map_count value failed"
    echo "$miniStatus"
    exit_with_error "Installation failed, aborting."
  fi
else
  echo "OK - vm.max_map_count =  `echo $miniStatus | sed 's/[^0-9]*//g'` meets Elasticsearch requirements"
fi


pvPath='/tmp/gestalt-postgresql-volume'

# First, create a directory for the PV on the minikube node. If already exists remove and re-create.
echo "Setup $pvPath on minikube node"

echo "Creating / Re-creating and permissioning $pvPath on minikube node"

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
  # storageClassName: gestalt-postgresql-volume
  storageClassName: hostpath
EOF
exit_on_error "Could not create Kubernetes PV"
echo 'Done.'
echo
