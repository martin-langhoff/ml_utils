#!/bin/sh -xe

# This script starts docker and systemd (if el7)

# Version of CentOS/RHEL
el_version="$1"
appname='iso-system'

 # Run tests in Container
if [ "$el_version" = "6" ]; then
    sudo docker run --rm=true -v "$(pwd):/${appname}:rw" "centos:centos${OS_VERSION}" \
        /bin/bash -c "bash -xe /${appname}/tests/tests_inside_docker.sh ${OS_VERSION}"
elif [ "$el_version" = "7" ]; then
    docker run --privileged -d -ti -e "container=docker"  \
        -v /sys/fs/cgroup:/sys/fs/cgroup -v "$(pwd):/${appname}:rw " "centos:centos${OS_VERSION}" \
        /usr/sbin/init
    DOCKER_CONTAINER_ID=$(docker ps | grep centos | awk '{print $1}')
    docker logs "$DOCKER_CONTAINER_ID"
docker exec -ti "$DOCKER_CONTAINER_ID" \
    /bin/bash -xec "bash -xe /${appname}/tests/tests_inside_docker.sh ${OS_VERSION};
    echo -ne \"------\nEND ${appname} TESTS\n\";"
    docker ps -a
    docker stop "$DOCKER_CONTAINER_ID"
    docker rm -v "$DOCKER_CONTAINER_ID"
fi
