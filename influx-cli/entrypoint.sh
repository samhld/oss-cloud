#!/bin/bash

./bin/linux/influx setup --bucket sam-bucket -t ${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN} -o ${DOCKER_INFLUXDB_INIT_ORG} --username=${DOCKER_INFLUXDB_INIT_USERNAME} --password=${DOCKER_INFLUXDB_INIT_PASSWORD} --host=http://influxd:8086 -f --skip-verify

./bin/linux/influx bucket create 
        --name downsampled \
        --token ${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN} \
        --org ${DOCKER_INFLUXDB_INIT_ORG} \
        --host=http://influxd:8086

# ./bin/linux/influx bucket create --name sam-bucket-sync -t ${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN} -o ${DOCKER_INFLUXDB_INIT_ORG} --host=http://influxd:8086

./bin/linux/influx remote create \
        --name oss-cloud 
        --token ${INFLUX_REMOTE_TOKEN} \
        --org ${INFLUX_REMOTE_ORG} \
        --host=http://influxd:8086

./bin/linux/influx replication create \
        --name oss-cloud 
        --token ${INFLUX_REMOTE_TOKEN} \
        --org ${INFLUX_REMOTE_ORG} \
        --host=http://influxd:8086
