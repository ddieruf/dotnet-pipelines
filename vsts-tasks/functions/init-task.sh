#!/bin/bash

echo "Sourcing file with util functions"
# shellcheck source=/dev/null
source "${ROOT_FOLDER}/${PIPELINE_RESOURCE}/functions/resource-util.sh" #bring in supporting functions
exportKeyValProperties

echo "Working version is [${PASSED_PIPELINE_VERSION}]"