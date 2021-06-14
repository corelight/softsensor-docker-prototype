#!/bin/bash

#Build environment variables for shell scripts
export INPUT_FILES_UPDATE_ENABLED=`echo "$CORELIGHT_SOFTSENSOR_CONF" | sed -n -e 's/^Corelight::input_files_update_enabled[[:space:]]*//p'`
export INPUT_FILES_URL=`echo "$CORELIGHT_SOFTSENSOR_CONF" | sed -n -e 's/^Corelight::input_files_url[[:space:]]*//p'`
export INTEL_FILES_UPDATE_ENABLED=`echo "$CORELIGHT_SOFTSENSOR_CONF" | sed -n -e 's/^Corelight::intel_files_update_enabled[[:space:]]*//p'`
export INTEL_FILES_URL=`echo "$CORELIGHT_SOFTSENSOR_CONF" | sed -n -e 's/^Corelight::intel_files_url[[:space:]]*//p'`
export GEOIP_UPDATE_ENABLED=`echo "$CORELIGHT_SOFTSENSOR_CONF" | sed -n -e 's/^Corelight::geoip_update_enabled[[:space:]]*//p'`
export GEOIP_SOURCE=`echo "$CORELIGHT_SOFTSENSOR_CONF" | sed -n -e 's/^Corelight::geoip_source[[:space:]]*//p'`
export GEOIP_MAXMIND_KEY=`echo "$CORELIGHT_SOFTSENSOR_CONF" | sed -n -e 's/^Corelight::geoip_maxmind_key[[:space:]]*//p'`
export GEOIP_URL=`echo "$CORELIGHT_SOFTSENSOR_CONF" | sed -n -e 's/^Corelight::geoip_local_url[[:space:]]*//p'`
export SURICATA_RULESET_SOURCE=`echo "$CORELIGHT_SOFTSENSOR_CONF" | sed -n -e 's/^Corelight::suricata_ruleset_source[[:space:]]*//p'`

echo 'Building /etc/suricata/update.yaml'
$(which j2) -f env -o /etc/suricata/update.yaml /root/update.yaml.j2
cat /etc/suricata/update.yaml

echo 'Collecting GeoIP database if missing and enabled'
if [[ ! -e /usr/share/GeoIP/GeoLite2-City.mmdb && ${GEOIP_UPDATE_ENABLED} = "T" ]]; then
  /root/geoip.sh
  ls -la /usr/share/GeoIP; fi

echo 'Setting zkg config'
if [ ! -e /root/.zkg/config ]; then mv /root/zkg-config.cfg /root/.zkg/config; fi
if [ ! -e /etc/corelight/packages ]; then $(which zkg) refresh; fi
cat /root/.zkg/config
ls -la /etc/corelight/packages

echo 'Running suricata-update if no rules exist'
if [ ! -e /etc/corelight/rules/suricata.rules ]; then $(which suricata-update) update -v; fi
ls -la /etc/corelight/rules

echo 'Collecting input_files if missing'
if [[ ${INPUT_FILES_UPDATE_ENABLED} = "T" ]]; then
  /root/input_files.sh
  ls -la /etc/corelight/input_files/; fi

echo 'Collecting intel_files if missing'
if [[ ${INTEL_FILES_UPDATE_ENABLED} = "T" ]]; then
  /root/intel_files.sh
  ls -la /etc/corelight/intel_files/; fi

echo 'Building /etc/corelight/local.zeek'
/root/local.zeek.sh
cat /etc/corelight/local.zeek

echo 'Starting Corelight-softsensor'
exec $(which corelight-softsensor) start
