# Download directly from Maxmind.com
if [[ ${GEOIP_ENABLED} = "true" && ${GEOIP_SOURCE} = "maxmind" ]]; then
  if [ ! -e /usr/share/GeoIP/GeoLite2-City.mmdb ]; then
    echo "No current GeoIP database, downloading new one"
    if curl --fail --output /tmp/GeoLite2-City.tar.gz.tmp "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${GEOIP_MAXMIND_KEY}&suffix=tar.gz" ; then
      mv /tmp/GeoLite2-City.tar.gz{.tmp,}
    else
      rm /tmp/GeoLite2-City.tar.gz.tmp
    fi
    tar -xzf /tmp/GeoLite2-City.tar.gz --directory /tmp
    mv /tmp/GeoLite2-City_*/GeoLite2-City.mmdb /usr/share/GeoIP/GeoLite2-City.mmdb
    rm -rf /tmp/GeoLite2-City*
  else
    # Check the `last-modified` header for the files build date or check `content-disposition` header for the date that would appear in the file name.
    local_date="$(ls -l --time-style=+"%Y-%m-%d" "/usr/share/GeoIP/GeoLite2-City.mmdb"| cut -d ' ' -f 6)"
    remote_last_modified="$(curl -I "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${GEOIP_MAXMIND_KEY}&suffix=tar.gz" | grep -i "last-modified:" | awk '{print $3,$4,$5}' )"
    remote_year=${remote_last_modified:7:4}
    remote_month_name=${remote_last_modified:3:3}
    remote_month=$(echo $remote_month_name | sed 's/Jan/01/;s/Feb/02/;s/Mar/03/;s/Apr/04/;s/May/05/;s/Jun/06/;s/Aug/08/;s/Sep/09/;s/Oct/10/;s/Nov/11/;s/Dec/12/')
    remote_day=${remote_last_modified:0:2}
    remote_date=${remote_year}-${remote_month}-${remote_day}

    if [[  $remote_date > $local_date ]] ; then
      echo "Downloading new GeoIP database"
      if curl --fail --output /tmp/GeoLite2-City.tar.gz.tmp "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${GEOIP_MAXMIND_KEY}&suffix=tar.gz" ; then
        mv /tmp/GeoLite2-City.tar.gz{.tmp,}
      else
        echo "Download failed"
        rm /tmp/GeoLite2-City.tar.gz.tmp
      fi
      tar -xzf /tmp/GeoLite2-City.tar.gz --directory /tmp
      mv /tmp/GeoLite2-City_*/GeoLite2-City.mmdb /usr/share/GeoIP/GeoLite2-City.mmdb
      rm -rf /tmp/GeoLite2-City*
    else
      echo "Latest GeoIP database already in use"
    fi
  fi
fi

# Download from a local source
if [[ ${GEOIP_ENABLED} = "true" && ${GEOIP_SOURCE} = "local" ]]; then
  if [ ! -e /usr/share/GeoIP/GeoLite2-City.mmdb ]; then
    echo "Downloading new GeoIP database"
    if curl --fail --output /usr/share/GeoIP/GeoLite2-City.mmdb.tmp ${GEOIP_URL} ; then
      mv /usr/share/GeoIP/GeoLite2-City.mmdb{.tmp,}
    else
      rm /usr/share/GeoIP/GeoLite2-City.mmdb.tmp
    fi
  else
    # Check the `last-modified` header for the files build date
    local_date="$(ls -l --time-style=+"%Y-%m-%d" "/usr/share/GeoIP/GeoLite2-City.mmdb"| cut -d ' ' -f 6)"
    remote_last_modified="$(curl -I "${GEOIP_URL}" | grep -i "last-modified:" | awk '{print $3,$4,$5}' )"
    remote_year=${remote_last_modified:7:4}
    remote_month_name=${remote_last_modified:3:3}
    remote_month=$(echo $remote_month_name | sed 's/Jan/01/;s/Feb/02/;s/Mar/03/;s/Apr/04/;s/May/05/;s/Jun/06/;s/Aug/08/;s/Sep/09/;s/Oct/10/;s/Nov/11/;s/Dec/12/')
    remote_day=${remote_last_modified:0:2}
    remote_date=${remote_year}-${remote_month}-${remote_day}

    if [[  $remote_date > $local_date ]] ; then
      echo "Downloading new GeoIP database"
      if curl --fail --output /usr/share/GeoIP/GeoLite2-City.mmdb.tmp ${GEOIP_URL} ; then
        mv /usr/share/GeoIP/GeoLite2-City.mmdb{.tmp,}
      else
        rm /usr/share/GeoIP/GeoLite2-City.mmdb.tmp
      fi
    else
      echo "Latest GeoIP database already in use"
    fi
  fi
fi
