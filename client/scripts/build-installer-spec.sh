#!/bin/bash

# Needs ./utilities/bash-utilities.sh

[[ $# -ne 1 ]] && echo && exit_with_error "File '$0' expects 1 parameter ($# provided) [$@], aborting."
GENERATED_CONF_FILE=$1


check_for_required_variables \
  docker_registry \
  gestalt_installer_docker_release_tag \
  gestalt_install_mode

cat > ${GENERATED_CONF_FILE} << EOF
# This is a pod w/ restartPolicy=Never so that the installer only runs once.
apiVersion: v1
kind: Pod
metadata:
  name: gestalt-installer
  labels:
    gestalt-app: installer
spec:
  restartPolicy: Never
  containers:
  - name: gestalt-installer
    image: "${docker_registry}/gestalt-installer:${gestalt_installer_docker_release_tag}"
    imagePullPolicy: Always
    # 'deploy' arg signals deployment of gestalt platform
    # 'debug' arg signals debug output
    args: ["install", "${gestalt_install_mode}"]
    volumeMounts:
    - mountPath: /config
      name: config
    - mountPath: /license
      name: license
EOF

if [ ${gestalt_custom_resources} == "true" ]; then
cat >> ${GENERATED_CONF_FILE} << EOF
    - mountPath: /resource_templates
      name: resources
EOF
fi

cat >> ${GENERATED_CONF_FILE} << EOF
  volumes:
    - name: config
      configMap:
        name: installer-config
    - name: license
      configMap:
        name: gestalt-license
EOF


if [ ${gestalt_custom_resources} == "true" ]; then
cat >> ${GENERATED_CONF_FILE} << EOF
    - name: resources
      configMap:
        name: gestalt-resources
EOF
fi