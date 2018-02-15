#!/bin/bash

set -o errexit
set -o errtrace

ROOT_FOLDER="$( pwd )"
SRC_AND_TEST_RESOURCE=src-and-test
PIPELINE_RESOURCE=dotnet-pipelines
TASK_SCRIPTS_RESOURCE="${PIPELINE_RESOURCE}/scripts"
CONCOURSE_TASKS_RESOURCE="${PIPELINE_RESOURCE}/concourse-tasks"
KEYVAL_RESOURCE=keyval
KEYVALOUTPUT_RESOURCE=keyvalout
OUTPUT_RESOURCE=out

#######################################
#       Initialize Task
#######################################
source "${ROOT_FOLDER}/${CONCOURSE_TASKS_RESOURCE}/functions/init-task.sh"

#######################################
#       Begin task
#######################################
#ARTIFACTORY_HOST
#ARTIFACTORY_TOKEN
#ARTIFACTORY_REPO_ID
#DOTNET_VERSION
export APP_SRC_CSPROJ_PATH="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/${SRC_CSPROJ_LOCATION_IN_SOLUTION}"
export APP_UNIT_TEST_CSPROJ_PATH="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/${UNIT_TEST_CSPROJ_LOCATION_IN_SOLUTION}"
export APP_INTEGRATION_TEST_CSPROJ_PATH="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/${INTEGRATION_TEST_CSPROJ_LOCATION_IN_SOLUTION}"
export APP_SMOKE_TEST_CSPROJ_PATH="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/${SMOKE_TEST_CSPROJ_LOCATION_IN_SOLUTION}"
export CF_STAGE_MANIFEST_PATH="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/${CF_STAGE_MANIFEST_LOCATION}"
export CF_PROD_MANIFEST_PATH="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/${CF_PROD_MANIFEST_LOCATION}"
export ARTILLERY_MANIFEST_PATH="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/${ARTILLERY_MANIFEST_LOCATION}"
export PIPELINE_VERSION="${PASSED_PIPELINE_VERSION}"

source "${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}/tasks/build-and-upload/run.sh"

export PASSED_SRC_ARTIFACT_NAME="${SRC_ARTIFACT_NAME}"
export PASSED_UNIT_TEST_ARTIFACT_NAME="${UNIT_TEST_ARTIFACT_NAME}"
export PASSED_INTEGRATION_TEST_ARTIFACT_NAME="${INTEGRATION_TEST_ARTIFACT_NAME}"
export PASSED_SMOKE_TEST_ARTIFACT_NAME="${SMOKE_TEST_ARTIFACT_NAME}"

#add tag to repo
TAG="build/${PIPELINE_VERSION}"
echo "Tagging the project with build tag [${TAG}]"
echo "${TAG}" > "${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}/tag"
cp -r "${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}"/. "${ROOT_FOLDER}/${OUTPUT_RESOURCE}/"

#######################################
#       Finalize task
#######################################
source "${ROOT_FOLDER}/${CONCOURSE_TASKS_RESOURCE}/functions/finish-task.sh"