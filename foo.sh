#!/usr/bin/env bash

echo "======================================================="
echo "${VAGRANT_PROVISION_USER}"
echo "======================================================="
useradd "${VAGRANT_PROVISION_USER}" -g vagrant --no-create-home
