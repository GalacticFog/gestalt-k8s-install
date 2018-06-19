cat - << EOF
{
  "database": {
    "username": "\$DATABASE_USERNAME",
    "password": "\$DATABASE_PASSWORD",
    "host": "\$DATABASE_HOSTNAME",
    "port": \$DATABASE_PORT,
    "protocol": "http"
  },
  "security": {
    "protocol": "\$SECURITY_PROTOCOL",
    "host": "\$SECURITY_HOSTNAME",
    "port": \$SECURITY_PORT,
    "key": "\$SECURITY_KEY",
    "secret": "\$SECURITY_SECRET"
  },
  "caas": {
    "url" : null,
    "username" : null,
    "password" : null,
    "kubeconfig": "$kubeconfig_data"
  },
  "laser": {
    "dbName": "laser-db",
    "laserImage" : "$gestalt_laser_image",
	"laserCpu" : ${gestalt_laser_cpu-0.25},
	"laserMem" : ${gestalt_laser_memory-1024},
    "laserMaxCoolConnectionTime" : 60,
    "laserExecutorHeartbeatPeriod" : 5000,
    "laserExecutorHeartbeatTimeout" : 5000,
    "esPort": 9200,
    "esHost": "gestalt-elastic.$install_namespace",
    "esProtocol": "http",
    "globalMinCoolExecutors" : 1,
    "globalScaleDownTimeSecs" : 15,
    "computeUsername": "\$SECURITY_KEY",
    "computePassword": "\$SECURITY_SECRET",
    "computeUrl": "\$META_URL",
    "monitorExchange": "default-monitor-echange",
    "monitorTopic": "default-monitor-topic",
    "responseExchange": "default-laser-exchange",
    "responseTopic": "default-response-topic",
    "listenExchange": "default-listen-exchange",
    "listenRoute": "default-listen-route",
	"executors" : [

EOF

## Don't output the first comma, but output after that.
## Used for building an array "[`comma`a `comma`b `comma`c ]" --> "[ a, b, c ]", e.g. if there's only one element,
## don't print out a comma.
comma_flag=
function comma() {
  echo $comma_flag
  comma_flag=","
}

executor_sizes=$(
cat - <<EOF
"SIZES_0_CPU": "0.1",
          "SIZES_0_MEM": "512",
          "SIZES_1_CPU": "0.2",
          "SIZES_1_MEM": "512",
          "SIZES_2_CPU": "0.4",
          "SIZES_2_MEM": "512",
          "SIZES_3_CPU": "0.5",
          "SIZES_3_MEM": "512",
          "SIZES_4_CPU": "0.5",
          "SIZES_4_MEM": "1024",
          "SIZES_5_CPU": "1",
          "SIZES_5_MEM": "1024"
EOF
)  


# JS Executor
if [ ! -z "$gestalt_laser_executor_js_image" ]; then
  comma
  cat - <<EOF
      {
        "image" : "$gestalt_laser_executor_js_image",
				"name" : "js",
				"cmd" : "bin/gestalt-laser-executor-js",
				"runtime" : "nashorn",
				"metaType" : "Nashorn",
        "extraEnv": {
          "MIN_COOL": "0",
          $executor_sizes,
          "SIZES_0_MIN_COOL": "$gestalt_laser_executor_js_mincool"
        }
			}
EOF
fi

# JS Executor
if [ ! -z "$gestalt_laser_executor_nodejs_image" ]; then
  comma
  cat - <<EOF
      {
        "image" : "$gestalt_laser_executor_nodejs_image",
				"name" : "nodejs",
				"cmd" : "bin/gestalt-laser-executor-nodejs",
				"runtime" : "nodejs",
				"metaType" : "NodeJS",
        "extraEnv": {
          "MIN_COOL": "0",
          $executor_sizes,
          "SIZES_0_MIN_COOL": "$gestalt_laser_executor_nodejs_mincool"
        }
			}
EOF
fi

# JVM Executor
if [ ! -z "$gestalt_laser_executor_jvm_image" ]; then
  comma
  cat - <<EOF
      {
        "image" : "$gestalt_laser_executor_jvm_image",
				"name" : "jvm",
				"cmd" : "bin/gestalt-laser-executor-jvm",
				"runtime" : "java;scala",
				"metaType" : "Java",
        "extraEnv": {
          "MIN_COOL": "0",
          $executor_sizes,
          "SIZES_0_MIN_COOL": "$gestalt_laser_executor_jvm_mincool"
        }
			}
EOF
fi

# .NET Executor
if [ ! -z "$gestalt_laser_executor_dotnet_image" ]; then
  comma
  cat - <<EOF
      {
        "image" : "$gestalt_laser_executor_dotnet_image",
				"name" : "dotnet",
				"cmd" : "bin/gestalt-laser-executor-dotnet",
				"runtime" : "csharp;dotnet",
				"metaType" : "CSharp",
        "extraEnv": {
          "MIN_COOL": "0",
          $executor_sizes,
          "SIZES_0_MIN_COOL": "$gestalt_laser_executor_dotnet_mincool"
        }
			}
EOF
fi

# Python Executor
if [ ! -z "$gestalt_laser_executor_python_image" ]; then
  comma
  cat - <<EOF
      {
        "image" : "$gestalt_laser_executor_python_image",
				"name" : "python",
				"cmd" : "bin/gestalt-laser-executor-python",
				"runtime" : "python",
				"metaType" : "Python",
        "extraEnv": {
          "MIN_COOL": "0",
          $executor_sizes,
          "SIZES_0_MIN_COOL": "$gestalt_laser_executor_python_mincool"
        }
			}
EOF
fi

# RUBY Executor
if [ ! -z "$gestalt_laser_executor_ruby_image" ]; then
  comma
  cat - <<EOF
      {
        "image" : "$gestalt_laser_executor_ruby_image",
				"name" : "ruby",
				"cmd" : "bin/gestalt-laser-executor-ruby",
				"runtime" : "ruby",
				"metaType" : "Ruby",
        "extraEnv": {
          "MIN_COOL": "0",
          $executor_sizes,
          "SIZES_0_MIN_COOL": "$gestalt_laser_executor_ruby_mincool"
        }
			}
EOF
fi

# GO-lang Executor
if [ ! -z "$gestalt_laser_executor_golang_image" ]; then
  comma
  cat - <<EOF
      {
        "image" : "$gestalt_laser_executor_golang_image",
				"name" : "golang",
				"cmd" : "bin/gestalt-laser-executor-golang",
				"runtime" : "golang",
				"metaType" : "GoLang",
        "extraEnv": {
          "MIN_COOL": "0",
          $executor_sizes,
          "SIZES_0_MIN_COOL": "$gestalt_laser_executor_golang_mincool"
        }
			}
EOF
fi

cat - <<EOF
		]
  },
	"policy" : {
		"image" : "$gestalt_policy_image",
		"rabbitExchange" : "policy-exchange",
		"rabbitRoute" : "policy",
		"laserUser" : "\$SECURITY_KEY",
		"laserPassword" : "\$SECURITY_SECRET"
	},
	"kong" : {
		"image" : "$gestalt_kong_image",
        "dbName" : "kong-db",
		"gatewayVHost" : "\$EXTERNAL_GATEWAY_HOST:$gestalt_kong_service_nodeport",
        "externalProtocol" : "$external_gateway_protocol",
        "servicePort": ${gestalt_kong_service_nodeport:-0}
	},
    "logging": {
        "image" : "$gestalt_log_image",
        "esClusterName": "myesdb",
        "esComputeType": "kube",
        "esColdDays": 1,
        "esHotDays": 1,
        "esServiceHost": "gestalt-elastic.$install_namespace",
        "esServicePort": 9300,
        "esSnapshotRepo": "",
        "vhostOverride": "\$EXTERNAL_GATEWAY_HOST:$gestalt_logging_service_nodeport",
        "vhostProtoOverride": "http",
        "servicePort": ${gestalt_logging_service_nodeport:-0}
    },
	"rabbit" : {
		"host" : "gestalt-rabbit.$install_namespace",
		"port" : 5672
	},
	"gateway" : {
		"image" : "$gestalt_gateway_manager_image",
		"dbName" : "gateway-db"
	}
}
EOF
