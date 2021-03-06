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

function readVarAndValidateRegex ()
{
    local varname="${1}"
    local prompt="${2}"
    local regex="${3}"
    local error="${4}"

    if test -z "$error"; then
        local error="${prompt} is invalid"
    fi

    while test -z "${!varname}"; do
        readVar "${varname}" "$prompt"
        if ! echo "${!varname}" | grep -q -E ${regex}; then
            error "$error"
            eval "${varname}=''"
        fi
    done

}

function readVarAndValidateInList ()
{
    local varname="${1}"
    local prompt="${2}"
    local list="${3}"
    local error="${4}"

    if test -z "$error"; then
        local error="${prompt} is unsupported"
    fi

    while test -z "${!varname}"; do
        readVar "${varname}" "$prompt"
        if ! in_list "${!varname}" "$list"; then
            error "$error"
            eval "${varname}=''"
        fi
    done
}

function yesInput ()
{
    local prompt="$1"

    local prompt="yes or no?"
    local regex='^(yes|no)$'
    local error="Please enter yes or no"

    tmpYesNoAnswer=""
    
    readVarAndValidateRegex "tmpYesNoAnswer" "${prompt}" "${regex}" "${error}"

    if [ "$tmpYesNoAnswer" = "yes" ]; then
        local returnValue=0
    else
        local returnValue=1
    fi

    unset tmpYesNoAnswer
    return $returnValue
}
