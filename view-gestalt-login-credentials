display_summary() {
  echo ""
  echo "  Gestalt Login credentials:"
  echo ""
  echo "         User:      $gestalt_admin_username"
  echo "         Password:  $gestalt_admin_password"
  echo ""
  echo "  You may access the Gestalt platform documentation at"
  echo ""
  echo "         http://docs.galacticfog.com/"
  echo ""
}

gestalt_admin_username=`kubectl get secrets -n gestalt-system gestalt-secrets -ojsonpath='{.data.admin-username}' | base64 --decode`
gestalt_admin_password=`kubectl get secrets -n gestalt-system gestalt-secrets -ojsonpath='{.data.admin-password}' | base64 --decode`

display_summary
