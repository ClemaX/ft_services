#!/bin/sh

# Exit on error
set -e

# Check for initialization
if [ -d "${INFLUXDB_DATA_DIR}" ]; then
    echo "Already initialized."
else
    echo "Initializing..."
    # Launch and wait for influxd in background
    influxd & until influx -execute exit </dev/null >/dev/null 2>&1; do sleep 0.2; echo -n '.'; done; echo
    # Create admin user
    influx -execute "CREATE USER \"${INFLUXDB_ADMIN_USERNAME}\" WITH PASSWORD '${INFLUXDB_ADMIN_PASSWORD}' WITH ALL PRIVILEGES"
    # Authenticate as admin
    export INFLUX_USERNAME=${INFLUXDB_ADMIN_USERNAME}
    export INFLUX_PASSWORD=${INFLUXDB_ADMIN_PASSWORD}
    # Create monitoring database
    influx -execute "CREATE DATABASE \"${INFLUXDB_DATABASE}\""
    # Create telegraf user with write privileges
    influx -execute "CREATE USER \"${INFLUXDB_TELEGRAF_USERNAME}\" WITH PASSWORD '${INFLUXDB_TELEGRAF_PASSWORD}'"
    influx -execute "GRANT WRITE ON \"${INFLUXDB_DATABASE}\" TO \"${INFLUXDB_TELEGRAF_USERNAME}\""
    # Create grafana user with read privileges
    influx -execute "CREATE USER \"${INFLUXDB_GRAFANA_USERNAME}\" WITH PASSWORD '${INFLUXDB_GRAFANA_PASSWORD}'"
    influx -execute "GRANT READ ON \"${INFLUXDB_DATABASE}\" TO \"${INFLUXDB_GRAFANA_USERNAME}\""
    # Shutdown influxd
    kill $(pidof influxd)
    echo "Done!"
fi
