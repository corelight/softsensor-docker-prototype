#!/bin/bash

echo 'Collecting GeoIP database if missing and enabled'
/root/geoip.sh
ls -la /usr/share/GeoIP

echo 'Setting zkg config'
if [ ! -e /root/.zkg/config ]; then mv /root/zkg-config.cfg /root/.zkg/config; fi
if [ ! -e /etc/corelight/packages ]; then $(which zkg) refresh; fi
cat /root/.zkg/config
ls -la /etc/corelight/packages

echo 'Building /etc/corelight/local.zeek'
/root/local.zeek.sh
cat /etc/corelight/local.zeek

echo 'Collecting Suricata ruleset if no rules exist'
/root/suricata_files.sh
ls -la /etc/corelight/rules

echo 'Collecting input_files if missing'
/root/input_files.sh
ls -la /etc/corelight/input_files/

echo 'Collecting intel_files if missing'
/root/intel_files.sh
ls -la /etc/corelight/intel/

echo 'Starting Corelight-softsensor'
exec /opt/corelight/bin/corelight-softsensor start


# corelight-update & corelight-softsensor start
