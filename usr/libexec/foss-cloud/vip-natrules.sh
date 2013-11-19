#!/bin/bash
#
# Copyright (C) 2013 FOSS-Group
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

# This script adds or removes the required NAT rules for VIP address to
# RIP address translations.
# For example 192.0.2.10:123 -> 192.0.2.11:123
#
# It should be called by a cluster ressource manager.
#
# The mappings are service based, and can be configured within the related
# configuration file.
# 
# Usage: vip-natrules.sh service action


LIB_DIR="`dirname $0`/../../share/foss-cloud/lib/bash"
CONFIG_DIR="`dirname $0`/../../../etc/foss-cloud"

source ${CONFIG_DIR}/vip-natrules.conf
source ${LIB_DIR}/vip-natrules.lib.sh

doNatRulesManagement "$1" "$2"
