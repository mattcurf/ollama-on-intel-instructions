CURRENT_DIR := $(shell pwd)

ARCH := $(shell uname -m)
ifeq ($(ARCH),arm64)
  ARCH := aarch64
endif

DOCKER_IMAGE_NAME = $(shell basename `pwd`)
DOCKER_ARGS = -it --rm --security-opt seccomp=unconfined -v `pwd`:/project -w /project 

ifeq ($(shell [ -d "/dev/dri" ] && echo yes),yes)
  DOCKER_ARGS += --device /dev/dri:/dev/dri -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$(DISPLAY) -e HAS_GPU=1
  ifeq ($(shell [ -d "/usr/lib/wsl" ] && echo yes),yes)
    DOCKER_ARGS += --device /dev/dxg:/dev/dxg -v /usr/lib/wsl:/usr/lib/wsl
  endif
endif

ifeq ($(shell [ -d "/dev/accel" ] && echo yes),yes)
  DOCKER_ARGS += --device /dev/accel:/dev/accel -e HAS_NPU=1
endif

DOCKER_ARGS += $(DOCKER_IMAGE_NAME)

default: verify 

image:
	@echo "Building Docker image $(DOCKER_IMAGE_NAME)..."
	@docker build . --progress plain -f Dockerfile.$(ARCH) -t $(DOCKER_IMAGE_NAME)

clean:
	@docker rmi $(DOCKER_IMAGE_NAME)

verify: image
	@docker run $(DOCKER_ARGS)

shell: image 
	@docker run --entrypoint /bin/bash $(DOCKER_ARGS)
