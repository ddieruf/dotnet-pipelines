#!/bin/bash

set -o errexit
set -o errtrace

ROOT_FOLDER="${SYSTEM_DEFAULTWORKINGDIRECTORY}"
ARTIFACT_ROOT="${SYSTEM_ARTIFACTSDIRECTORY}"
PIPELINE_RESOURCE="dotnet-pipelines"
TASK_SCRIPTS_RESOURCE="${PIPELINE_RESOURCE}/scripts"
SRC_AND_TEST_RESOURCE="src-and-test"

#######################################
#       Initialize Task
#######################################
while IFS='=' read -r name value ; do
    if [[ "${name}" == *'SMOKE_TEST_ARTIFACT_NAME' ]]; then
       export TEST_ARTIFACT_NAME="${value}"
    fi
    if [[ "${name}" == *'STAGE_APP_URLS' ]]; then
       export APP_URL="${value}"
    fi
done < <(env)

#######################################
#       Run Task
#######################################
#ARTIFACTORY_HOST
#ARTIFACTORY_TOKEN
#ARTIFACTORY_REPO_ID
#DOTNET_VERSION
export TEST_DLL_NAME="${SMOKE_TEST_DLL_NAME}"
export ARTIFACT_FOLDER_PATH="${ARTIFACT_ROOT}"

source "${ARTIFACT_ROOT}/${TASK_SCRIPTS_RESOURCE}/tasks/dotnet-test/run.sh"

#######################################
#       Finalize task
#######################################