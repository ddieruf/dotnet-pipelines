#!/bin/bash

set -o errexit
set -o errtrace

ROOT_FOLDER="${SYSTEM_DEFAULTWORKINGDIRECTORY}"
ARTIFACT_ROOT="${SYSTEM_ARTIFACTSDIRECTORY}"
PIPELINE_RESOURCE="dotnet-pipelines/drop"
TASK_SCRIPTS_RESOURCE="${PIPELINE_RESOURCE}/scripts"
SRC_VERSION_RESOURCE="src-and-test"

#######################################
#       Initialize Task
#######################################
source "${ROOT_FOLDER}/${PIPELINE_RESOURCE}/functions/init-task.sh"

#######################################
#       Run Task
#######################################
export VERSION_ROOT="${ARTIFACT_ROOT}/${SRC_AND_TEST_RESOURCE}"
#GIT_EMAIL
#GIT_NAME
source "${ARTIFACT_ROOT}/${TASK_SCRIPTS_RESOURCE}/tasks/generate-version/run.sh"

echo "New version number: ${NEW_VERSION_NUMBER}"

echo "##vso[task.setvariable variable=NEW_VERSION_NUMBER;isSecret=false;isOutput=true;]${NEW_VERSION_NUMBER}"

#######################################
#       Finalize task
#######################################
source "${ROOT_FOLDER}/${PIPELINE_RESOURCE}/functions/finish-task.sh"
