=====================================================
Corelight Software Sensor Docker Bundle Documentation
=====================================================

.. note::

   The context for the current build pulls directly from the repo in maestro.  To enable the ability to build the image, create a Personal Access Token, with a minimum of repo read access, in maestro and add it to a .env file in the same folder as the docker-compose.yml file.  See the example.env file.

   * The file should be named ``.env``

Release notes
=============

-------------------
Initial release
-------------------

Overview
========

-------------------
What's included
-------------------
* Corelight Software Sensor v1.3.4
* Zeek Package Manager v2.7.0
* Corelight-Suricata v5.0.3
* Suricata-update v1.1.0

Set up the container
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

--------------------
Environment File
--------------------
All of the configuration settings within the container are passed in with environment variables.  The variables can be added directly to the compose file, however, an environment file is recommended.

The format of the environment file is a list key=value pairs.  When using an environment file, all of the values are passed into the container exactly as they are written.  If the value is in double quotes in the .env file, it will be passed in with the double quotes.

Only variables that contain multiple entries (like CORELIGHT_PACKAGES) and string values that could be misinterpreted as boolean should be in double quotes.  See the attached ``example_vars.env`` file.

Configure the Bundle Components
===============================

--------------------------------------
License the Corelight-softsensor
--------------------------------------
Once you have your Corelight-softsensor license, it should be added to the ``vars.env`` files with the following variable:

.. code-block:: shell

   CORELIGHT_LICENSE=

--------------------------------------
Configure the Corelight-softsensor
--------------------------------------
All corelight-softsensor.conf settings can be changed from their defaults in the environment file.  With the exception of ``Corelight::sniff``, enter them in all caps and replace the separators with underscores.

``Corelight::ignore_bpf`` becomes

.. code-block:: shell

   CORELIGHT_IGNORE_BPF=

``Corelight::sniff``, it is split into

.. code-block:: shell

   CORELIGHT_SNIFF_INTERFACES=
   CORELIGHT_WORKERS=

-------------------------------------
Configure Corelight/Zeek Packages
-------------------------------------
To enable the Zeek packages, include the following in the environment file (edit as appropriate):

.. code-block:: shell

   CORELIGHT_PACKAGES="
    ssh-inference
    ConnViz
    cert-hygiene"

   INCLUDED_PACKAGES="
    bro-long-connections
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


--------------------------
Setup Dynamic Features
--------------------------
Dynamic features are features that periodically pull from local or remote sources to update content in the container.

When the container first starts, if the dynamic content is enabled (see below) and is missing, the entry point script will reach out and pull the content.  The frequency of each pull after the initial is either hourly or weekly, depending on how frequently the source might get updated.  In all cases, if the content at the source has not changed since the last pull, nothing will change in the container.

Configuring the content on the source host for each feature is outside the scope of this document.  However, it could be as simple as adding the content to a locally reachable web server and exposing the directory via a URL.

Configure the Cron Job Windows
-------------------------------------
In an environment with very few sensors, having each container check for updates at exactly the same time is generally not an issue.  However, in environments with hundreds or thousands of sensors, if each container checks at exactly the same time, it could be a burden on the source providing the content.

To reduce the load on the source, the cron jobs are configured to start randomly within the configured window, at the beginning of the cron period.  For example, the instead of the hourly cron job kicking off at 1:00, it could start at 1:13.

The default window is 1800 seconds (30 minutes).  To change the random window size for all jobs, add the following variable in seconds to the environment file:

.. code-block:: shell

   CRON_SLEEP=

Setup the Input Framework
-------------------------------
The Input Framework script will download all the files at the configured URL and place them in the input_files folder.

To enable the Input Framework script to automatically check for new files, and download them on an hourly basis, add the following variables to the environment variable file:

.. code-block:: shell

   INPUT_FILES_ENABLED="true"
   INPUT_FILES_URL=

Setup the Intel Framework
-------------------------------
The Intel Framework script will download all the files at the configured URL, place them in the intel_files folder, and enable them in the local.zeek.  If a new file has been added to the source that was not downloaded when the sensor started, the container will need to be restarted before the new intel file will be enabled.

To enable the Intel Framework script to automatically check for new files, and download them on an hourly basis, add the following variables to the environment variable file:

.. code-block:: shell

   INTEL_FILES_ENABLED="true"
   INTEL_FILES_URL=

Setup the GeoIP Database
------------------------------
The GeoIP script will download the ``GeoLite2-City.mmdb`` database from the configured URL.  There are two options for downloading the database:

* directly from Maxmind.com
* from local URL

Anyone can go to maxmind.com and create an account to generate a free license.  If you are going to download directly from maxmind.com, you will need the following variables defined in the environment file:

.. code-block:: shell

   GEOIP_ENABLED="true"
   GEOIP_SOURCE=maxmind
   GEOIP_MAXMIND_KEY=

To enable the GeoIP script to download the ``GeoLite2-City.mmdb`` from a local source (UNCOMPRESSED), add the following variables in the environment file:

.. code-block:: shell

   GEOIP_ENABLED="true"
   GEOIP_SOURCE=local
   GEOIP_LOCAL_URL=

Configure Suricata-update
-------------------------------
Suricata-update in this container has been pre-configured to download rulesets from a local source (based on the running version of suricata) that have already processed by Suricata-update on another host (i.e. suricata-update host).  The ony requirement is to provide the URL in the following format:

.. code-block:: shell

   UPDATE_SOURCE=http://my-web-server/suricata-rulesets/%(__version__)s/suricata.rules

Alternately, Suricata-update can be configured to run stand-a-lone and pull from an Internet source.  Just change the ``UPDATE_SOURCE`` URL to point to an Internet source.

The environment file does not provide the ability to configure other settings, including pulling from multiple sources.  However, Suricata-update can be configured via bind mounts to access the appropriate configuration files.

Here is a list of all the relevant Suricata-update files and their locations:

* ``/etc/suricata/update.yaml``
* ``/etc/suricata/disable.conf``
* ``/etc/suricata/enable.conf``
* ``/etc/suricata/modify.conf``
