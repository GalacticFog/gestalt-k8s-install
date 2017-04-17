echo Deleting gestalt-platform ...
helm delete --purge gestalt-platform
echo Done.

echo
echo Listing PVCs...
kubectl get pvc

echo
echo Run to delete volume claims:
echo
echo "  kubectl delete pvc --all"
echo
echo "Or, clean the entire namespace"
echo
echo "  kubectl delete namespace gestalt-system"
echo
