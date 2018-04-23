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
#       Run Task
#######################################
export SCRIPTS_ROOT="${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}"
export SRC_AND_TEST_ROOT="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}"
export PIPELINE_VERSION="${PIPELINE_VERSION}"
export SONAR_SCANNER_MSBUILD_VERSION="4.0.2.892"
export SONAR_SCANNER_VERSION="3.0.3.778"
export SONAR_TIMEOUT_SECONDS=240

#DOTNET_VERSION
#SONAR_PROJECT_KEY
#SONAR_PROJECT_NAME
#SONAR_HOST
#SONAR_LOGIN_KEY

source "${SCRIPTS_ROOT}/tasks/scan-code-quality/run.sh"

#######################################
#       Finalize task
#######################################