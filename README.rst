=====================================================
Corelight Software Sensor Docker Bundle Documentation
=====================================================

Overview
========

--------------------------------------------------------
What's included (see change-log.rst for version details)
--------------------------------------------------------
* Corelight Software Sensor
* Zeek Package Manager
* Corelight-update (optionally)

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
* ``/etc/corelight-softsensor.conf``
* ``/etc/corelight-license.txt``
* ``/etc/corelight-update``
* ``/var/corelight-update``

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

-------------------------------------
Configure Zeek Packages
-------------------------------------
To enable the Zeek packages, include the following in the vars.env file (edit as appropriate):

.. code-block:: shell


   OS_PACKAGES="
    icannTLD"
