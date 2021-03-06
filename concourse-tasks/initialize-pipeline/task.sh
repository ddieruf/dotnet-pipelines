#!/bin/bash

set -o errexit
set -o errtrace

ROOT_FOLDER="$( pwd )"
PIPELINE_RESOURCE=dotnet-pipelines
TASK_SCRIPTS_RESOURCE="${PIPELINE_RESOURCE}/scripts"
CONCOURSE_TASKS_RESOURCE="${PIPELINE_RESOURCE}/concourse-tasks"
KEYVALOUTPUT_RESOURCE=keyvalout

#######################################
#       Initialize Task
#######################################

#######################################
#       Run Task
#######################################
#initialize the output for the keyval store
mkdir -p "${ROOT_FOLDER}/${KEYVALOUTPUT_RESOURCE}"

#We are initializing the properties file to be used throughout the pipeline
propsFile="${ROOT_FOLDER}/${KEYVALOUTPUT_RESOURCE}/keyval.properties"
touch "${propsFile}"  

#need to source the utils to run the finalize task
source "${ROOT_FOLDER}/${CONCOURSE_TASKS_RESOURCE}/functions/resource-util.sh"

#######################################
#       Finalize task
#######################################
source "${ROOT_FOLDER}/${CONCOURSE_TASKS_RESOURCE}/functions/finish-task.sh"