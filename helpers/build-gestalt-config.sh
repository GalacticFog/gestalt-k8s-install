# This file is included by the installer

random() { cat /dev/urandom | env LC_CTYPE=C tr -dc $1 | head -c $2; echo; }

randompw() {
  # Generate a random password (16 characters) that starts with an alpha character
  echo `random [:alpha:] 1``random [:alnum:] 15`
}

# Set a random password if not set by user
if [ -z "$gestalt_admin_username" ]; then
  gestalt_admin_username=gestalt-admin
  echo "Defaulting gestalt_admin_username to '$gestalt_admin_username'"
fi

if [ -z "$gestalt_admin_password" ]; then
  gestalt_admin_password=`randompw`
  echo "Defaulting gestalt_admin_password to random password"
fi

if [ -z "$database_name" ]; then
  database_name=postgres
  echo "Defaulting database_name to '$database_name'"
fi

# Defaults
gestalt_ui_ingress_protocol=http    # Must be HTTP unless ingress supports https
[ -z $external_gateway_protocol ]      && external_gateway_protocol=http
[ -z $gestalt_ui_service_nodeport ]    && gestalt_ui_service_nodeport=33000
[ -z $gestalt_kong_service_nodeport ]  && gestalt_kong_service_nodeport=33001

# if [ ! -z "$PV_STORAGE_CLASS" ]; then
#   PV_STORAGE_ANNOTATION="storageClassName: $PV_STORAGE_CLASS"
# fi
#
# if [ -z "$PV_STORAGE_ANNOTATION" ]; then
#   PV_STORAGE_ANNOTATION="storageClassName: default"
# fi

# By default, the service type will be NodePort, however if
# Dynamic LB is enabled, use the 'LoadBalancer' type for which
# Kubernetes attempts to dynamically provision a load balancer.
case $use_dynamic_loadbalancers in
  [YyTt1]*)
    use_dynamic_loadbalancers=Yes
    exposed_service_type=LoadBalancer
    ;;
  *)
    use_dynamic_loadbalancers=No
    exposed_service_type=NodePort
    ;;
esac

# Generate the configuration file and echos to stdout
generate_gestalt_config() {

if [ -z "$kubeconfig_data" ]; then
  exit_with_error "kubeconfig_data not provided"
fi

# other configuration
cat - << EOF

common:
  # imagePullPolicy: Always
  imagePullPolicy: IfNotPresent

security:
  image: $gestalt_security_image
  exposedServiceType: $exposed_service_type
  hostname: gestalt-security.$install_namespace
  port: 9455
  protocol: http
  adminUser: "$gestalt_admin_username"
  adminPassword: "$gestalt_admin_password"
  databaseName: gestalt-security

rabbit:
  image: $gestalt_rabbit_image
  hostname: gestalt-rabbit.$install_namespace
  port: 5672
  httpPort: 15672

meta:
  image: $gestalt_meta_image
  exposedServiceType: $exposed_service_type
  hostname: gestalt-meta.$install_namespace
  port: 10131
  protocol: http
  databaseName: gestalt-meta

laser:
  image: $gestalt_laser_image
  databaseName: laser-db
  cpu: ${gestalt_laser_cpu-0.25}
  memory: ${gestalt_laser_memory-1024}
  executorImages:
    dotNet: $gestalt_laser_executor_dotnet_image
    golang: $gestalt_laser_executor_golang_image
    js: $gestalt_laser_executor_js_image
    nodejs: $gestalt_laser_executor_nodejs_image
    jvm: $gestalt_laser_executor_jvm_image
    python: $gestalt_laser_executor_python_image
    ruby: $gestalt_laser_executor_ruby_image

gatewayManager:
  image: $gestalt_gateway_manager_image
  databaseName: gateway-db

kong:
  image: $gestalt_kong_image
  databaseName: kong-db
  nodePort: $gestalt_kong_service_nodeport

ui:
  image: $gestalt_ui_image
  exposedServiceType: $exposed_service_type
  nodePort: $gestalt_ui_service_nodeport
  ingress:
    host: $gestalt_ui_ingress_host

policy:
  image: $gestalt_policy_image

# Database configuration:
EOF

case $provision_internal_database in
  [YyTt1]*)

# Only used if provioning an internal database
initial_db_password=`randompw`

cat - << EOF
# Provision an internal database
# TODO - use this to determine whether to provision postgres as container
#provision-internal-db: true

postgresql:
  postgresUser: postgres
  postgresPassword: "$initial_db_password"
  postgresDatabase: $database_name
  persistence:
    size: $internal_database_pv_storage_size
    storageClass: "$internal_database_pv_storage_class"
EOF

if [ ! -z ${postgres_persistence_subpath+x} ]; then

cat - << EOF
    subPath: "$postgres_persistence_subpath"
EOF

fi
cat - << EOF
  resources:
    limits:
      memory: 256Mi
      cpu: 100m
  service:
    port: 5432
    type: ClusterIP

# Internal DB settings
db:
  # Hostname must be fully qualified for Kong service
  hostname: gestalt-postgresql.$install_namespace.svc.cluster.local
  port: 5432
  username: postgres
  password: "$initial_db_password"
  databaseName: $database_name
EOF

    ;;
  *) cat - << EOF
# Use an external database
# TODO - use this to determine whether to provision postgres as container
#provision-internal-db: false

# External DB settings:
db:
  # Hostname must be fully qualified for Kong service
  hostname: $database_hostname
  port: $database_port
  username: $database_user
  password: $database_password
  databaseName: $database_name
EOF
    ;;
esac

cat - << EOF

installer:
  image: $gestalt_installer_image
  mode: $gestalt_install_mode
  useDynamicLoadBalancers: $use_dynamic_loadbalancers
  externalGateway:
    dnsName: $external_gateway_host
    protocol: $external_gateway_protocol
    kongServiceName: $kong_ingress_service_name
  kubeconfig: $kubeconfig_data
EOF

}

process_kubeconfig() {
  # echo "Processing kubectl configuration (provided to the installer)..."

  os=`uname`

  if [ -z "$kubeconfig_data" ]; then
    echo "Obtaining kubeconfig from kubectl context '`kubectl config current-context`'"
    data=$(kubectl config view --raw --flatten=true --minify=true)
    kubeurl='https://kubernetes.default'
    echo "Converting server URL to '$kubeurl'"

    # for 'http'
    data=$(echo "$data" | sed "s;server: http://.*;server: $kubeurl;g")

    # for 'https'
    data=$(echo "$data" | sed "s;server: https://.*;server: $kubeurl;g")

    exit_on_error "Could not process kube config, aborting."

    if [ "$os" == "Darwin" ]; then
      kubeconfig_data=`echo "$data" | base64`
    elif [ "$os" == "Linux" ]; then
      kubeconfig_data=`echo "$data" | base64 | tr -d '\n'`
    else
      echo "Warning: unknown OS type '$os', treating as Linux"
      kubeconfig_data=`echo "$data" | base64 | tr -d '\n'`
    fi
  fi
}
