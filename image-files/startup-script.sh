#!/bin/bash

echo 'Building corelight-softsensor.conf'
$(which j2) -f env -o /etc/corelight-softsensor.conf /root/corelight-softsensor.conf.j2
echo /etc/corelight-softsensor.conf

echo 'Building /etc/suricata/update.yaml'
$(which j2) -f env -o /etc/suricata/update.yaml /root/update.yaml.j2
cat /etc/suricata/update.yaml

echo 'Collecting GeoIP database if missing and enabled'
if [[ ! -e /usr/share/GeoIP/GeoLite2-City.mmdb && ${GEOIP_ENABLED} = "true" ]]; then /root/geoip.sh; fi
ls -la /usr/share/GeoIP

echo 'Setting zkg config'
if [ ! -e /root/.zkg/config ]; then mv /root/zkg-config.cfg /root/.zkg/config; fi
if [ ! -e /etc/corelight/packages ]; then $(which zkg) refresh; fi
cat /root/.zkg/config
ls -la /etc/corelight/packages

echo 'Running suricata-update if no rules exist'
if [ ! -e /etc/corelight/rules/suricata.rules ]; then $(which suricata-update) update -v; fi
ls -la /etc/corelight/rules

echo 'Collecting input_files if missing'
/root/input_files.sh
ls -la /etc/corelight/input_files/

echo 'Collecting intel_files if missing'
/root/intel_files.sh
ls -la /etc/corelight/intel_files/

echo 'Building /etc/corelight/local.zeek'
/root/local.zeek.sh
cat /etc/corelight/local.zeek

echo 'Starting Corelight-softsensor'
exec $(which corelight-softsensor) start
