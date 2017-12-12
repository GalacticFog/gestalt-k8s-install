# This file is included by the installer

random() { cat /dev/urandom | env LC_CTYPE=C tr -dc $1 | head -c $2; echo; }

randompw() {
  # Generate a random password (16 characters) that starts with an alpha character
  echo `random [:alpha:] 1``random [:alnum:] 15`
}

# Set a random password if not set by user
if [ -z "$GESTALT_ADMIN_USERNAME" ]; then
  GESTALT_ADMIN_USERNAME=gestalt-admin
  echo "Defaulting GESTALT_ADMIN_USERNAME to '$GESTALT_ADMIN_USERNAME'"
fi

if [ -z "$GESTALT_ADMIN_PASSWORD" ]; then
  GESTALT_ADMIN_PASSWORD=`randompw`
  echo "Defaulting GESTALT_ADMIN_PASSWORD to random password"
fi

if [ -z "$DATABASE_NAME" ]; then
  DATABASE_NAME=postgres
  echo "Defaulting DATABASE_NAME to '$DATABASE_NAME'"
fi

# Defaults
GESTALT_UI_INGRESS_PROTOCOL=http    # Must be HTTP unless ingress supports https
EXTERNAL_GATEWAY_PROTOCOL=${EXTERNAL_GATEWAY_PROTOCOL-http}

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
case $USE_DYNAMIC_LOADBALANCERS in
  [YyTt1]*)
    USE_DYNAMIC_LOADBALANCERS=Yes
    EXPOSED_KUBE_SERVICE_TYPE=LoadBalancer
    ;;
  *)
    USE_DYNAMIC_LOADBALANCERS=No
    EXPOSED_KUBE_SERVICE_TYPE=NodePort
    ;;
esac

# Generate the configuration file and echos to stdout
generate_gestalt_config() {

if [ -z "$KUBECONFIG_DATA" ]; then
  exit_with_error "KUBECONFIG_DATA not provided"
fi

# other configuration
cat - << EOF

common:
  imagePullPolicy: Always

security:
  image: $GESTALT_SECURITY_IMG
  exposedServiceType: $EXPOSED_KUBE_SERVICE_TYPE
  hostname: gestalt-security.$INSTALL_NAMESPACE
  port: 9455
  protocol: http
  adminUser: "$GESTALT_ADMIN_USERNAME"
  adminPassword: "$GESTALT_ADMIN_PASSWORD"
  databaseName: gestalt-security

rabbit:
  image: $GESTALT_RABBIT_IMG
  hostname: gestalt-rabbit.$INSTALL_NAMESPACE
  port: 5672
  httpPort: 15672

meta:
  image: $GESTALT_META_IMG
  exposedServiceType: $EXPOSED_KUBE_SERVICE_TYPE
  hostname: gestalt-meta.$INSTALL_NAMESPACE
  port: 10131
  protocol: http
  databaseName: gestalt-meta

laser:
  image: $GESTALT_LASER_IMG
  databaseName: laser-db
  cpu: ${GESTALT_LASER_CPU-0.25}
  memory: ${GESTALT_LASER_MEMORY-1024}
  executorImages:
    dotNet: $GESTALT_LASER_EXECUTOR_DOTNET_IMG
    golang: $GESTALT_LASER_EXECUTOR_GOLANG_IMG
    js: $GESTALT_LASER_EXECUTOR_JS_IMG
    nodejs: $GESTALT_LASER_EXECUTOR_NODEJS_IMG
    jvm: $GESTALT_LASER_EXECUTOR_JVM_IMG
    python: $GESTALT_LASER_EXECUTOR_PYTHON_IMG
    ruby: $GESTALT_LASER_EXECUTOR_RUBY_IMG

gatewayManager:
  image: $GESTALT_GATEWAY_MGR_IMG
  databaseName: gateway-db

kong:
  image: $GESTALT_KONG_IMG
  databaseName: kong-db

ui:
  image: $GESTALT_UI_IMG
  exposedServiceType: $EXPOSED_KUBE_SERVICE_TYPE
  ingress:
    host: $GESTALT_UI_INGRESS_HOST

policy:
  image: $GESTALT_POLICY_IMG

# Database configuration:
EOF

case $PROVISION_INTERNAL_DATABASE in
  [YyTt1]*)

# Only used if provioning an internal database
INTERNAL_DATABASE_INITIAL_PASSWORD=`randompw`

cat - << EOF
# Provision an internal database
# TODO - use this to determine whether to provision postgres as container
#provision-internal-db: true

postgresql:
  postgresUser: postgres
  postgresPassword: "$INTERNAL_DATABASE_INITIAL_PASSWORD"
  postgresDatabase: $DATABASE_NAME
  persistence:
    size: $INTERNAL_DATABASE_PV_STORAGE_SIZE
    storageClass: "$INTERNAL_DATABASE_PV_STORAGE_CLASS"
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
  hostname: gestalt-postgresql.$INSTALL_NAMESPACE.svc.cluster.local
  port: 5432
  username: postgres
  password: "$INTERNAL_DATABASE_INITIAL_PASSWORD"
  databaseName: $DATABASE_NAME
EOF

    ;;
  *) cat - << EOF
# Use an external database
# TODO - use this to determine whether to provision postgres as container
#provision-internal-db: false

# External DB settings:
db:
  # Hostname must be fully qualified for Kong service
  hostname: $DATABASE_HOSTNAME
  port: $DATABASE_PORT
  username: $DATABASE_USER
  password: $DATABASE_PASSWORD
  databaseName: $DATABASE_NAME
EOF
    ;;
esac

cat - << EOF

installer:
  image: $GESTALT_INSTALLER_IMG
  mode: $GESTALT_INSTALL_MODE
  useDynamicLoadBalancers: $USE_DYNAMIC_LOADBALANCERS
  externalGateway:
    dnsName: $EXTERNAL_GATEWAY_HOST
    protocol: $EXTERNAL_GATEWAY_PROTOCOL
    kongServiceName: $KONG_INGRESS_SERVICE_NAME
  kubeconfig: $KUBECONFIG_DATA
EOF

}

process_kubeconfig() {
  # echo "Processing kubectl configuration (provided to the installer)..."

  os=`uname`

  if [ -z "$KUBECONFIG_DATA" ]; then
    echo "Obtaining kubeconfig from kubectl"

    data=$(kubectl config view --raw --flatten=true --minify=true)
    exit_on_error "Could not process kube config, aborting."

    if [ "$os" == "Darwin" ]; then
      KUBECONFIG_DATA=`echo "$data" | base64`
    elif [ "$os" == "Linux" ]; then
      KUBECONFIG_DATA=`echo "$data" | base64 | tr -d '\n'`
    else
      echo "Warning: unknown OS type '$os', treating as Linux"
      KUBECONFIG_DATA=`echo "$data" | base64 | tr -d '\n'`
    fi
  fi
}
