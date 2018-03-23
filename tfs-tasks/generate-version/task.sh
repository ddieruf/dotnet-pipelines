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

#######################################
#       Run Task
#######################################
export VERSION_ROOT="${ARTIFACT_ROOT}/${SRC_VERSION_RESOURCE}"
export ARTIFACT_FOLDER_PATH=${ROOT_FOLDER}
#GIT_EMAIL
#GIT_NAME
source "${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}/tasks/generate-version/run.sh"

echo "New version number: ${NEW_VERSION_NUMBER}"

echo "##vso[task.setvariable variable=MY_OUTPUT_VAR;isSecret=false;isOutput=true;]12345"

#######################################
#       Finalize task
#######################################
