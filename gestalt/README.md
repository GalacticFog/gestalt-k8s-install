# Gestalt Platform Helm Chart

## Prerequisites Details
* Kubernetes 1.5
* PV support on the underlying infrastructure
* Volumes configured or Dynamic Storage Provisioning enabled

## Chart Details
This chart will do the following:

* Deploy the Gestalt Platform to your Kubernetes cluster

## Preparing and Installing the Chart

Prepare kubernetes provider configuration file to be used by gestalt:

```
$ ./gen_kubeconfig_yaml.sh ~/.kube/config

Encoded kubernetes config file (/home/example/.kube/config) to kube_provider_config.yaml.

Pass with '-f' to helm install command, e.g.

    helm install --namespace gestalt-system ./gestalt -n gestalt-platform -f kube_provider_config.yaml
```


## Configuration
Modify the values in ```values.yaml```


## Deploy Gestalt Platform using Helm:

Create a namespace (e.g. 'gestalt-system'):
```
$ kubectl create namespace gestalt-system
```
Install using Helm:
```
$ helm install --namespace gestalt-system ./gestalt -n gestalt-platform -f kube_provider_config.yaml
NAME:   gestalt-platform
LAST DEPLOYED: Tue Apr 18 16:25:13 2017
NAMESPACE: gestalt-system
STATUS: DEPLOYED

RESOURCES:
==> v1/Secret
NAME        TYPE    DATA  AGE
gestalt-db  Opaque  3     3s

==> v1/Service
NAME                   CLUSTER-IP    EXTERNAL-IP  PORT(S)             AGE
gestalt-security       10.0.196.202  <pending>    9455:31704/TCP      3s
gestalt-platform-etcd  None          <none>       2380/TCP,2379/TCP   3s
gestalt-ui             10.0.47.144   <pending>    80:30008/TCP        3s
gestalt-db             10.0.136.194  <none>       5432/TCP            3s
gestalt-meta           10.0.16.222   <pending>    10131:32631/TCP     3s
gestalt-rabbit         10.0.51.143   <none>       5672/TCP,15672/TCP  3s

==> apps/v1beta1/StatefulSet
NAME                   DESIRED  CURRENT  AGE
gestalt-platform-etcd  3        1        3s
gestalt-db             2        1        2s

==> v1/Pod
NAME              READY  STATUS             RESTARTS  AGE
gestalt-deployer  0/1    ContainerCreating  0         3s

==> extensions/v1beta1/Deployment
NAME              DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
gestalt-rabbit    1        1        1           1          3s
gestalt-meta      1        1        1           1          3s
gestalt-security  1        1        1           1          3s
gestalt-ui        1        1        1           1          2s

==> v1/Endpoints
NAME        ENDPOINTS  AGE
gestalt-db  <none>     2s


NOTES:

    Gestalt platform deployment initiated to namespace 'gestalt-system'.

    Deployment takes several minutes to complete.  To view status of deployment,
    view the gestalt-deployer container logs:

      kubectl --namespace=gestalt-system logs gestalt-deployer


    UI Access - Once Gestalt platform is deployed, the User Interface is accessible from the
    'gestalt-ui' service. For details, use the LoadBalancer Ingress.  Run the following:

      kubectl describe services gestalt-ui --namespace=gestalt-system

    Default credentials for the UI are specified in values.yaml:

      Security:
        AdminUser:      "gestalt-admin"
        AdminPassword:  "<password>"

    You may access the Gestalt platform documentation at

        http://docs.galacticfog.com/

```

## Deleting the Gestalt Platform Deployment

Delete Gestalt platform deployment and namespace:
```
$ helm list
$ helm list
NAME            	REVISION	UPDATED                 	STATUS  	CHART        	NAMESPACE       
gestalt-platform	1       	Tue Apr 18 16:25:13 2017	DEPLOYED	gestalt-1.0.0	gestalt-system

$ helm delete --purge gestalt-platform

$ helm delete namespace gestalt-system
```

Delete provider resources created outside of Helm:
```
$ kubectl get services --all-namespaces
NAMESPACE                              NAME                       CLUSTER-IP     EXTERNAL-IP        PORT(S)                         AGE
548f2d87-3f5f-4962-941b-b204a60d6abd   default-kong               10.0.112.188   <nodes>            8001:32355/TCP,8000:31235/TCP   32m
8ded91ae-322c-4de6-90e5-d6a89e096310   lambda-provider            10.0.68.159    <nodes>            9000:31368/TCP                  32m
aaf236e6-2711-4c7a-a8a7-5051fada5a8c   default-gateway-provider   10.0.62.15     <nodes>            9000:32642/TCP                  32m
ee56e43e-a1bd-4643-84ac-511cab54bee5   gestalt-policy-provider    10.0.31.228    <nodes>            9000:31047/TCP                  32m

$ kubectl delete namespace \
548f2d87-3f5f-4962-941b-b204a60d6abd \
8ded91ae-322c-4de6-90e5-d6a89e096310 \
aaf236e6-2711-4c7a-a8a7-5051fada5a8c \
ee56e43e-a1bd-4643-84ac-511cab54bee5
```
