# Exit on error
set -e

apply_conf()
{
	diff "${1}" "${2}" || (cp -ar "${1}" "${2}" && echo "Updated '${2}'!")
}

update()
{
	cd grafana
	apply_conf defaults.ini "${GRAFANA_DIR}/conf/defaults.ini"
	apply_conf datasources.yaml "${GRAFANA_DIR}/conf/provisioning/datasources/datasources.yaml"
	apply_conf dashboards.yaml "${GRAFANA_DIR}/conf/provisioning/dashboards/dashboards.yaml"
	cd dashboards
	for DASHBOARD in *; do
		sed -i "${DASHBOARD}" -e "s|\${DS_INFLUXK8S}|${DS_INFLUXK8S}|g"
		apply_conf "${DASHBOARD}" "${GRAFANA_DIR}/data/dashboards/${DASHBOARD}"
	done
}

echo "Initializing..."
if [ -d "${GRAFANA_DIR}/conf" ]; then
    echo "Updating existing config..."
	update
else
	echo "Installing to '${GRAFANA_DIR}'..."
	mkdir -p "${GRAFANA_DIR}/conf/provisioning/dashboards"
	mkdir -p "${GRAFANA_DIR}/conf/provisioning/datasources"
	mkdir -p "${GRAFANA_DIR}/conf/provisioning/notifiers"
	mkdir -p "${GRAFANA_DIR}/conf/provisioning/plugins"
	mkdir -p "${GRAFANA_DIR}/data/logs"
	mkdir -p "${GRAFANA_DIR}/data/dashboards"
	ln -s /usr/share/grafana/public "${GRAFANA_DIR}/public"
	update
fi
echo "Done!"
