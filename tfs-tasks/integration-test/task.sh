#!/bin/bash

set -o errexit
set -o errtrace

ROOT_FOLDER="${AGENT_WORKFOLDER}"
ARTIFACT_ROOT="${SYSTEM_ARTIFACTSDIRECTORY}"
PIPELINE_RESOURCE="dotnet-pipelines"
TASK_SCRIPTS_RESOURCE="${PIPELINE_RESOURCE}/scripts"

#######################################
#       Initialize Task
#######################################

#######################################
#       Run Task
#######################################
#ARTIFACT_LOCATION_TYPE
#ARTIFACTORY_HOST
#ARTIFACTORY_TOKEN
#ARTIFACTORY_REPO_ID
#ARTIFACT_FOLDER_PATH
#DOTNET_VERSION

export TEST_DLL_NAME="${INTEGRATION_TEST_DLL_NAME}"
export TEST_ARTIFACT_NAME="${INTEGRATION_TEST_ARTIFACT_NAME}"
source "${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}/tasks/dotnet-test/run.sh"

#######################################
#       Finalize task
#######################################