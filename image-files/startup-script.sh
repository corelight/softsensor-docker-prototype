#!/bin/bash

echo '##################################################'
echo 'Build environment variables for shell scripts'
echo '##################################################'
echo 'source /root/export'
source /root/export

echo '##################################################'
echo 'Building /etc/suricata/update.yaml'
echo '##################################################'
$(which j2) -f env -o /etc/suricata/update.yaml /root/update.yaml.j2
echo 'cat /etc/suricata/update.yaml'
cat /etc/suricata/update.yaml

echo '##################################################'
echo 'Collecting GeoIP database if missing and enabled'
echo '##################################################'
if [[ ! -e /usr/share/GeoIP/GeoLite2-City.mmdb && ${GEOIP_UPDATE_ENABLED} = "T" ]]; then
  /root/geoip.sh
echo 'ls -la /usr/share/GeoIP'
  ls -la /usr/share/GeoIP; fi

echo '##################################################'
echo 'Setting zkg config'
echo '##################################################'
if [ ! -e /root/.zkg/config ]; then mv /root/zkg-config.cfg /root/.zkg/config; fi
if [ ! -e /etc/corelight/packages ]; then $(which zkg) refresh; fi
echo 'cat /root/.zkg/config'
cat /root/.zkg/config
echo '--------------------------------------------------'
echo 'ls -la /etc/corelight/packages'
ls -la /etc/corelight/packages

echo '##################################################'
echo 'Running suricata-update if no rules exist'
echo '##################################################'
if [ ! -e /etc/corelight/rules/suricata.rules ]; then $(which suricata-update) update -v; fi
echo 'ls -la /etc/corelight/rules'
ls -la /etc/corelight/rules

echo '##################################################'
echo 'Collecting input_files if missing'
echo '##################################################'
if [[ ${INPUT_FILES_UPDATE_ENABLED} = "T" ]]; then
  /root/input_files.sh
  echo 'ls -la /etc/corelight/input_files/'
  ls -la /etc/corelight/input_files/; fi

echo '##################################################'
echo 'Collecting intel_files if missing'
echo '##################################################'
if [[ ${INTEL_FILES_UPDATE_ENABLED} = "T" ]]; then
  /root/intel_files.sh
  echo 'ls -la /etc/corelight/intel_files/'
  ls -la /etc/corelight/intel_files/; fi

echo '##################################################'
echo 'Building /etc/corelight/local.zeek'
echo '##################################################'
/root/local.zeek.sh
echo 'cat /etc/corelight/local.zeek'
cat /etc/corelight/local.zeek

echo '##################################################'
echo 'Starting Corelight-softsensor'
echo '##################################################
'echo '##################################################'
exec $(which corelight-softsensor) start
