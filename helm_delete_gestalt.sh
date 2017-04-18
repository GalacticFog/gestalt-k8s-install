#!/bin/bash
namespace=gestalt-system

echo Deleting gestalt-platform ...
helm delete --purge gestalt-platform
echo Done.

echo
echo Listing PVCs...
kubectl get pvc --namespace=$namespace

echo
echo Run to delete volume claims:
echo
echo "  kubectl delete pvc --all --namespace=$namespace"
echo
echo "Or, clean the entire '$namespace' namespace"
echo
echo "  kubectl delete namespace $namespace"
echo
