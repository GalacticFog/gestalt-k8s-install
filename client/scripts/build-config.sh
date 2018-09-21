#!/bin/bash

# Needs ./utilities/bash-utilities.sh

[[ $# -ne 1 ]] && echo && exit_with_error "File '$0' expects 1 parameter ($# provided) [$@], aborting."
GENERATED_CONF_FILE=$1


check_for_required_variables \
  admin_username \
  admin_password \
  provision_internal_database \
  database_image \
  database_image_tag \
  database_username \
  database_password \
  docker_registry \
  gestalt_docker_release_tag \
  external_gateway_host \
  gestalt_kong_service_nodeport \
  kubeconfig_data \
  gestalt_custom_resources \
  gestalt_ui_service_nodeport \
  gestalt_kong_service_nodeport \
  gestalt_logging_service_nodeport

  #FOG DEBUG

cat > ${GENERATED_CONF_FILE} << EOF
{
EOF

if [ "${fogcli_debug}" == "true" ]; then
cat >> ${GENERATED_CONF_FILE} << EOF
    "FOGCLI_DEBUG": "${fogcli_debug}",
EOF
fi

cat >> ${GENERATED_CONF_FILE} << EOF
    "ADMIN_PASSWORD": "${admin_password}",
    "ADMIN_USERNAME": "${admin_username}",
    "DATABASE_HOSTNAME": "gestalt-postgresql.gestalt-system.svc.cluster.local",
    "DATABASE_IMAGE": "${database_image}",
    "DATABASE_IMAGE_TAG": "${database_image_tag}",
    "DATABASE_PASSWORD": "${database_password}",
    "DATABASE_PORT": "5432",
    "DATABASE_USERNAME": "${database_username}",
    "DOTNET_EXECUTOR_IMAGE": "${docker_registry}/gestalt-laser-executor-dotnet:${gestalt_docker_release_tag}",
    "ELASTICSEARCH_HOST": "gestalt-elastic.gestalt-system",
    "ELASTICSEARCH_IMAGE": "${docker_registry}/elasticsearch-docker:5.3.1",
    "GESTALT_CUSTOM_RESOURCES": ${gestalt_custom_resources},
    "GESTALT_INSTALL_LOGGING_LVL": "${gestalt_install_mode}",
    "GOLANG_EXECUTOR_IMAGE": "${docker_registry}/gestalt-laser-executor-golang:${gestalt_docker_release_tag}",
    "GWM_EXECUTOR_IMAGE": "${docker_registry}/gestalt-api-gateway:${gestalt_docker_release_tag}",
    "GWM_IMAGE": "${docker_registry}/gestalt-api-gateway:${gestalt_docker_release_tag}",
    "JS_EXECUTOR_IMAGE": "${docker_registry}/gestalt-laser-executor-js:${gestalt_docker_release_tag}",
    "JVM_EXECUTOR_IMAGE": "${docker_registry}/gestalt-laser-executor-jvm:${gestalt_docker_release_tag}",
    "KONG_IMAGE": "${docker_registry}/kong:${gestalt_docker_release_tag}",
    "KONG_INGRESS_SERVICE_NAME": "kng",
    "KONG_NODEPORT": "${gestalt_kong_service_nodeport}",
    "KONG_VIRTUAL_HOST": "${external_gateway_host}:${gestalt_kong_service_nodeport}",
    "KUBECONFIG_BASE64": "${kubeconfig_data}",
    "LOGGING_IMAGE": "${docker_registry}/gestalt-log:${gestalt_docker_release_tag}",
    "LOGGING_NODEPORT": "${gestalt_logging_service_nodeport}",
    "META_HOSTNAME": "gestalt-meta.gestalt-system.svc.cluster.local",
    "META_IMAGE": "${docker_registry}/gestalt-meta:${gestalt_docker_release_tag}",
    "META_PORT": "10131",
    "META_PROTOCOL": "http",
    "NODEJS_EXECUTOR_IMAGE": "${docker_registry}/gestalt-laser-executor-nodejs:${gestalt_docker_release_tag}",
    "POLICY_IMAGE": "${docker_registry}/gestalt-policy:${gestalt_docker_release_tag}",
    "PROVISION_INTERNAL_DATABASE": "${provision_internal_database}",
    "PYTHON_EXECUTOR_IMAGE": "${docker_registry}/gestalt-laser-executor-python:${gestalt_docker_release_tag}",
    "RABBIT_HOST": "gestalt-rabbit.gestalt-system",
    "RABBIT_HOSTNAME": "gestalt-rabbit.gestalt-system",
    "RABBIT_HTTP_PORT": "15672",
    "RABBIT_IMAGE": "${docker_registry}/rabbit:${gestalt_docker_release_tag}",
    "RABBIT_PORT": "5672",
    "RUBY_EXECUTOR_IMAGE": "${docker_registry}/gestalt-laser-executor-ruby:${gestalt_docker_release_tag}",
    "SECURITY_HOSTNAME": "gestalt-security.gestalt-system.svc.cluster.local",
    "SECURITY_IMAGE": "${docker_registry}/gestalt-security:${gestalt_docker_release_tag}",
    "SECURITY_PORT": "9455",
    "SECURITY_PROTOCOL": "http",
    "UI_HOSTNAME": "gestalt-ui.gestalt-system.svc.cluster.local",
    "UI_IMAGE": "${docker_registry}/gestalt-ui-react:${gestalt_docker_release_tag}",
    "UI_NODEPORT": "${gestalt_ui_service_nodeport}",
    "UI_PORT": "80",
    "UI_PROTOCOL": "http"
}
EOF
