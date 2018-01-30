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
#ARTIFACTORY_HOST
#ARTIFACTORY_TOKEN
#ARTIFACTORY_REPO_ID
#APP_INTEGRATION_TEST_DLL_NAME
export INTEGRATION_TEST_ARTIFACT_NAME="${INTEGRATION_TEST_ARTIFACT_NAME}"
source "${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}/tasks/integration-test/run.sh"

#######################################
#       Finalize task
#######################################