=====================================================
Corelight Software Sensor Docker Bundle Documentation
=====================================================

.. note::

  The Cron process is not running inside the container.  The included cron scripts should be run from the Docker host.

Currently, this container uses shell scripts to allow the softsensor to pull dynamic content.  In a future state, some or all of that functionality will move to Zeek scripts.


This repository contains a prototype of the Software Sensor running in a Docker container.  The usecase is the prototype, not the software sensor, it is GA.

Overview
========

--------------------------------------------------------
What's included (see change-log.rst for version details)
--------------------------------------------------------
* Corelight Software Sensor
* Zeek Package Manager
* Corelight-Suricata
* Suricata-update

Installing Docker
=================

A script to install Docker on Debian or RHEL based systems is included in another Corelight repo.  To run the script without the need to download it first, execute the following command:

.. code-block:: shell

  source <( curl https://raw.githubusercontent.com/corelight/ansible-awx-docker-bundle/devel/docker-install.sh)

Setting up the container
==========================

--------------------------
Container Capabilities
--------------------------
The Docker container will need additional capabilities to properly run the software sensor.

The following are recommended:

* ``drop All`` capabilities
* ``add NET_ADMIN`` (Perform various network-related operations)
* ``add NET_RAW`` (Use RAW and PACKET sockets; bind to any address for transparent proxying)
* ``add SYS_NICE`` (set real-time scheduling policies, CPU affinity, I/O scheduling, etc.)

----------------------------
Container Network Access
----------------------------
The software sensor will need direct access to a physical interface for capturing packets.  The current recommendation is to use the host network.

---------------------
Container Restart
---------------------
To ensure the container restarts in the event of an error.  The restart mode should be set to one of the following:

* ``unless-stopped``
* ``always``

-----------------------------
Container Storage/Volumes
-----------------------------
Container images are designed to be read-only and ephemeral so volumes are used to preserve storage between container starts and stops.  To simplify volume access from outside the container, named volumes or bind volumes can be used.  The default setup lets Docker manage the volumes.

The following paths within the container should be protected with a volume:

* ``/var/corelight``
* ``/etc/corelight``
* ``/var/logs/suricata``
* ``/usr/local/etc/suricata``
* ``/etc/suricata``
* ``/var/lib/suricata``

Configuring the Sensor
==========================

The sensor is configured with environment variables which currently require the following three files:

* corelight-license.txt
* corelight-softsensor.conf
* vars.env (to be removed in a future version)

--------------------------------------
Sensor License (corelight-license.txt)
--------------------------------------

* Contains a single line with the license string
* Read from the environment variable 'CORELIGHT_LICENSE'.

  * To simplify the process, source the provided script "set_config" on the Docker host from the same directory the license and config are located.

* Ignored by .gitignore

-----------------------------------------
Sensor Config (corelight-softsensor.conf)
-----------------------------------------

* The entire contents are read from the single environment variable 'CORELIGHT_SOFTSENSOR_CONF'.

  * To simplify the process, source the provided script "set_config" on the Docker host from the same directory the license and config are located.

* The corelight-softsensor.conf file only needs to have settings that deviate from the default settings.  All others can be commented out or removed.
* Ignored by .gitignore

-----------------------------------------------------
Setup Dynamic Features (in corelight-softsensor.conf)
-----------------------------------------------------
Dynamic features are features that periodically pull from local or remote sources to update content in the container.

When the container first starts, if the dynamic content is enabled (see below) and is missing, the entry point script will reach out and pull the content.  The frequency of each pull after the initial should be either hourly or weekly, depending on how frequently the source might get updated.  In all cases, if the content at the source has not changed since the last pull, nothing will change in the container.

Configuring the content on the source host for each feature is outside the scope of this document.  However, it could be as simple as adding the content to a locally reachable web server and exposing the directory via a URL.

Cron job scripts have been provided that can be run directly on the Docker host to perform the following tasks on an hourly or weekly basis.

Setup the Input Framework
-------------------------------
The Input Framework script will download all the files at the configured URL and place them in the input_files folder.

To enable the Input Framework script to automatically check for new files, and download them on an hourly basis, add the following variables to the environment variable file:

.. code-block:: shell

   Corelight::input_files_update_enabled  T
   Corelight::input_files_url

Setup the Intel Framework
-------------------------------
The Intel Framework script will download all the files at the configured URL, place them in the intel_files folder, and enable them in the local.zeek.  If a new file has been added to the source that was not downloaded when the sensor started, the container will need to be restarted before the new intel file will be enabled.

To enable the Intel Framework script to automatically check for new files, and download them on an hourly basis, add the following variables to the environment variable file:

.. code-block:: shell

   Corelight::intel_files_update_enabled T
   Corelight::input_files_url

Setup the GeoIP Database
------------------------------
The GeoIP script will download the ``GeoLite2-City.mmdb`` database from the configured URL.  There are two options for downloading the database:

* directly from Maxmind.com
* from local URL

Anyone can go to maxmind.com and create an account to generate a free license.  If you are going to download directly from maxmind.com, you will need the following variables defined in the environment file:

.. code-block:: shell

   Corelight::geoip_update_enabled T
   Corelight::geoip_source maxmind
   Corelight::geoip_maxming_key

To enable the GeoIP script to download the ``GeoLite2-City.mmdb`` from a local source (UNCOMPRESSED), add the following variables in the environment file:

.. code-block:: shell

   Corelight::geoip_update_enabled T
   Corelight::geoip_source local
   Corelight::geoip_local_url

Configure Suricata-update
-------------------------------
Suricata-update in this container has been pre-configured to download rulesets from a local source (based on the running version of suricata) that have already processed by Suricata-update on another host (i.e. suricata-update host).  The ony requirement is to provide the URL in the following format:

.. code-block:: shell

   Corelight::suricata_ruleset_source http://update-host/suricata-rulesets/%(__version__)s/suricata.rules

Alternately, Suricata-update can be configured to run stand-a-lone and pull from an Internet source.  Just change the ``suricata_ruleset_source`` URL to point to an Internet source.

The corelight-softsensor.conf file does not provide the ability to configure other suricata-update settings, including pulling from multiple sources.  However, Suricata-update can be manually configured by editing the update.yaml.j2 template included in this image.

NOTE: Future versions of this image may not contain the full suricata-update service and only the ability to download a new ruleset and apply it!

-------------------------------------
Configure Corelight/Zeek Packages
-------------------------------------
To enable the Zeek packages, include the following in the vars.env file (edit as appropriate):

.. code-block:: shell

    CORELIGHT_PACKAGES="
    DOH
    BeaconFinder
    cert-hygiene
    encrypted_dns_sni
    ConnViz
    generic-icmp-tunnel
    generic_dns_tunnel
    http-c2
    MeterpreterDetection
    specific-dns-tunnels
    specific-icmp-tunnels
    ssh-inference
    SteppingStones"

   INCLUDED_PACKAGES="
    zeek-long-connections
    log-add-vlan-everywhere
    bro-is-darknet
    bro-simple-scan
    hassh
    ja3
    credit-card-exposure
    ssn-exposure
    unknown-mime-type-discovery"

   OS_PACKAGES="
    icannTLD"
