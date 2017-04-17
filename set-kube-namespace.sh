#!/bin/bash
# Set context to '$1'
# Based on instructions at https://kubernetes.io/docs/user-guide/namespaces/
CONTEXT=$(kubectl config view | awk '/current-context/ {print $2}')
kubectl config set-context $CONTEXT --namespace=$1

# validate - returns 0 if namespace set
kubectl config view | grep "namespace: $1"
