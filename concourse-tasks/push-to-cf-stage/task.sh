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
export PIPELINE_VERSION="${PASSED_PIPELINE_VERSION}"
export SRC_ARTIFACT_NAME="${PASSED_SRC_ARTIFACT_NAME}"
export APP_NAME="${PAAS_STAGE_APP_NAME}"
export CF_USERNAME="${PAAS_STAGE_USERNAME}"
export CF_PASSWORD="${PAAS_STAGE_PASSWORD}"
export CF_ORG="${PAAS_STAGE_ORG}"
export CF_SPACE="${PAAS_STAGE_SPACE}"
export CF_API_URL="${PAAS_STAGE_API_URL}"

source "${ROOT_FOLDER}/${TASK_SCRIPTS_RESOURCE}/tasks/push-to-cf-stage/run.sh"

export PASSED_STAGE_APP_ROUTE="${APP_ROUTE}"
export PASSED_STAGE_APP_URLS="${APP_URLS}"

#######################################
#       Finalize task
#######################################
source "${ROOT_FOLDER}/${CONCOURSE_TASKS_RESOURCE}/functions/finish-task.sh"
