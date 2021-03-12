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
$(which suricata-update) update -v
/root/input_files.sh
/root/intel_files.sh
