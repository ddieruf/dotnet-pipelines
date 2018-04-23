#!/bin/bash

set -o errexit
set -o errtrace

ROOT_FOLDER="${AGENT_RELEASEDIRECTORY}"
TASK_SCRIPTS_RESOURCE="task-scripts"

#######################################
#       Initialize Task
#######################################

#######################################
#       Run Task
#######################################
export APP_URL="${LOAD_TEST_APP_URL}"
#ARTILLERY_ENVIRONMENT
#ARTIFACTORY_HOST
#ARTIFACTORY_TOKEN
#ARTIFACTORY_REPO_ID
export SRC_ARTIFACT_NAME="${SRC_ARTIFACT_NAME}"

source "${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}/tasks/load-test/run.sh"

#######################################
#       Finalize task
#######################################