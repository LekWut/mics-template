#!/bin/bash
# Setup Nexus Project
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Nexus in project $GUID-nexus"

# Code to set up the Nexus. It will need to
# * Create Nexus
# * Set the right options for the Nexus Deployment Config
# * Load Nexus with the right repos
# * Configure Nexus as a docker registry
# Hint: Make sure to wait until Nexus if fully up and running
#       before configuring nexus with repositories.
#       You could use the following code:
# while : ; do
#   echo "Checking if Nexus is Ready..."
#   oc get pod -n ${GUID}-nexus|grep '\-2\-'|grep -v deploy|grep "1/1"
#   [[ "$?" == "1" ]] || break
#   echo "...no. Sleeping 10 seconds."
#   sleep 10
# done

# Ideally just calls a template
# oc new-app -f ../templates/nexus.yaml --param .....

# To be Implemented by Student
oc project ${GUID}-nexus
oc new-app -f ./Infrastructure/templates/nexus.yaml --param NEXUS_LIMIT_MEMORY=2Gi --param NEXUS_LIMIT_CPU="2" --param NEXUS_REQUEST_MEMORY=1Gi --param NEXUS_REQUEST_CPU=500m --param NEXUS_PERSISTENT_VOLUME_CLAIM_SIZE=4Gi -n ${GUID}-nexus
 while : ; do
   echo "Checking if Nexus is Ready..."
   oc get pod -n ${GUID}-nexus|grep '\-1\-'|grep -v deploy|grep "1/1"
   [[ "$?" == "1" ]] || break
   echo "$?" == "1"
   echo "...no. Sleeping 10 seconds."
   sleep 10
 done

curl -o setup_nexus3.sh -s https://raw.githubusercontent.com/redhat-gpte-devopsautomation/ocp_advanced_development_resources/master/nexus/setup_nexus3.sh
chmod +x setup_nexus3.sh
./setup_nexus3.sh admin admin123 http://$(oc get route nexus3 --template='{{ .spec.host }}')
rm -f -r setup_nexus3.sh