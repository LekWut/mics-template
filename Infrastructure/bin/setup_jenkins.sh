#!/bin/bash
# Setup Jenkins Project
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID REPO CLUSTER"
    echo "  Example: $0 wkha https://github.com/wkulhanek/ParksMap na39.openshift.opentlc.com"
    exit 1
fi

GUID=$1
#REPO=$2
#CLUSTER=$3
echo "Setting up Jenkins in project ${GUID}-tools"

# Code to set up the Jenkins project to execute the
# three pipelines.
# This will need to also build the custom Maven Slave Pod
# Image to be used in the pipelines.
# Finally the script needs to create three OpenShift Build
# Configurations in the Jenkins Project to build the
# three micro services. Expected name of the build configs:
# * mlbparks-pipeline
# * nationalparks-pipeline
# * parksmap-pipeline
# The build configurations need to have two environment variables to be passed to the Pipeline:
# * GUID: the GUID used in all the projects
# * CLUSTER: the base url of the cluster used (e.g. na39.openshift.opentlc.com)

# To be Implemented by Student
oc new-app jenkins-persistent --param ENABLE_OAUTH=true --param MEMORY_LIMIT=8Gi --param VOLUME_CAPACITY=4Gi --param DISABLE_ADMINISTRATIVE_MONITORS=true -n ${GUID}-jenkins
oc rollout pause dc jenkins   -n ${GUID}-tools
oc set resources dc jenkins   --limits=memory=4Gi,cpu=2 --requests=memory=2Gi,cpu=1 -n ${GUID}-jenkins
oc rollout resume dc jenkins  -n ${GUID}-tools
oc new-build  -D $'FROM docker.io/openshift/jenkins-agent-maven-35-centos7:v3.11\n
      USER root\nRUN yum -y install skopeo && yum clean all\n
      USER 1001' --name=jenkins-agent-appdev -n ${GUID}-tools
      
echo "apiVersion: v1
items:
- kind: "BuildConfig"
  apiVersion: "v1"
  metadata:
    name: "product-serive-pipeline"
  spec:
    source:
      type: "Git"
      git:
        uri: https://gitlab.yipintsoi.com/akkarawu/myboutique-productservice.git
    strategy:
      type: "JenkinsPipeline"
      jenkinsPipelineStrategy:
        jenkinsfilePath: Jenkinsfile
kind: List
metadata: []" | oc create -f - -n ${GUID}-tools

#oc set env bc/mlbparks-pipeline GUID=${GUID} REPO=${REPO} CLUSTER=${CLUSTER} -n ${GUID}-jenkins
#oc set env bc/nationalparks-pipeline GUID=${GUID} REPO=${REPO} CLUSTER=${CLUSTER} -n ${GUID}-jenkins
#oc set env bc/parksmap-pipeline GUID=${GUID} REPO=${REPO} CLUSTER=${CLUSTER} -n ${GUID}-jenkins

while : ; do
   echo "Checking if jenkins-agent-appdev is Ready..."
   oc get pod -n ${GUID}-tools|grep '\jenkins-agent-appdev\-'|grep "Completed"
   [[ "$?" == "1" ]] || break
   echo "$?" == "1"
   echo "...no. Sleeping 10 seconds."
   sleep 10
 done