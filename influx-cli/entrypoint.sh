#!/bin/bash

while ! curl -s -k http://influxd:8086/health; do sleep 1; done

# ./bin/linux/influx setup --bucket sam-bucket -t ${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN} -o ${DOCKER_INFLUXDB_INIT_ORG} --username=${DOCKER_INFLUXDB_INIT_USERNAME} --password=${DOCKER_INFLUXDB_INIT_PASSWORD} --host=http://influxd:8086 -f --skip-verify

# ./bin/linux/influx setup --bucket sam-bucket -t ${INFLUX_LOCAL_TOKEN} -o ${INFLUX_LOCAL_ORG} --username=${DOCKER_INFLUXDB_INIT_USERNAME} --password=${DOCKER_INFLUXDB_INIT_PASSWORD} --host=http://influxd:8086 -f --skip-verify

./bin/linux/influx bucket create \
        --name downsampled \
        --token ${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN} \
        --org ${DOCKER_INFLUXDB_INIT_ORG} \
        --host=http://influxd:8086

# # ./bin/linux/influx bucket create --name sam-bucket-sync -t ${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN} -o ${DOCKER_INFLUXDB_INIT_ORG} --host=http://influxd:8086

./bin/linux/influx remote create \
        --name oss-cloud \
        --org samhld \
        --token ${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN} \
        --remote-api-token ${INFLUX_REMOTE_TOKEN} \
        --remote-org-id ${INFLUX_REMOTE_ORG_ID} \
        --remote-url ${INFLUX_REMOTE_HOST} \
        --host=http://influxd:8086

apt-get install jq -y

export INFLUX_BUCKET_ID=$(curl --get http://influxd:8086/api/v2/buckets --header "Authorization: Token ${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN}"  \
--header "Content-type: application/json" \
--data-urlencode "org=samhld" | jq .buckets | jq 'map(select(.name=="downsampled")) | .[].id' | tr -d '"')

export INFLUX_ORG_ID=$(bin/linux/influx org list --token ${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN} --host http://influxd:8086 --json | jq -r '.[0].id')

export REMOTE_ID=$(curl --location --request GET "http://influxd:8086/api/v2/remotes?orgID=${INFLUX_ORG_ID}" \
--header 'Authorization: Token Et0vp9d9Bx1fJbTcASO29wmLlUXNLZcSl4rtJP1W2iD_quofAKFiL0AJ3Dtvnl_9OsuV44Z1riZu73CXbIB9QQ==' \
--data-raw '' | jq -r '.remotes[0].id')

./bin/linux/influx replication create \
        --name oss-cloud \
        --remote-id ${REMOTE_ID} \
        --token ${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN} \
        --org-id ${INFLUX_ORG_ID} \
        --local-bucket-id ${INFLUX_BUCKET_ID} \
        --remote-bucket-id 86e6899e10629f54 \
        --host=http://influxd:8086

# ./bin/linux/influx task create -f /go/influx-cli/downsample_procstat.flux