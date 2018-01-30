#!/bin/bash

set -o errexit
set -o errtrace

ROOT_FOLDER="$( pwd )"
TASK_SCRIPTS_RESOURCE=task-scripts
CONCOURSE_TASKS_RESOURCE=concourse-tasks
KEYVAL_RESOURCE=keyval
KEYVALOUTPUT_RESOURCE=keyvalout

#######################################
#       Initialize Task
#######################################

#######################################
#       Run Task
#######################################
#We are initializing the properties file to be used throughout the pipeline
propsFile="${ROOT_FOLDER}/${KEYVAL_RESOURCE}/keyval.properties"
touch "${propsFile}"

#initialize the output for the keyval store
mkdir -p "${ROOT_FOLDER}/${KEYVALOUTPUT_RESOURCE}"

#need to source the utils to run the finalize task
source "${ROOT_FOLDER}/${CONCOURSE_TASKS_RESOURCE}/functions/resource-util.sh"

#######################################
#       Finalize task
#######################################
source "${ROOT_FOLDER}/${CONCOURSE_TASKS_RESOURCE}/functions/finish-task.sh"