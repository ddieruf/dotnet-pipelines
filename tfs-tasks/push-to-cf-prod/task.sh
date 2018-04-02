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
export APP_NAME="${CF_PROD_APP_NAME}"
export CF_USERNAME="${CF_PROD_USERNAME}"
export CF_PASSWORD="${1}"
export CF_ORG="${CF_PROD_ORG}"
export CF_SPACE="${CF_PROD_SPACE}"
export CF_API_URL="${CF_PROD_API_URL}"
export ARTIFACT_FOLDER_PATH="${ARTIFACT_ROOT}/${SRC_AND_TEST_RESOURCE}"
export ENVIRONMENT_NAME="prod"

pushd "${ARTIFACT_FOLDER_PATH}"
    export SRC_ARTIFACT_NAME=$(find . ! -name '*Tests*')
popd

source "${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}/tasks/push-to-cf/run.sh"

echo "##vso[task.setvariable variable=PROD_APP_ROUTE;isSecret=false;isOutput=true;]${APP_ROUTE}"
echo "##vso[task.setvariable variable=PROD_APP_URLS;isSecret=false;isOutput=true;]${APP_URLS}"

#######################################
#       Finalize task
#######################################