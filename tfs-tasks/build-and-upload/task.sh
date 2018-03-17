#!/bin/bash

set -o errexit
set -o errtrace

ROOT_FOLDER="${AGENT_RELEASEDIRECTORY}"
TASK_SCRIPTS_RESOURCE="task-scripts"
SRC_AND_TEST_RESOURCE="src-and-test"

#######################################
#       Initialize Task
#######################################

#######################################
#       Begin task
#######################################
#DOTNET_VERSION
export APP_SRC_CSPROJ_PATH="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/${APP_SRC_CSPROJ_PATH}"
export APP_UNIT_TEST_CSPROJ_PATH="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/${APP_UNIT_TEST_CSPROJ_PATH}"
export APP_INTEGRATION_TEST_CSPROJ_PATH="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/${APP_INTEGRATION_TEST_CSPROJ_PATH}"
export APP_SMOKE_TEST_CSPROJ_PATH="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/${APP_SMOKE_TEST_CSPROJ_PATH}"
export CF_MANIFEST_PATH="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/${CF_MANIFEST_PATH}"
export ARTILLERY_MANIFEST_PATH="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/${ARTILLERY_MANIFEST_PATH}"
export PIPELINE_VERSION="${PIPELINE_VERSION}"

export ARTIFACT_FOLDER_PATH="${BUILD_ARTIFACTSTAGINGDIRECTORY}"

source "${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}/tasks/build-and-upload/run.sh"

export SRC_ARTIFACT_NAME="${SRC_ARTIFACT_NAME}"
export UNIT_TEST_ARTIFACT_NAME="${UNIT_TEST_ARTIFACT_NAME}"
export INTEGRATION_TEST_ARTIFACT_NAME="${INTEGRATION_TEST_ARTIFACT_NAME}"
export SMOKE_TEST_ARTIFACT_NAME="${SMOKE_TEST_ARTIFACT_NAME}"

#add tag to repo
TAG="build/${PIPELINE_VERSION}"
echo "Tagging the project with build tag [${TAG}]"
echo "${TAG}" > "${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/tag"
#cp -r "${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}"/. "${ROOT_FOLDER}/${OUTPUT_RESOURCE}/"

#######################################
#       Finalize task
#######################################