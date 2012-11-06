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


IPTABLES_CMD=${IPTABLES_CMD:="/sbin/iptables"}

# append a rule into a given chain, if it's not already present
# netfilterAppendRuleIfNotPresent "test_chain" "-s 10.1.1.1 -j test_chain2"
function netfilterAppendRuleIfNotPresent() {
    local chain=$1
    local rule=$2
    local table=$3

    if [ "$table" == "" ]; then
        local table="filter"
    fi

    # Check if the rule is already present
    # Note that the appending whitespace befor the line ending is intentional
    # as the iptables -S output appends it.
    # This might change with further iptable versions :(
    # ^-A $chain $rule $"
    #                ^^^
    if ! $IPTABLES_CMD -t $table -S $chain | grep -q -E -- "^-A $chain $rule $";
    then
        debug "[netfilter] Appending rule '$rule' to chain '$chain' of table '$table'"
        $IPTABLES_CMD -t $table -A $chain $rule
        return $?
    fi
        debug "[netfilter] Rule '$rule' from chain '$chain' of table '$table' already present, won't append."

    return 0
}

# remove a rule from a given chain, if it's present
# netfilterRemoveRuleIfPresent "test_chain" "-s 10.1.1.1 -j test_chain2"
function netfilterRemoveRuleIfPresent() {
    local chain=$1
    local rule=$2
    local table=$3

    if [ "$table" == "" ]; then
        local table="filter"
    fi

    # Check if the rule is already present
    # Note that the appending whitespace befor the line ending is intentional
    # as the iptables -S output appends it.
    # This might change with further iptable versions :(
    # ^-A $chain $rule $"
    #                ^^^
    if $IPTABLES_CMD -t $table -S $chain | grep -q -E -- "^-A $chain $rule $";
    then
        debug "[netfilter] Removing rule '$rule' from chain '$chain' in table '$table'"
        $IPTABLES_CMD --table $table --delete $chain $rule
        return $?
    fi

    debug "[netfilter] Rule '$rule' not present in chain '$chain' of table '$table', won't remove."

    return 0
}

# checks if a given chain is present/created
# netfilterIsChainPresent "test_chain"
function netfilterIsChainPresent() {
    local chain=$1
    local table="$2"

    if [ "$table" == "" ]; then
        local table="filter"
    fi

    $IPTABLES_CMD --table $table --list $chain --numeric > /dev/null 2>&1
    return $?
}

# Creates a new chain if it's not already present
# netfilterCreateChainIfNotPresent "test_chain"
function netfilterCreateChainIfNotPresent() {
    local chain=$1
    local table="$2"

    if [ "$table" == "" ]; then
        local table="filter"
    fi

    if ! netfilterIsChainPresent "$chain" "$table"; then
        $IPTABLES_CMD --table $table --new-chain $chain
	return $?
    fi

    return 0
}
