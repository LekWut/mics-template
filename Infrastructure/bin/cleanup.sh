#!/bin/bash
# Delete all Homework Projects
#if [ "$#" -ne 1 ]; then
#    echo "Usage:"
#    echo "  $0 GUID"
#    exit 1
#fi

GUID=$1
echo "Removing all Projects for GUID=$GUID"
oc delete project $GUID-mics-tools
oc delete project $GUID-dev
oc delete project $GUID-test
oc delete project $GUID-prod