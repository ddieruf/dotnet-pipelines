#!/bin/bash

set -o errexit
set -o errtrace

ROOT_FOLDER="$( pwd )"
PIPELINE_RESOURCE=dotnet-pipelines
TASK_SCRIPTS_RESOURCE="${PIPELINE_RESOURCE}/scripts"
CONCOURSE_TASKS_RESOURCE="${PIPELINE_RESOURCE}/concourse-tasks"
SRC_VERSION_RESOURCE=src-version
KEYVAL_RESOURCE=keyval
KEYVALOUTPUT_RESOURCE=keyvalout

#######################################
#       Initialize Task
#######################################
source "${ROOT_FOLDER}/${CONCOURSE_TASKS_RESOURCE}/functions/init-task.sh"

#######################################
#       Run Task
#######################################
export VERSION_ROOT="${ROOT_FOLDER}/${SRC_VERSION_RESOURCE}"

source "${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}/tasks/generate-version/run.sh"

echo "New version number: ${NEW_VERSION_NUMBER}"

#add the new version number to keyval store
export PASSED_PIPELINE_VERSION="${NEW_VERSION_NUMBER}"

#######################################
#       Finalize task
#######################################
source "${ROOT_FOLDER}/${CONCOURSE_TASKS_RESOURCE}/functions/finish-task.sh"