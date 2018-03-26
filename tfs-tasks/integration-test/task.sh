#!/bin/bash

set -o errexit
set -o errtrace

ROOT_FOLDER="${SYSTEM_DEFAULTWORKINGDIRECTORY}"
ARTIFACT_ROOT="${SYSTEM_ARTIFACTSDIRECTORY}"
PIPELINE_RESOURCE="dotnet-pipelines"
TASK_SCRIPTS_RESOURCE="${PIPELINE_RESOURCE}/scripts"
SRC_AND_TEST_RESOURCE="src-and-test/drop"

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
#DOTNET_VERSION

export TEST_DLL_NAME="${INTEGRATION_TEST_DLL_NAME}"
export ARTIFACT_FOLDER_PATH="${ARTIFACT_ROOT}/${SRC_AND_TEST_RESOURCE}"
pushd "${ARTIFACT_FOLDER_PATH}"
    export TEST_ARTIFACT_NAME=$(find . -name '*IntegrationTests*')
popd
echo "Name: ${TEST_ARTIFACT_NAME}"

source "${ARTIFACT_ROOT}/${TASK_SCRIPTS_RESOURCE}/tasks/dotnet-test/run.sh"

#######################################
#       Finalize task
#######################################
