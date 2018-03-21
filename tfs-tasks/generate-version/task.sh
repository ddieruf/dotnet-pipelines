#!/bin/bash

set -o errexit
set -o errtrace

ROOT_FOLDER="${AGENT_WORKFOLDER}"
ARTIFACT_ROOT="${SYSTEM_ARTIFACTSDIRECTORY}"
PIPELINE_RESOURCE="dotnet-pipelines"
TASK_SCRIPTS_RESOURCE="${PIPELINE_RESOURCE}/scripts"
SRC_VERSION_RESOURCE="src-and-test"

#######################################
#       Initialize Task
#######################################

#######################################
#       Run Task
#######################################
export VERSION_ROOT="${ARTIFACT_ROOT}/${SRC_VERSION_RESOURCE}"
#GIT_EMAIL
#GIT_NAME
source "${ARTIFACT_ROOT}/${TASK_SCRIPTS_RESOURCE}/tasks/generate-version/run.sh"

echo "New version number: ${NEW_VERSION_NUMBER}"

echo "##vso[task.setvariable variable=VERSION_NUM]${NEW_VERSION_NUMBER}"
echo "Saved version: ${VERSION_NUM}"
#######################################
#       Finalize task
#######################################
