# This file is included by the installer

# Include variables for configuration
. gestalt-config.rc

random() { cat /dev/urandom | env LC_CTYPE=C tr -dc $1 | head -c $2; echo; }

randompw() {
  # Generate a random password (16 characters) that starts with an alpha character
  echo `random [:alpha:] 1``random [:alnum:] 15`
}

randomlabel() {
  echo `random [:xdigit:] 4 | tr '[:upper:]' '[:lower:]'`
}

# Calculate initial values for variables

# Set a random password if not set by user
if [ -z "$GESTALT_ADMIN_USERNAME" ]; then
  GESTALT_ADMIN_USERNAME=gestalt-admin
  echo "Admin username not set, defaulting to '$GESTALT_ADMIN_USERNAME'"
fi

if [ -z "$GESTALT_ADMIN_PASSWORD" ]; then
  GESTALT_ADMIN_PASSWORD=`randompw`
  echo "Admin password not set, generating random password"
fi

if [ -z "$DATABASE_NAME" ]; then
  DATABASE_NAME=postgres
  echo "Defaulting to database name '$DATABASE_NAME'"
fi

if [ -z "$PV_STORAGE_ANNOTATION" ]; then
  PV_STORAGE_ANNOTATION="volume.alpha.kubernetes.io/storage-class: default"
fi

# By default, the service type will be NodePort, however if
# Dynamic LB is enabled, use the 'LoadBalancer' type for which
# Kubernetes attempts to dynamically provision a load balancer.
case $KUBE_DYNAMIC_LOADBALANCER_ENABLED in
  [YyTt1]*)
    KUBE_DYNAMIC_LOADBALANCER_ENABLED=Yes
    PUBLIC_KUBE_SERVICE_TYPE=LoadBalancer
    ;;
  *)
    KUBE_DYNAMIC_LOADBALANCER_ENABLED=No
    PUBLIC_KUBE_SERVICE_TYPE=NodePort
    ;;
esac

# Generate the configuration file and echos to stdout
generate_gestalt_config() {

# other configuration
cat - << EOF

deploymentLabel: `randomlabel`

# If true, will use Service of type Load Balancer to dynamically create
DynamicLoadbalancerEnabled: $KUBE_DYNAMIC_LOADBALANCER_ENABLED

PublicServiceType: $PUBLIC_KUBE_SERVICE_TYPE

# Applies if Dynamic LB is not available/enabled
ExternalGateway:
  DnsName: $EXTERNAL_GATEWAY_DNSNAME
  Protocol: $EXTERNAL_GATEWAY_PROTOCOL

Mode: $GESTALT_INSTALL_MODE

Common:
  ReleaseTag: $COMMON_RELEASE_TAG

Installer:
  ReleaseTag: $INSTALLER_RELEASE_TAG

Security:
  Hostname: gestalt-security.gestalt-system
  Port: 9455
  Protocol: http
  AdminUser: "$GESTALT_ADMIN_USERNAME"
  AdminPassword: "$GESTALT_ADMIN_PASSWORD"
  DatabaseName: gestalt-security

Rabbit:
  Hostname: gestalt-rabbit.gestalt-system
  Port: 5672
  HttpPort: 15672

Meta:
  Hostname: gestalt-meta.gestalt-system
  Port: 10131
  Protocol: http
  DatabaseName: gestalt-meta

Laser:
  DatabaseName: laser-db
  Cpu: 0.25
  Memory: 1024

Gateway:
  DatabaseName: gateway-db

Kong:
  DatabaseName: kong-db

# Database configuration:
EOF

case $PROVISION_INTERNAL_DATABASE in
  [YyTt1]*)

# Only used if provioning an internal database (gestalt-db chart)
DB_INITIAL_PASSWORD=`randompw`

cat - << EOF
# Provision an internal database using the 'gestalt-db' sub chart
provision-internal-db: true

gestalt-db:
  StorageClassAnnotation: "$PV_STORAGE_ANNOTATION"
  etcd:
    StorageClassAnnotation: "$PV_STORAGE_ANNOTATION"

  # Randomized initial database credentials
  Credentials:
    Superuser: "$DB_INITIAL_PASSWORD"
    Admin: "$DB_INITIAL_PASSWORD"
    Standby: "$DB_INITIAL_PASSWORD"

# Internal DB settings
DB:
  # Hostname must be fully qualified for Kong service
  Hostname: gestalt-db.gestalt-system.svc.cluster.local
  Port: 5432
  Username: postgres
  Password: "$DB_INITIAL_PASSWORD"
  DbName: $DATABASE_NAME
EOF

    ;;
  *) cat - << EOF
# Use an external database
provision-internal-db: false

# External DB settings:
DB:
  # Hostname must be fully qualified for Kong service
  Hostname: $DATABASE_HOSTNAME
  Port: $DATABASE_PORT
  Username: $DATABASE_USER
  Password: $DATABASE_PASSWORD
  DbName: $DATABASE_NAME
EOF
    ;;
esac

}
