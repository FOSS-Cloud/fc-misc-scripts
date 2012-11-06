#!/bin/bash
#
# Copyright (C) 2012 FOSS-Group
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


LIB_DIR=${LIB_DIR:="`dirname $0`"}

source "${LIB_DIR}/input-output.lib.sh"
source "${LIB_DIR}/netfilter.lib.sh"


function validateInput ()
{
    local service="$1"
    local action="$2"

    if test -z "$service"; then
        error "Missing service name as the first argument"
        die
    elif test -z "${vipAddresses[$service]}"; then
        error "Unknown service name specified"
        info  "See the configuration for supported service names"
        die
    fi


    if test -z "$action"; then
        error "Missing action as the second argument"
        die
    elif [ "$action" != "add" ] && [ "$action" != "remove" ]; then
        error "Unsupported action"
        info  "Either 'add' or 'remove' has to be specified"
        die
    fi
}

function createChains ()
{
    debug "Creating custom $projectName NAT chains"

    if ! netfilterCreateChainIfNotPresent "$customNatPreroutingChain" "nat" ||
       ! netfilterCreateChainIfNotPresent "$customNatOutputChain" "nat";
    then
        error "Unable to create custom chains"
        die
    fi


    debug "Appending custom $projectName NAT chains to parent chains"
    if ! netfilterAppendRuleIfNotPresent "${natPreroutingChain}" \
                                         "-j ${customNatPreroutingChain}" \
                                         "nat";
    then
        error "Unable to append custom pre-route nat chain to parent chain"
        die

    elif ! netfilterAppendRuleIfNotPresent "${natOutputChain}" \
                                           "-j ${customNatOutputChain}" \
                                           "nat";
    then
        error "Unable to append custom output nat chain to parent chain"
        die
    fi
}

function addNatRule ()
{
    local rule="$1"

    # Destination NAT rule for ingress connections
    # VIP_Address:VIP_Port -> RIP_Address:RIP_Port
    # This rule will be added into the PREROUTING chain of the nat table
    if ! netfilterAppendRuleIfNotPresent "${customNatPreroutingChain}" \
                                         "${rule}" "nat";
    then
        error "Unable to add pre-routing NAT rule"

    fi

    # Destination NAT rule for local originating connections
    # VIP_Address:VIP_Port -> RIP_Address:RIP_Port
    # This rule will be added into the OUTPUT chain of the nat table
    if ! netfilterAppendRuleIfNotPresent "${customNatOutputChain}" \
				         "${rule}" "nat"
    then
        error "Unable to add output NAT rule"
    fi
}

function removeNatRule ()
{
    local rule="$1"

    if ! netfilterRemoveRuleIfPresent "${customNatPreroutingChain}" \
                                      "${rule}" "nat";
    then
        error "Unable to remove pre-routing NAT rule"

    fi

    if ! netfilterRemoveRuleIfPresent "${customNatOutputChain}" \
				      "${rule}" "nat"
    then
        error "Unable to remove output NAT rule"
    fi

}

function handleNatRule ()
{
    local service="$1"
    local action="$2"

    local ripAddress="${ripAddresses[$service]}"
    local ripPort="${ripPorts[$service]}"

    local vipAddress="${vipAddresses[$service]}/32"
    local vipPort="${vipPorts[$service]}"

    local protocol=${serviceProtocols[$service]}


    # Destination NAT rule 
    # VIP_Address:VIP_Port -> RIP_Address:RIP_Port
    local rule="-d ${vipAddress} -p ${protocol} -m tcp --dport ${vipPort} -j DNAT --to-destination ${ripAddress}:${ripPort}"


    case $action in
        add)
	    debug "Adding NAT rules for service ${service}"
	    debug "${vipAddress}:${vipPort} -> ${ripAddress}:${ripPort}"
            addNatRule "$rule"

            ;;

        remove)
            debug "Removing NAT rules for service ${service}"
            debug "${vipAddress}:${vipPort} -> ${ripAddress}:${ripPort}"
            removeNatRule "$rule"

            ;;
        *)
            error "Unsupported action"
            info  "either 'add' or 'remove' has to be specified"
            die
    esac

    return $?
}


function doNatRulesManagement ()
{
    validateInput "$1" "$2"
    createChains
    handleNatRule "$1" "$2"
}
