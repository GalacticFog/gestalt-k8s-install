pod=`kubectl get pod -n gestalt-system | grep gestalt-security- | awk '{print $1}'`

kubectl cp gestalt-system/$pod:/etc/ssl/certs/java/cacerts .
