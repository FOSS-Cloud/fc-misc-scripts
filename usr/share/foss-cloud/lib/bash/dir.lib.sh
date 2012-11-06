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


RM_CMD=${RM_CMD:="/bin/rm"}
CP_CMD=${CP_CMD:="/bin/cp"}

LIB_DIR=${LIB_DIR:="`dirname $0`"}

source "${LIB_DIR}/input-output.lib.sh"



function removeDirectoryContent ()
{
    local directory="$1"

    info "Removing content of $directory"
    if ! $RM_CMD -rf ${directory}/*; then
        error "Unable to remove the content of ${directory}"
        die
    fi
}

function copyDirectoryContent ()
{
    local sourceDir="$1"
    local destinationDir="$2"

    info "Copy directory content of ${sourceDir} to ${destinationDir}"

    if ! $CP_CMD -rp "${sourceDir}"/* "${destinationDir}"; then
        error "Unable to copy the content of ${sourceDir} to ${destinationDir}"
        die
    fi
}
