#!/usr/bin/env bash

# shellcheck disable=SC2086
set -o errexit
set -o nounset
set -o pipefail

export MAX_COUNT=${MAX_COUNT-20}
export SLEEP_DURATION=${SLEEP_DURATION-30}
ANZIBLE_EXTRA_ARGS="--timeout 300 --fork 50"

export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_GRAFANA_COLLECTION_VERSION=5.0.0
export GRAFANA_ALLOY_VERSION=${GRAFANA_ALLOY_VERSION-"1.3.0"}
export GRAFANA_ALLOY_RETRY_COUNT=${GRAFANA_ALLOY_RETRY_COUNT-"10"}
export GRAFANA_ALLOY_DELAY_DURATION=${GRAFANA_ALLOY_DELAY_DURATION-"30"}
export ALLOY_CONFIGS="$MODULE_PATH/../../files/configs/*.alloy"

echo "[+] Current dir: $(pwd)"
echo "[+] MODULE_PATH: $MODULE_PATH"
echo "[+] INVENTORY_HOSTS: $INVENTORY_HOSTS"
echo "[+] SSH_AUTH_SOCK: $SSH_AUTH_SOCK"
echo "[+] GRAFANA_ALLOY_VERSION: $GRAFANA_ALLOY_VERSION"
echo "[+] GRAFANA_ALLOY_CONFIG: $GRAFANA_ALLOY_CONFIG"

echo "[+] List all ssh identities"
ssh-add -l || echo 'List ssh private keys'

echo "[+] Wait another ansible-galaxy processes"
count=0
while true; do
	if ! pgrep ansible-galaxy >/dev/null; then
		break
	fi

	count=$((count + 1))
	echo "[+] Retrying ...: '$count'"
	[[ $count -eq "$MAX_COUNT" ]] && echo "Exceeded the retry count" && exit 1

	echo "[+] Delaying ... : '5'"
	sleep 5
done

echo "[+] Install requirement collection"
ansible-galaxy collection install grafana.grafana:${ANSIBLE_GRAFANA_COLLECTION_VERSION} -p ~/.ansible/collections/

echo "[+] [Cluster] Pinging"
count=0
while true; do
	if ansible -b -u ubuntu -i "${INVENTORY_HOSTS}," all -m ping ${ANZIBLE_EXTRA_ARGS}; then
		break
	fi

	count=$((count + 1))
	echo "[+] Retrying ...: '$count'"
	[[ $count -eq "$MAX_COUNT" ]] && echo "Exceeded the retry count" && exit 1

	echo "[+] Delaying ... : '$SLEEP_DURATION'"
	sleep ${SLEEP_DURATION}
done

TMP_FILE=$(mktemp)_config.txt

echo "[+] [Cluster] Append common declare definitions"
for f in ${ALLOY_CONFIGS}; do
	cat $f >>"$TMP_FILE"
done

echo "[+] [Cluster] Append configurable alloy config"
cat <<EOF >>"$TMP_FILE"

$GRAFANA_ALLOY_CONFIG
EOF

echo "[+] [Cluster] Show config.txt: $TMP_FILE"

echo "[+] [Cluster] Configure with Ansible Playbook"
ansible-playbook \
	-b -u ubuntu -i "${INVENTORY_HOSTS}," \
	"$MODULE_PATH/../../files/playbooks/configure.yml" \
	${ANZIBLE_EXTRA_ARGS} \
	--extra-vars "config='$(cat ${TMP_FILE})'" \
	--extra-vars "version=$GRAFANA_ALLOY_VERSION" \
	--extra-vars "retry_count=$GRAFANA_ALLOY_RETRY_COUNT" \
	--extra-vars "delay_duration=$GRAFANA_ALLOY_DELAY_DURATION"

echo "[+] [Cluster] All done"
