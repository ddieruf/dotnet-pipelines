#!/bin/bash

set -o errexit
set -o errtrace

ROOT_FOLDER="${SYSTEM_ARTIFACTSDIRECTORY}"
PIPELINE_RESOURCE="dotnet-pipelines"
TASK_SCRIPTS_RESOURCE="${PIPELINE_RESOURCE}/scripts"
SRC_VERSION_RESOURCE="src-and-test"

#######################################
#       Initialize Task
#######################################

#######################################
#       Run Task
#######################################
export VERSION_ROOT="${ROOT_FOLDER}/${SRC_VERSION_RESOURCE}"
#GIT_EMAIL
#GIT_NAME
source "${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}/tasks/generate-version/run.sh"

echo "New version number: ${NEW_VERSION_NUMBER}"

echo "##vso[task.setvariable variable=MySecret;isSecret=true]My secret value"
echo "My secret: ${MySecret}"
exit 1

#######################################
#       Finalize task
#######################################
