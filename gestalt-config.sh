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

GESTALT_DEPLOY_LABEL=`randomlabel`

# Set a random password if not set by user
if [ -z "$GESTALT_ADMIN_PASSWORD" ]; then
  GESTALT_ADMIN_PASSWORD=`randompw`
fi

DB_INITIAL_PASSWORD=`randompw`

generate_gestalt_config() {
cat - << EOF

deploymentLabel: $GESTALT_DEPLOY_LABEL

gestalt-db:
  StorageClassAnnotation: "$PV_STORAGE_ANNOTATION"
  etcd:
    StorageClassAnnotation: "$PV_STORAGE_ANNOTATION"

  # Randomized initial database credentials
  Credentials:
    Superuser: "$DB_INITIAL_PASSWORD"
    Admin: "$DB_INITIAL_PASSWORD"
    Standby: "$DB_INITIAL_PASSWORD"


# If true, will use Service of type Load Balancer to dynamically create
DynamicLoadbalancerEnabled: $KUBE_DYNAMIC_LOADBALANCER_ENABLED

# Applies if Dynamic LB is not available/enabled
ExternalLBs:
  Gateway: $EXTERNAL_GATEWAY_LB_HOSTNAME

Common:
  ReleaseTag: $DOCKER_RELEASE_TAG

DB:
  # Hostname must be fully qualified for Kong service
  Hostname: gestalt-db.gestalt-system.svc.cluster.local
  Port: 5432
  Username: postgres
  Password: "$DB_INITIAL_PASSWORD"

Security:
  Hostname: gestalt-security.gestalt-system
  Port: 9455
  Protocol: http
  AdminUser: gestalt-admin
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
EOF
}
