#!/bin/bash
# Create all Homework Projects
if [ "$#" -ne 2 ]; then
    echo "Usage:"
    echo "  $0 GUID USER"
    exit 1
fi

GUID=$1
USER=$2
echo "Creating all Homework Projects for GUID=${GUID} and USER=${USER}"
oc new-project ${GUID}-tools    --display-name="${GUID} CICD Tools"
oc new-project ${GUID}-dev  --display-name="${GUID} Development Project"
oc new-project ${GUID}-test  --display-name="${GUID} Test Project"
oc new-project ${GUID}-prod --display-name="${GUID} Production Project"

oc policy add-role-to-user admin ${USER} -n ${GUID}-tools
oc policy add-role-to-user admin ${USER} -n ${GUID}-dev
oc policy add-role-to-user admin ${USER} -n ${GUID}-test
oc policy add-role-to-user admin ${USER} -n ${GUID}-prod

oc annotate namespace ${GUID}-tools      openshift.io/requester=${USER} --overwrite
oc annotate namespace ${GUID}-dev  openshift.io/requester=${USER} --overwrite
oc annotate namespace ${GUID}-test    openshift.io/requester=${USER} --overwrite
oc annotate namespace ${GUID}-prod openshift.io/requester=${USER} --overwrite