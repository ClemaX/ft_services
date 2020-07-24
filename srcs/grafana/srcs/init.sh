# Exit on error
set -e

if [ -d "${GRAFANA_DIR}/conf" ]; then
	echo "Already initialized."
	echo "Applying config..."
	cp /defaults.ini ${GRAFANA_DIR}/conf/
	echo "Done!"
else
	echo "Initializing..."
	mkdir -p ${GRAFANA_DIR}/conf/provisioning/dashboards
	mkdir -p ${GRAFANA_DIR}/conf/provisioning/datasources
	mkdir -p ${GRAFANA_DIR}/conf/provisioning/notifiers
	mkdir -p ${GRAFANA_DIR}/conf/provisioning/plugins
	mkdir -p ${GRAFANA_DIR}/data/logs
	cp -ar /usr/share/grafana/public ${GRAFANA_DIR}
	cp /defaults.ini ${GRAFANA_DIR}/conf/
	cp /datasources.yaml ${GRAFANA_DIR}/conf/provisioning/datasources/
fi