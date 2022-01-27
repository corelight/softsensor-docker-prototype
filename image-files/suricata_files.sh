#!/bin/bash

# Only downloads files if they don't exists or have been updated
if [ ${INTEL_FILES_ENABLED} = "true" ]; then
  if [ ! -e /etc/corelight/rules ]; then mkdir /etc/corelight/rules; fi
  cd /etc/corelight/rules
  curl -O ${SURICATA_FILES_URL}
fi
