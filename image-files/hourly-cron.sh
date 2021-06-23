#!/bin/bash

# generate random sleep less than 30 minutes
random_wait()
{
    RandomSleep=${CRON_SLEEP:-1800}
    TIME=$(($RANDOM % $RandomSleep))
    sleep $TIME
}

# delay the job execution by a random amount of time
random_sleep

# Hourly jobs
docker exec softsensor-bundle suricata-update update -v
docker exec softsensor-bundle /root/input_files.sh
docker exec softsensor-bundle /root/intel_files.sh
