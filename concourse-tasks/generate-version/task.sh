#!/bin/bash

set -o errexit
set -o errtrace

ROOT_FOLDER="$( pwd )"
TASK_SCRIPTS_RESOURCE=task-scripts
CONCOURSE_TASKS_RESOURCE=concourse-tasks
SRC_VERSION_RESOURCE=src-version
KEYVAL_RESOURCE=keyval
KEYVALOUTPUT_RESOURCE=keyvalout
UPDATE_VERSION_OUTPUT_RESOURCE=updated-version

#######################################
#       Initialize Task
#######################################
source "${ROOT_FOLDER}/${CONCOURSE_TASKS_RESOURCE}/functions/init-task.sh"

#######################################
#       Run Task
#######################################
#initialize the output for the keyval store
mkdir -p "${UPDATE_VERSION_OUTPUT_RESOURCE}"
export VERSION_ROOT="${ROOT_FOLDER}/${SRC_VERSION_RESOURCE}"
#GIT_EMAIL
#GIT_NAME
source "${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}/tasks/generate-version/run.sh"
cp -r "${SRC_VERSION_RESOURCE}/." "${UPDATE_VERSION_OUTPUT_RESOURCE}"

echo "New version number: ${NEW_VERSION_NUMBER}"

#add the new version number to keyval store
export PASSED_PIPELINE_VERSION="${NEW_VERSION_NUMBER}"

#######################################
#       Finalize task
#######################################
source "${ROOT_FOLDER}/${CONCOURSE_TASKS_RESOURCE}/functions/finish-task.sh"