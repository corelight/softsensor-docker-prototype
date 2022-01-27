#!/bin/bash

# Only downloads files if they don't exists or have been updated
if [ ${INTEL_FILES_ENABLED} = "true" ]; then
  if [ ! -e /etc/corelight/intel ]; then mkdir /etc/corelight/intel; fi
  cd /etc/corelight/intel
  curl -O ${INTEL_FILES_URL}
fi
