# syntax=docker/dockerfile:1

FROM golang:1.17-buster

# Required packages
RUN apt-get update && \
    apt-get install pkg-config -y && \
    apt-get install curl -y && \
    apt-get install git -y && \
    apt-get install protobuf-compiler -y && \
    go get github.com/influxdata/pkg-config

# RUN apt update && \
#     apt install make clang pkg-config protobuf-compiler libprotobuf-dev -y

# Clone repo 
RUN git clone https://github.com/influxdata/influx-cli.git

WORKDIR ./influx-cli

RUN make

# ENTRYPOINT ["bin/linux/influx"]