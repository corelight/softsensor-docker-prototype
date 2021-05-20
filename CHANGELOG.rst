=====================================================
Corelight Software Sensor Docker Bundle Change Log
=====================================================

Change Log
=============

--------------------
Release v0.2
--------------------

* Corelight Software Sensor v1.3.4
* Zeek Package Manager v2.7.0
* Corelight-Suricata v5.0.3
* Suricata-update v1.2.1
* The shell script to build the sensor config from environment variables has be replaced by loading the corelight-softsensor.conf as an environment variable.
* The sensor license is read from the environment variable 'CORELIGHT_LICENSE'.
* The sensor config is read from the environment variable 'CORELIGHT_SOFTSENSOR_CONF'.

  * The corelight-softsensor.conf file only needs to have settings that deviate from the default settings.  All others can be commented out or removed.
  * To simplify the process of setting the license and config environment variable, run the provided script "set_config.sh" on the Docker host from the same directory the license and config are located.
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
