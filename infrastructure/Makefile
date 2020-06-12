V ?= @

PROJECT_DIR := $(shell pwd)
IPV4_ADDR := $(shell ip route get 8.8.8.8 | grep src | sed 's/.*src \(.*\) uid.*/\1/g')

DOCKER_APT_CACHE_CONTAINER_NAME := "pumpos-apt-cache"
DOCKER_APT_CACHE_IMAGE_NAME := "pumpos:apt-cache"
DOCKER_APT_CACHE_INSTANCE_NAME := "pumpos-apt-cache-instance"
DOCKER_PIU_MESA_CONTAINER_NAME := "pumpos-piu-mesa"
DOCKER_PIU_MESA_IMAGE_NAME := "pumpos:piu-mesa"

all: \
usage

.PHONY: \
usage \
build-apt-cache \
start-apt-cache \
stop-apt-cache \
logs-apt-cache

usage:
	$(V)echo "Make file to run various infrastructure related commands for pumpos"
	$(V)echo "  build-apt-cache: Build the apt-cache docker container to allow caching of apt packages when installing pumpos multiple times which speeds up installation a lot"
	$(V)echo "  start-apt-cache: Start the apt-cache docker container locally to make it available for pumpos installation"
	$(V)echo "  stop-apt-cache: Stop the apt-cache docker container"
	$(V)echo "  logs-apt-cache: Show the logs of the running apt-cache container"

build-apt-cache:
	$(V)docker rm -f $(DOCKER_APT_CACHE_CONTAINER_NAME) 2> /dev/null || true
	$(V)docker build -t $(DOCKER_APT_CACHE_IMAGE_NAME) -f apt-cache/Dockerfile .
	$(V)docker create --name $(DOCKER_APT_CACHE_CONTAINER_NAME) $(DOCKER_APT_CACHE_IMAGE_NAME)
	$(V)echo "Run 'mkdir -p /var/cache/apt-cache-ng' if the folder doesn't exist on your hostmachine, yet"

start-apt-cache:
	$(V)docker run --name $(DOCKER_APT_CACHE_INSTANCE_NAME) -d -p 3142:3142 $(DOCKER_APT_CACHE_IMAGE_NAME)
	$(V)echo "Use the following address when configuring an apt host for pumpos installation: http://$(IPV4_ADDR):3142"

stop-apt-cache:
	$(V)docker stop $(DOCKER_APT_CACHE_INSTANCE_NAME)
	$(V)docker rm -f $(DOCKER_APT_CACHE_INSTANCE_NAME)

logs-apt-cache:
	$(V)docker logs -f $(DOCKER_APT_CACHE_INSTANCE_NAME)

build-piu-mesa:
	$(V)docker rm -f $(DOCKER_PIU_MESA_CONTAINER_NAME) 2> /dev/null || true
	$(V)docker build -t $(DOCKER_PIU_MESA_IMAGE_NAME) -f piu-mesa/Dockerfile .
	$(V)docker create --name $(DOCKER_PIU_MESA_CONTAINER_NAME) $(DOCKER_PIU_MESA_IMAGE_NAME)