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
# https://joinup.ec.europa.eu/software/page/eupl
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


LIB_DIR=${LIB_DIR:="`dirname $0`"}

source "${LIB_DIR}/input-output.lib.sh"
source "${LIB_DIR}/process-control.lib.sh"


function stopAllServices
{
    local servicesToStop="$1"

    header "Stopping Services"

    local service=""

    for service in $servicesToStop; do
        if ! processControlStopService "$service"; then
            error "Unable to stop the ${service} service"
            die
        fi
    done
}

function startAllServices
{
    local servicesToStart="$1"

    header "Starting Services"

    local service=""

    for service in $servicesToStart; do
        if ! processControlStartService "$service"; then
            error "Unable to start the ${service} service"
            die
        fi
    done
}
