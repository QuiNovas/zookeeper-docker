# Zookeeper with prometheus.

## Run Zookeeper with Prometheus agent in docker

# Configuration
### The following environment variables are supported for configuration

|         Variable        |            Description              |      Default      |
|-------------------------|-------------------------------------|-------------------|
| $PROMETHEUS_PORT        | Port that prometheus listens on     | 7070              |
| $ZK_SERVER_HEAP         | Maximum heap size in MB             | 256               |
| $JVMFLAGS               | Extra jvm flags to pass to run cmd  | (empty)           |
| $DEBUG                  | Prints the full run command         | (empty)           |
| $ZOO_EXTRA_ARGS         | Extra args to pass to run cmd       | (empty)           |
| $WITHOUT_PROMETHEUS     | Don't run prometheus agent          | (empty)           |
| $PREHOOK                | Full path to prehook script         | (empty)           |
| $ASYNC_HOOK             | FUll path to async hook script      | (empty)           |


## Prehook Script

Setting the $PREHOOK variable with the path to an executable will execute the file synchronously and block Zookeeper from executing until the script
finishes. Note that Zookeeper will try to start regardless of the exit code of this script.

## Async hook

Setting the $ASYNC_HOOK variable with the path to an executable will execute the file asynchronously in a subshell to zkServer.sh. The zkServer.sh will
continue to execute. There is no guarantee that your script will finish before Zookeeper is started. A non-zero exit code will not affect Zookeeper from
starting.
