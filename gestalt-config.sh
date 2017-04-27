# This file is included by the installer

# Include variables for configuration
. gestalt-config.rc

random() { cat /dev/urandom | env LC_CTYPE=C tr -dc $1 | head -c $2; echo; }

randompw() {
  random [:alnum:] 16
}

DB_INITIAL_PASSWORD=`randompw`

generate_gestalt_config() {
cat - << EOF

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
  Hostname: gestalt-db
  Port: 5432
  Username: postgres
  Password: "$DB_INITIAL_PASSWORD"

Security:
  Hostname: gestalt-security
  Port: 9455
  Protocol: http
  AdminUser: gestalt-admin
  AdminPassword: "`randompw`"
  DatabaseName: gestalt-security

Rabbit:
  Hostname: gestalt-rabbit
  Port: 5672
  HttpPort: 15672

Meta:
  Hostname: gestalt-meta
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
