#!/bin/bash

# Only downloads files if they don't exists or have been updated
if [ ${INPUT_FILES_UPDATE_ENABLED} = "T" ]; then
  if [ ! -e /etc/corelight/input_files ]; then mkdir /etc/corelight/input_files; fi
  cd /etc/corelight/input_files
  wget -r -np -nd -R html -N ${INPUT_FILES_URL}
  rm /etc/corelight/input_files/index.html*
fi
