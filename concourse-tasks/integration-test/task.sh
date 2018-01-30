#!/bin/bash

set -o errexit
set -o errtrace

ROOT_FOLDER="$( pwd )"
TASK_SCRIPTS_RESOURCE=task-scripts
CONCOURSE_TASKS_RESOURCE=concourse-tasks
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
#APP_INTEGRATION_TEST_DLL_NAME
export INTEGRATION_TEST_ARTIFACT_NAME="${PASSED_INTEGRATION_TEST_ARTIFACT_NAME}"
source "${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}/tasks/integration-test/run.sh"

#######################################
#       Finalize task
#######################################
source "${ROOT_FOLDER}/${CONCOURSE_TASKS_RESOURCE}/functions/finish-task.sh"