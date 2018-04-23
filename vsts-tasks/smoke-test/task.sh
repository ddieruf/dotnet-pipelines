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
#DOTNET_VERSION
export APP_URL="${STAGE_APP_URLS}"
export TEST_DLL_NAME="${SMOKE_TEST_DLL_NAME}"
export TEST_ARTIFACT_NAME="${SMOKE_TEST_ARTIFACT_NAME}"
source "${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}/tasks/dotnet-test/run.sh"

#######################################
#       Finalize task
#######################################