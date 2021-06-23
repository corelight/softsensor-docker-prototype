#!/bin/bash
echo "# Load Open Source Packages" > /etc/corelight/local.zeek
echo @load /etc/corelight/packages >> /etc/corelight/local.zeek

echo "" >> /etc/corelight/local.zeek
echo "# Load Corelight Packages" >> /etc/corelight/local.zeek
for package in $CORELIGHT_PACKAGES; do
  echo @load Corelight/$package >> /etc/corelight/local.zeek
done

echo "" >> /etc/corelight/local.zeek
echo "# Load Pre-bundled Packages" >> /etc/corelight/local.zeek
for package in $INCLUDED_PACKAGES; do
  echo @load packages/$package >> /etc/corelight/local.zeek
done

if [[ ! -z $OS_PACKAGES ]]; then
  echo "Installing Open Source Packages"
  for package in $OS_PACKAGES; do
    echo "installing $package"
    zkg install --force --skiptests $package
  done
fi

if [[ ${INTEL_FILES_UPDATE_ENABLED} == "T" ]]; then
  echo "" >> /etc/corelight/local.zeek
  echo "# Load Intel files" >> /etc/corelight/local.zeek
  echo @load frameworks/intel/do_notice >> /etc/corelight/local.zeek
  echo @load frameworks/intel/seen >> /etc/corelight/local.zeek
  echo "" >> /etc/corelight/local.zeek
  echo 'redef Intel::read_files += {' >> /etc/corelight/local.zeek
  for file in $(find /etc/corelight/intel_files -type f); do
    filename=$(basename $file)
    echo '        "'"$filename"'",' >> /etc/corelight/local.zeek
  done
  echo '};' >> /etc/corelight/local.zeek
fi
