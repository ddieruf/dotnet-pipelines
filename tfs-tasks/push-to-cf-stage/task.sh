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
#ARTIFACTORY_HOST
#ARTIFACTORY_TOKEN
#ARTIFACTORY_REPO_ID
export PIPELINE_VERSION="${BUILD_BUILDNUMBER}"
export APP_NAME="${CF_STAGE_APP_NAME}"
export CF_USERNAME="${CF_STAGE_USERNAME}"
export CF_PASSWORD="${CF_STAGE_PASSWORD}"
export CF_ORG="${CF_STAGE_ORG}"
export CF_SPACE="${CF_STAGE_SPACE}"
export CF_API_URL="${CF_STAGE_API_URL}"
export ARTIFACT_FOLDER_PATH="${ARTIFACT_ROOT}/${SRC_AND_TEST_RESOURCE}"

pushd "${ARTIFACT_FOLDER_PATH}"
    export SRC_ARTIFACT_NAME=$(find . ! -name '*Tests*')
popd

source "${ARTIFACT_ROOT}/${TASK_SCRIPTS_RESOURCE}/tasks/push-to-cf-stage/run.sh"

echo "##vso[task.setvariable variable=STAGE_APP_ROUTE;isSecret=false;isOutput=true;]${APP_ROUTE}"
echo "##vso[task.setvariable variable=STAGE_APP_URLS;isSecret=false;isOutput=true;]${APP_URLS}"

#######################################
#       Finalize task
#######################################
