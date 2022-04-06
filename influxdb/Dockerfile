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
RUN git clone https://github.com/influxdata/influxdb.git

RUN curl https://sh.rustup.rs -sSf | bash -s -- --default-toolchain "1.53" -y

WORKDIR ./influxdb

ENV PATH=/root/.cargo/bin:${PATH}

RUN make

ENTRYPOINT ["bin/linux/influxd"]