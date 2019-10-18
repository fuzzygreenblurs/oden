#!/usr/bin/env bash

# set -o errexit
# set -o pipefail

# Write a short BASH script that:
    # DONE: Accepts a host as a first argument
    # DONE: Pings the host once
        # DONE: If the host responds : print "OK" to the screen and return 0 to shell
        # DONE: If the host times out: print "ERROR" to the screen, pause for 1 second and try again
            # DONE: Repeat upto 5 times
            # DONE: If the host has not responded after 5 attempts, print “FAIL” and return 1 to the shell

    # While the script is running, write its current PID to /tmp/ping-test.pid
    # Delete /tmp/ping-test.pid once the script is complete
    # Do not allow the script to run if it is already running

# REF: https://bencane.com/2015/09/22/preventing-duplicate-cron-job-executions/

# we can use the PID file to lock the script until it is completed
PIDFILE=/tmp/ping-test.pid
echo $$
echo $(cat $PIDFILE)
if [[ -f ${PIDFILE} ]] ; then
    # read pid from PIDFILE
    PID=$(cat $PIDFILE)

    # check if this process is still running
    ps -p $PID > /dev/null 2>&1
    if [[ $? -eq 0 ]] ; then
        echo "this job is currently already running."
        exit 1
    fi
else
    echo $$ > ${PIDFILE}
    if [[ $? -ne 0 ]] ; then
        echo "could not create pid file."
        exit 1
    fi
fi

((tries = 0))
while [[ ${tries} -ne 5 ]] ; do
    ping -c 1 ${1}
    if [[ $? -eq 0 ]]; then
        echo "OK"
        exit 0
    else
        ((tries++))
        echo "The ping has failed ${tries} times"
        sleep 1
    fi
done

echo "FAIL"
exit 1

