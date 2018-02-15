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

#######################################
#       Initialize Task
#######################################
source "${ROOT_FOLDER}/${CONCOURSE_TASKS_RESOURCE}/functions/init-task.sh"

#######################################
#       Run Task
#######################################
export SCRIPTS_ROOT="${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}"
export SRC_AND_TEST_ROOT="${ROOT_FOLDER}/${SRC_AND_TEST_RESOURCE}"
export PIPELINE_VERSION="${PASSED_PIPELINE_VERSION}"

#DOTNET_VERSION
#SONAR_PROJECT_KEY
#SONAR_PROJECT_NAME
#SONAR_HOST
#SONAR_LOGIN_KEY
#SONAR_SCANNER_VERSION
#SONAR_SCANNER_MSBUILD_VERSION
#DOTNET_FRAMEWORK
#DOTNET_RUNTIME_ID
#SONAR_TIMEOUT_SECONDS

source "${SCRIPTS_ROOT}/tasks/scan-code-quality/run.sh"

#######################################
#       Finalize task
#######################################
source "${ROOT_FOLDER}/${CONCOURSE_TASKS_RESOURCE}/functions/finish-task.sh"