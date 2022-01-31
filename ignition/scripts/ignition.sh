#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

eval "$(jq -r '@sh "INSTALLER_WORKSPACE=\(.installer_workspace)"')"

master_ignition="{}"
test -e ${INSTALLER_WORKSPACE}/master.ign && {
  master_ignition=$(cat ${INSTALLER_WORKSPACE}/master.ign)
}
bootstrap_ignition_file="${INSTALLER_WORKSPACE}/bootstrap.ign"


jq -n \
  --arg bootstrap_ignition_file "$bootstrap_ignition_file" \
  --arg master_ignition "$master_ignition" \
  '{"bootstrap_ignition_file":$bootstrap_ignition_file, "master_ignition":$master_ignition}'