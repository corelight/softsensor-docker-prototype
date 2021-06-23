=====================================================
Corelight Software Sensor Docker Bundle Change Log
=====================================================

Change Log
=============

--------------------
Release v0.7
--------------------

* Fixed local.zeek.sh

--------------------
Release v0.6
--------------------

* Improved Logging of startup script
* Only export environment variables if they exists in softsensor config
* Moved volume definition to Dockerfile
* Moved network definition to image build

--------------------
Release v0.5
--------------------

* Corelight Software Sensor v1.3.6

* Gracefully handles Zeek package renaming.

--------------------
Release v0.4
--------------------

* Corelight Software Sensor v1.3.5
* Zeek Package Manager v2.9.0
* Corelight-Suricata v5.0.3
* Suricata-update v1.2.2

* The included Zeek package 'bro-long-connections' has been renamed to 'zeek-long-connections'.
* Advanced Suricata support added

--------------------
Release v0.3
--------------------

* The vars.env file is now only used for zeek packages.  The following options have been added to corelight-softsensor.conf:

  * Corelight::input_files_update_enabled   T or F
  * Corelight::input_files_url
  * Corelight::intel_files_update_enabled   T or F
  * Corelight::intel_files_url
  * Corelight::geoip_update_enabled         T or F
  * Corelight::geoip_source                 maxmind or local
  * Corelight::geoip_maxmind_key
  * Corelight::geoip_local_url
  * Corelight::suricata_ruleset_source      http://corelight-update-host/suricata-rulesets/%(__version__)s/suricata.rules

--------------------
Release v0.2
--------------------

* Suricata-update v1.2.1
* The shell script to build the sensor config from environment variables has be replaced by loading the corelight-softsensor.conf as an environment variable.
* The sensor license is read from the environment variable 'CORELIGHT_LICENSE'.
* The sensor config is read from the environment variable 'CORELIGHT_SOFTSENSOR_CONF'.

  * The corelight-softsensor.conf file only needs to have settings that deviate from the default settings.  All others can be commented out or removed.
  * To simplify the process of setting the license and config environment variable, run the provided script "set_config.sh" on the Docker host from the same directory the license and config are located.  The script runs the following commands:

    * export CORELIGHT_SOFTSENSOR_CONF=`cat corelight-softsensor.conf`
    * export CORELIGHT_LICENSE=`cat corelight-license.txt`

  * .gitignore has been updated to ignore 'corelight-license.txt' and 'corelight-softsensor.conf'.

* The cron job scripts have been moved to the Docker host.  Currently, the cron jobs need to be created on the host manually.



--------------------
Initial release v0.1
--------------------

* Corelight Software Sensor v1.3.4
* Zeek Package Manager v2.7.0
* Corelight-Suricata v5.0.3
* Suricata-update v1.1.0
* All of the configuration settings within the container are set in 'vars.env' and passed in as environment variables.

  * The sensor license is set within the vars.env file.
  * The sensor config is set within the vars.env file.
  * The following Packages are set within the vars.env file.

    * Corelight Proprietary Packages
    * Corelight Included Packages
    * Open Source Packages

  * The following dynamic features are set within the vars.env file.

    * Input Files
    * Intel Files
    * GeoIP
    * Suricata Rulesets
