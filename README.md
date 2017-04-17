# Gestalt Platform Quick Start


## Prepare kubernetes provider configuration file to be used by gestalt

```
$ ./gen_kubeconfig_yaml.sh kubeproviderconfig
Encoded kubeproviderconfig to kube_provider_config.yaml. Pass with '-f' to helm install command, e.g.

    helm install ./gestalt -n gestalt-platform -f kube_provider_config.yaml
```


## Configure the Chart

```vi ./gestalt/values.yaml```



## Install the Chart

Install either with the following helm command:

```
$ helm install ./gestalt -n gestalt-platform -f kube_provider_config.yaml
```

Or by using the helper script:

```$ ./helm_install_gestalt.sh```
