# Gestalt Platform Helm Chart

## Prerequisites Details
* Kubernetes 1.5
* PV support on the underlying infrastructure
* Volumes configured or Dynamic Storage Provisioning enabled

## Chart Details
This chart will do the following:

* Deploy the Gestalt Platform

## Installing the Chart

1) Prepare kubernetes provider configuration file to be used by gestalt:

```
$ ./gen_kubeconfig_yaml.sh kubeproviderconfig

Encoded kubeproviderconfig to kube_provider_config.yaml. Pass with '-f' to helm install command, e.g.

    helm install ./gestalt -n gestalt-platform -f kube_provider_config.yaml
```

2) Install with the following helm command:

```
$ helm install ./gestalt -n gestalt-platform -f kube_provider_config.yaml
```

## Configuration
Modify the values in ```values.yaml```

## Perform a dry run:

```
helm install --debug --dry-run .
```

## Install Gestalt platform:

```
$ helm install ./gestalt -n gestalt-platform -f kube_provider_config.yaml
NAME:   gestalt-platform
LAST DEPLOYED: Tue Apr 11 22:33:11 2017
NAMESPACE: gestalt-deploy-test-1
STATUS: DEPLOYED

RESOURCES:
==> v1/Secret
NAME        TYPE    DATA  AGE
gestalt-db  Opaque  3     3s

==> v1/Service
NAME                   CLUSTER-IP    EXTERNAL-IP  PORT(S)             AGE
gestalt-rabbit         10.0.51.39    <none>       5672/TCP,15672/TCP  3s
gestalt-meta           10.0.231.121  <none>       10131/TCP           3s
gestalt-security       10.0.94.215   <none>       9455/TCP            3s
gestalt-platform-etcd  None          <none>       2380/TCP,2379/TCP   3s
gestalt-db             10.0.29.233   <none>       5432/TCP            3s

==> apps/v1beta1/StatefulSet
NAME                   DESIRED  CURRENT  AGE
gestalt-platform-etcd  3        1        3s
gestalt-db             2        1        2s

==> extensions/v1beta1/Deployment
NAME              DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
gestalt-meta      1        1        1           0          3s
gestalt-deployer  1        1        1           0          3s
gestalt-rabbit    1        1        1           0          3s
gestalt-security  1        1        1           0          3s

==> v1/Endpoints
NAME        ENDPOINTS  AGE
gestalt-db  <none>     2s

```


Delete Gestalt platform and data volumes:
```
$ helm list
NAME            	REVISION	UPDATED                 	STATUS  	CHART        	NAMESPACE            
gestalt-platform	1       	Tue Apr 11 22:33:11 2017	DEPLOYED	gestalt-0.0.1	gestalt-deploy-test-1

$ helm delete --purge gestalt-platform

$ kubectl get pvc
NAME                              STATUS    VOLUME                                     CAPACITY   ACCESSMODES   AGE
datadir-gestalt-platform-etcd-0   Bound     pvc-601207de-1f28-11e7-bd9c-0a5e79684354   1Gi        RWO           16m
datadir-gestalt-platform-etcd-1   Bound     pvc-6037855d-1f28-11e7-bd9c-0a5e79684354   1Gi        RWO           16m
datadir-gestalt-platform-etcd-2   Bound     pvc-60690fdf-1f28-11e7-bd9c-0a5e79684354   1Gi        RWO           16m
pgdata-gestalt-db-0               Bound     pvc-6094e305-1f28-11e7-bd9c-0a5e79684354   1Gi        RWO           16m
pgdata-gestalt-db-1               Bound     pvc-609f46ce-1f28-11e7-bd9c-0a5e79684354   1Gi        RWO           16m

$ kubectl delete pvc --all
persistentvolumeclaim "datadir-gestalt-platform-etcd-0" deleted
persistentvolumeclaim "datadir-gestalt-platform-etcd-1" deleted
persistentvolumeclaim "datadir-gestalt-platform-etcd-2" deleted
persistentvolumeclaim "pgdata-gestalt-db-0" deleted
persistentvolumeclaim "pgdata-gestalt-db-1" deleted
```

> **Tip**: You can use the default [values.yaml](values.yaml)
