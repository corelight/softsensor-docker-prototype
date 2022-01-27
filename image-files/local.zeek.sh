#!/bin/bash
echo "# Load Open Source Packages" > /etc/corelight/local.zeek
echo @load /etc/corelight/packages >> /etc/corelight/local.zeek

if [[ ! -z $OS_PACKAGES ]]; then
  echo "Installing Open Source Packages"
  for package in $OS_PACKAGES; do
    echo "installing $package"
    zkg install --force --skiptests $package
  done
fi
