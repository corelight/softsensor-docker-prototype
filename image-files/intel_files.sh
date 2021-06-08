#!/bin/bash

# Only downloads files if they don't exists or have been updated
if [ ${INTEL_FILES_UPDATE_ENABLED} = "T" ]; then
  if [ ! -e /etc/corelight/intel_files ]; then mkdir /etc/corelight/intel_files; fi
  cd /etc/corelight/intel_files
  wget -r -np -nd -R html -N ${INTEL_FILES_URL}
  rm /etc/corelight/intel_files/index.html*
fi
