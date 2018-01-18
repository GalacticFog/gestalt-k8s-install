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

minikube_ip=`minikube ip`
exit_on_error "Unable to get minikube IP address"

echo "==========================================="
echo "   Minikube Post-Install Configuration"
echo "==========================================="
echo
echo "Your minikube cluster IP is $minikube_ip"
echo
echo "Adding /etc/host entries for Gestalt (requires sudo, you may be asked for your password)..."
sudo true
if [ $? -eq 0 ]; then
  sudo ./helpers/remove-etc-hosts-entry.sh $GESTALT_UI_INGRESS_HOST >/dev/null
  sudo ./helpers/remove-etc-hosts-entry.sh $EXTERNAL_GATEWAY_HOST >/dev/null
  sudo ./helpers/add-etc-hosts-entry.sh $minikube_ip $GESTALT_UI_INGRESS_HOST >/dev/null
  sudo ./helpers/add-etc-hosts-entry.sh $minikube_ip $EXTERNAL_GATEWAY_HOST >/dev/null
  echo "Added Gestalt entries to /etc/hosts."
  GESTALT_LOGIN_URL="$GESTALT_UI_INGRESS_PROTOCOL://$GESTALT_UI_INGRESS_HOST"
else
  echo "Warning: failed to add entries to /etc/hosts.  These should be added manually:"
  echo "  $minikube_ip $GESTALT_UI_INGRESS_HOST"
  echo "  $minikube_ip $EXTERNAL_GATEWAY_HOST"
  GESTALT_LOGIN_URL="$GESTALT_UI_INGRESS_PROTOCOL://$minikube_ip"
fi
