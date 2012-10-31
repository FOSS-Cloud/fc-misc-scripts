#!/bin/bash
#
# Copyright (C) 2012 FOSS Group
#                    Germany
#                    http://www.foss-group.de
#                    support@foss-group.de
#
# Authors:
#  Christian Affolter <christian.affolter@stepping-stone.ch>
#  
# Licensed under the EUPL, Version 1.1 or – as soon they
# will be approved by the European Commission - subsequent
# versions of the EUPL (the "Licence");
# You may not use this work except in compliance with the
# Licence.
# You may obtain a copy of the Licence at:
#
# http://www.osor.eu/eupl
#
# Unless required by applicable law or agreed to in
# writing, software distributed under the Licence is
# distributed on an "AS IS" basis,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied.
# See the Licence for the specific language governing
# permissions and limitations under the Licence.
#
# 
#


PS_CMD=${PS_CMD:="/bin/ps"}
PIDOF_CMD=${PIDOF_CMD:="/bin/pidof"}
KILLALL_CMD=${KILLALL_CMD:="/usr/bin/killall"}
SLEEP_CMD=${SLEEP_CMD:="/usr/bin/sleep"}

PROCESSCONROL_INIT_DIR=${PROCESSCONROL_INIT_DIR:="/etc/init.d"}
PROCESSCONROL_SERVICE_STOP_SLEEP=${PROCESSCONROL_SERVICE_STOP_SLEEP:="2s"}


function processControlStopService () 
{
    local serviceName="$1"
    local processName="$2"

    # defaults to service name
    if test -z $processName; then
        local processName="$serviceName"
    fi

    if processControlIsServiceStarted "$serviceName"; then
        ${PROCESSCONROL_INIT_DIR}/${serviceName} stop 
    else
       debug "Service $serviceName was not running"
    fi

    if processControlIsProcessRunning "$processName"; then
        debug "Process $processName is still running, sending SIGTERM"
        ${KILLALL_CMD} --signal SIGTERM "$processName"
    fi

    if processControlIsProcessRunning "$processName"; then
        # wait before killing
        ${SLEEP_CMD} ${PROCESSCONROL_SERVICE_STOP_SLEEP}

        if processControlIsProcessRunning "$processName"; then
            debug "Process $processName is still running, sending SIGKILL"
            ${KILLALL_CMD} --signal SIGKILL "$processName"
	fi

        if processControlIsProcessRunning "$processName"; then
            # unable to stop service :(
	    return 1
	fi
    fi

    # service successfully stopped
    return 0
}

function processControlStartService () 
{
    local serviceName="$1"

    ${PROCESSCONROL_INIT_DIR}/${serviceName} start
    return $?
}


# Returns zero if the service is started
function processControlIsServiceStarted ()
{
    local serviceName="$1"
 
    ${PROCESSCONROL_INIT_DIR}/${serviceName} status > /dev/null
    return $?
}

# Returns zero if at least on process with the given name is running
function processControlIsProcessRunning ()
{
    local processName="$1"

    $PIDOF_CMD "$processName" > /dev/null
    return $?
}
