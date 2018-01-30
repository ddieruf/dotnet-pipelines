#!/bin/bash
#
# Task Description:
#   Given a directory with either a solution(sln) file or a project(csproj) file, attempt a build
#   and let SonarQube analyze it
# 
# Required Globals:
#   SRC_AND_TEST_ROOT
#   PIPELINE_VERSION
#   SONAR_PROJECT_KEY
#   SONAR_PROJECT_NAME
#   SONAR_HOST
#   SONAR_LOGIN_KEY
#   DOTNET_VERSION
#   SONAR_SCANNER_VERSION
#   SONAR_SCANNER_MSBUILD_VERSION
#   SONAR_TIMEOUT_SECONDS

set -o errexit
set -o errtrace

export ROOT_FOLDER="$( pwd )"
export THIS_FOLDER="$( dirname "${BASH_SOURCE[0]}" )"

#######################################
#       Validate required globals
#######################################
[[ ! -z "${SRC_AND_TEST_ROOT}" ]] || (echo "SRC_AND_TEST_ROOT is a required value" && exit 1)
[[ ! -z "${PIPELINE_VERSION}" ]] || (echo "PIPELINE_VERSION is a required value" && exit 1)
[[ ! -z "${SONAR_HOST}" ]] || (echo "SONAR_HOST is a required value" && exit 1)
[[ ! -z "${SONAR_LOGIN_KEY}" ]] || (echo "SONAR_LOGIN_KEY is a required value" && exit 1)
[[ ! -z "${SONAR_PROJECT_NAME}" ]] || (echo "SONAR_PROJECT_NAME is a required value" && exit 1)
[[ ! -z "${SONAR_TIMEOUT_SECONDS}" ]] || (echo "SONAR_TIMEOUT_SECONDS is a required value" && exit 1)

[[ -d "${SRC_AND_TEST_ROOT}" ]] || (echo "SRC_AND_TEST_ROOT path invalid [${SRC_AND_TEST_ROOT}]" && exit 1)

#######################################
#       Source needed functions
#######################################
source "${THIS_FOLDER}/../../functions/dotnet-core.sh --version ${DOTNET_VERSION}"
source "${THIS_FOLDER}/../../functions/sonar.sh --scanner-version ${SONAR_SCANNER_VERSION} --msbuild-version ${SONAR_SCANNER_MSBUILD_VERSION}"

#######################################
#       Setup temporary values
#######################################

#######################################
#       Begin task
#######################################
#now that the required dependencies are installed, one last test
urlstatus=$(curl -o /dev/null --silent --head --write-out '%{http_code}' "${SONAR_HOST}" )
if [[ ${urlstatus} -ne 200 ]]; then
  echo "ERROR: Sonar host could not be reached [${SONAR_HOST}]"
  exit 1
fi

cd "${SRC_AND_TEST_ROOT}" || exit

dotnetClean

beginMSBuildScanner "${SONAR_HOST}" \
  "${SONAR_LOGIN_KEY}" \
  "${SONAR_PROJECT_KEY}" \
  "${SONAR_PROJECT_NAME}" \
  "${PIPELINE_VERSION}"

buildEntireDotnetCoreSolution

endMSBuildScanner "${SONAR_LOGIN_KEY}"

echo "====================================="
echo "Analysis completed, looking up quality gate status"
echo "====================================="

checkQualityGate "${SONAR_HOST}" "./.sonarqube/out" ${SONAR_TIMEOUT_SECONDS}
if [[ $? -eq 1 ]]; then
  echo "Project did not pass quality gate checks"
  exit 1
fi

cd "${ROOT_FOLDER}" || exit
#######################################
#       Return result
#######################################