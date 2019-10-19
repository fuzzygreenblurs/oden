#!/usr/bin/env bash

# REF: https://bencane.com/2015/09/22/preventing-duplicate-cron-job-executions/

# we can use the PID file to lock the script until it is completed
PIDFILE=/tmp/ping-test.pid

if [[ -f ${PIDFILE} ]] ; then
    PID=$(cat $PIDFILE)
    # if the ps command finds an already running process, it will exit with a 0 exit code
    ps -p ${PID} > /dev/null 2>&1

    # in this case, exit with error code
    if [[ $? -eq 0 ]] ; then
        echo "this job is currently already running."
        exit 1
    else
        # if the ps command doesnt find an already running process, try to create a PID file with the PID
        echo $$ > ${PIDFILE}
        if [[ $? -ne 0 ]] ; then
            echo "could not create pid file."
            exit 1
        fi
    fi
else
    # if the PID file doesnt exist in the first place, then the process must not be running
    # in this case, try to create it and let the script run
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
        rm ${PIDFILE}
        exit 0
    else
        ((tries++))
        echo "The ping has failed ${tries} times"
        sleep 1
    fi
done

echo "FAIL"
rm ${PIDFILE}
exit 1
