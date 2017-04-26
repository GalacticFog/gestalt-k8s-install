# This file is included by the installer

# Include variables for configuration
. gestalt-config.rc

random() { cat /dev/urandom | env LC_CTYPE=C tr -dc $1 | head -c $2; echo; }

randompw() {
  random [:alnum:] 16
}

generate_gestalt_config() {
cat - << EOF

# Override sub-chart with persistent volume settings
gestalt-db:
  PersistentVolumeStorageClass: $PV_STORAGE_CLASS
  etcd:
    PersistentVolumeStorageClass: $PV_STORAGE_CLASS

Common:
  ReleaseTag: $DOCKER_RELEASE_TAG

DB:
  Hostname: gestalt-db
  Port: 5432
  Username: postgres
  Password: letmein

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
