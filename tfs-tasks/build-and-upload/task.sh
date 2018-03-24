#!/bin/bash

set -o errexit
set -o errtrace

env

ROOT_FOLDER="${SYSTEM_DEFAULTWORKINGDIRECTORY}"
ARTIFACT_ROOT="${SYSTEM_ARTIFACTSDIRECTORY}"
PIPELINE_RESOURCE="dotnet-pipelines"
TASK_SCRIPTS_RESOURCE="${PIPELINE_RESOURCE}/scripts"
SRC_AND_TEST_RESOURCE="src-and-test"

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
export APP_SRC_CSPROJ_PATH="${ARTIFACT_ROOT}/${SRC_AND_TEST_RESOURCE}/${SRC_CSPROJ_LOCATION_IN_SOLUTION}"
if [[ ! -z "${UNIT_TEST_CSPROJ_LOCATION_IN_SOLUTION}" ]]; then
	export APP_UNIT_TEST_CSPROJ_PATH="${ARTIFACT_ROOT}/${SRC_AND_TEST_RESOURCE}/${UNIT_TEST_CSPROJ_LOCATION_IN_SOLUTION}"
fi
if [[ ! -z "${INTEGRATION_TEST_CSPROJ_LOCATION_IN_SOLUTION}" ]]; then
	export APP_INTEGRATION_TEST_CSPROJ_PATH="${ARTIFACT_ROOT}/${SRC_AND_TEST_RESOURCE}/${INTEGRATION_TEST_CSPROJ_LOCATION_IN_SOLUTION}"
fi
if [[ ! -z "${SMOKE_TEST_CSPROJ_LOCATION_IN_SOLUTION}" ]]; then
	export APP_SMOKE_TEST_CSPROJ_PATH="${ARTIFACT_ROOT}/${SRC_AND_TEST_RESOURCE}/${SMOKE_TEST_CSPROJ_LOCATION_IN_SOLUTION}"
fi
export CF_STAGE_MANIFEST_PATH="${ARTIFACT_ROOT}/${SRC_AND_TEST_RESOURCE}/${CF_STAGE_MANIFEST_LOCATION}"
export CF_PROD_MANIFEST_PATH="${ARTIFACT_ROOT}/${SRC_AND_TEST_RESOURCE}/${CF_PROD_MANIFEST_LOCATION}"
if [[ ! -z "${ARTILLERY_MANIFEST_LOCATION}" ]]; then
	export ARTILLERY_MANIFEST_PATH="${ARTIFACT_ROOT}/${SRC_AND_TEST_RESOURCE}/${ARTILLERY_MANIFEST_LOCATION}"
fi
export ARTIFACT_FOLDER_PATH="${AGENT_TEMPDIRECTORY}"

source "${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}/tasks/build-and-upload/run.sh"

echo "##vso[task.setvariable variable=SRC_ARTIFACT_NAME;isSecret=false;isOutput=true;]${SRC_ARTIFACT_NAME}"
echo "##vso[task.setvariable variable=UNIT_TEST_ARTIFACT_NAME;isSecret=false;isOutput=true;]${UNIT_TEST_ARTIFACT_NAME}"
echo "##vso[task.setvariable variable=INTEGRATION_TEST_ARTIFACT_NAME;isSecret=false;isOutput=true;]${INTEGRATION_TEST_ARTIFACT_NAME}"
echo "##vso[task.setvariable variable=SMOKE_TEST_ARTIFACT_NAME;isSecret=false;isOutput=true;]${SMOKE_TEST_ARTIFACT_NAME}"

#add tag to repo
#TAG="build/${PIPELINE_VERSION}"
#echo "Tagging the project with build tag [${TAG}]"
#echo "${TAG}" > "${ARTIFACT_ROOT}/${SRC_AND_TEST_RESOURCE}/tag"
#cp -r "${ARTIFACT_ROOT}/${SRC_AND_TEST_RESOURCE}"/. "${ROOT_FOLDER}/${OUTPUT_RESOURCE}/"

#######################################
#       Finalize task
#######################################