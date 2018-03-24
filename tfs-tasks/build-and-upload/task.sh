#!/bin/bash

set -o errexit
set -o errtrace

env

ROOT_FOLDER="${SYSTEM_DEFAULTWORKINGDIRECTORY}"
ARTIFACT_ROOT="${SYSTEM_ARTIFACTSDIRECTORY}"
PIPELINE_RESOURCE="dotnet-pipelines"
TASK_SCRIPTS_RESOURCE="${PIPELINE_RESOURCE}/scripts"
SRC_VERSION_RESOURCE="src-and-test"

#######################################
#       Initialize Task
#######################################
while IFS='=' read -r name value ; do
    if [[ "${name}" == *'NEW_VERSION_NUMBER' ]]; then
       export PIPELINE_VERSION="${value}"
    fi
done < <(env)

#######################################
#       Begin task
#######################################
#DOTNET_VERSION
export APP_SRC_CSPROJ_PATH="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/${APP_SRC_CSPROJ_PATH}"
export APP_UNIT_TEST_CSPROJ_PATH="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/${APP_UNIT_TEST_CSPROJ_PATH}"
export APP_INTEGRATION_TEST_CSPROJ_PATH="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/${APP_INTEGRATION_TEST_CSPROJ_PATH}"
export APP_SMOKE_TEST_CSPROJ_PATH="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/${APP_SMOKE_TEST_CSPROJ_PATH}"
export CF_STAGE_MANIFEST_PATH="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/${CF_STAGE_MANIFEST_LOCATION}"
export CF_PROD_MANIFEST_PATH="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/${CF_PROD_MANIFEST_LOCATION}"
export ARTILLERY_MANIFEST_PATH="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/${ARTILLERY_MANIFEST_PATH}"
export ARTIFACT_FOLDER_PATH="${ROOT_FOLDER}"

source "${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}/tasks/build-and-upload/run.sh"

echo "##vso[task.setvariable variable=SRC_ARTIFACT_NAME;isSecret=false;isOutput=true;]${SRC_ARTIFACT_NAME}"
echo "##vso[task.setvariable variable=UNIT_TEST_ARTIFACT_NAME;isSecret=false;isOutput=true;]${UNIT_TEST_ARTIFACT_NAME}"
echo "##vso[task.setvariable variable=INTEGRATION_TEST_ARTIFACT_NAME;isSecret=false;isOutput=true;]${INTEGRATION_TEST_ARTIFACT_NAME}"
echo "##vso[task.setvariable variable=SMOKE_TEST_ARTIFACT_NAME;isSecret=false;isOutput=true;]${SMOKE_TEST_ARTIFACT_NAME}"

#######################################
#       Finalize task
#######################################