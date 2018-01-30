#!/bin/bash

echo "Sourcing file with util functions"
# shellcheck source=/dev/null
source "${ROOT_FOLDER}/${CONCOURSE_TASKS_RESOURCE}/functions/resource-util.sh" #bring in supporting functions
exportKeyValProperties "${ROOT_FOLDER}/${KEYVAL_RESOURCE}" #must happen right after the functions script is sourced

echo "Working version is [${PASSED_PIPELINE_VERSION}]"