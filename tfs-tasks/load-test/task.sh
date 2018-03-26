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
while IFS='=' read -r name value ; do
    if [[ "${name}" == *'STAGE_APP_URLS' ]]; then
       export APP_URL="${value}"
    fi
done < <(env)

#######################################
#       Run Task
#######################################
#ARTIFACT_LOCATION_TYPE
#ARTIFACTORY_HOST
#ARTIFACTORY_TOKEN
#ARTIFACTORY_REPO_ID
#DOTNET_VERSION

export TEST_DLL_NAME="${SMOKE_TEST_DLL_NAME}"
export ARTIFACT_FOLDER_PATH="${ARTIFACT_ROOT}/${SRC_AND_TEST_RESOURCE}"

pushd "${ARTIFACT_FOLDER_PATH}"
    export SRC_ARTIFACT_NAME=$(find . ! -name '*Tests*')
popd

source "${ARTIFACT_ROOT}/${TASK_SCRIPTS_RESOURCE}/tasks/load-test/run.sh"

#######################################
#       Finalize task
#######################################
