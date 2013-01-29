#!/bin/bash
#
# Copyright (C) 2013 FOSS Group
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
# This script writes a welcome banner to the /etc/issue file which will be
# displayed by the getty process on the terminals.
#

LIB_DIR="$(dirname $(readlink -f $0))/../../share/foss-cloud/lib/bash"
CONFIG_DIR="$(dirname $(readlink -f $0))/../../../etc/foss-cloud"

source "${LIB_DIR}/input-output.lib.sh"

CAT_CMD=${CAT_CMD:="/bin/cat"}
GREP_CMD=${GREP_CMD:="/bin/grep"}
IP_CMD=${IP_CMD:="/sbin/ip"}

dev='eth0'
issueFile="/etc/issue"

echo > ${issueFile}
repeatCharacter '*' '80' >> ${issueFile}

echo >> ${issueFile}
fossCloudLogoWithProgramInfo "" "" "yes" >> ${issueFile}


if [ "`getFossCloudNodeType`" = "demo" ]; then
    inet="`${IP_CMD} addr show dev $dev 2>/dev/null | ${GREP_CMD} -m 1 inet`"

    if test $? -ne 0; then
        ${CAT_CMD} << EOF >> ${issueFile}

                    Network device '${dev}' has no IP address.
                  Make sure you have a cable connected to ${dev}
                         Afterwards reboot the system
EOF
  
    else
        ipAddress=`echo $inet | ${GREP_CMD} -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'`

        # strip trailing slash
        ipAddress=${ipAddress%/}

        ${CAT_CMD} << EOF >> ${issueFile}

                         Direct your web browser to:
                       --->  http://${ipAddress} <---
                         user: admin password: admin
EOF
    fi

    ${CAT_CMD} << EOF >> ${issueFile}

                             Console/SSH-Login
                        user: root password: admin
EOF
else
    ${CAT_CMD} << EOF >> ${issueFile}

             Console/SSH-Login is possible with the user 'root'
           and the password you have set during the installation.
EOF
fi

${CAT_CMD} << EOF >> ${issueFile}

                 Documentation: http://wiki.foss-cloud.org

EOF

repeatCharacter '*' '80' >> ${issueFile}
echo -e "\n" >> ${issueFile}
echo 'This is \n.\O (\s \m \r) \t' >> ${issueFile}
echo >> ${issueFile}

exit 0
