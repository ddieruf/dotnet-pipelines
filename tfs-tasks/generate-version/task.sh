#!/bin/bash

set -o errexit
set -o errtrace

ROOT_FOLDER="${AGENT_RELEASEDIRECTORY}"
TASK_SCRIPTS_RESOURCE="task-scripts"
SRC_VERSION_RESOURCE="src-version"

#######################################
#       Initialize Task
#######################################

#######################################
#       Run Task
#######################################
export VERSION_ROOT="${ROOT_FOLDER}/${SRC_VERSION_RESOURCE}"
#GIT_EMAIL
#GIT_NAME
source "${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}/tasks/generate-version/run.sh"

echo "New version number: ${NEW_VERSION_NUMBER}"

#save the new version number to a global variable
#TODO!!!!

#######################################
#       Finalize task
#######################################
