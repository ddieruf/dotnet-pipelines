#!/bin/bash

set -o errexit
set -o errtrace

ROOT_FOLDER="$( pwd )"
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
#ARTIFACTORY_HOST
#ARTIFACTORY_TOKEN
#ARTIFACTORY_REPO_ID
#UNIT_TEST_DLL_NAME
export UNIT_TEST_ARTIFACT_NAME="${PASSED_UNIT_TEST_ARTIFACT_NAME}"
source "${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}/tasks/unit-test/run.sh"

#######################################
#       Finalize task
#######################################
source "${ROOT_FOLDER}/${CONCOURSE_TASKS_RESOURCE}/functions/finish-task.sh"