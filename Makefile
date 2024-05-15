
# Default flags
# MAKEFLAGS := -r -R
# MAKEFLAGS += -s

# Use one shell to process entire recipe
.ONESHELL:

MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURR_DIR := $(notdir $(patsubst %/,%,$(dir $(MAKEFILE_PATH))))
ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))


INSTALL_DIR  ?= /usr/share/cmake-mx




uninstall:
	sudo rm -rf ${INSTALL_DIR}


install: uninstall
	sudo mkdir -p ${INSTALL_DIR}
	sudo cp -R cmake ${INSTALL_DIR}/


link: uninstall
	sudo ln -s $(dir $(MAKEFILE_PATH)) ${INSTALL_DIR}

