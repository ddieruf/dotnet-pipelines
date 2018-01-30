#!/bin/bash
#
# Task Description:
#   Functions to run SonarQube actions. By adding this script as a source, the required binaries
#   will automatically be installed
#

######################################
# Description:
# 	Install sonarqube msbuild scanner and needed dependencies. Note to run this in a linux environment
#   we are mono.
# Globals:
#   None
# Arguments:
#   None
#	Global Returns:
#   None
# Returns:
#   0: success
#   1: error
#######################################
function install(){
  local SONAR_SCANNER_MSBUILD_HOME=/opt/sonar-scanner-msbuild

  command -v mono >/dev/null 2>&1 || installMono
  echo "mono version: $(mono --version)"

  if [[ ! -d "${SONAR_SCANNER_MSBUILD_HOME}" ]]; then
    installSonar "${SONAR_SCANNER_MSBUILD_HOME}"
  fi

  echo "Sonarqube home: ${SONAR_SCANNER_MSBUILD_HOME}"

  return 0
}
function installMono(){
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF

  echo "deb http://download.mono-project.com/repo/ubuntu xenial main" | tee /etc/apt/sources.list.d/mono-official.list

  apt-get update --quiet --assume-yes
  apt-get install --assume-yes --fix-broken --quiet --allow-unauthenticated \
    mono-complete \
    ca-certificates-mono \
    referenceassemblies-pcl \
    mono-xsp4

	return 0
}
function installSonar(){
  local homeDir="${1}"

  apt-get update --quiet --assume-yes
  apt-get install --assume-yes --fix-broken --quiet --allow-unauthenticated \
    wget \
    unzip \
    jq

  wget https://github.com/SonarSource/sonar-scanner-msbuild/releases/download/${scanner-msbuild-version}/sonar-scanner-msbuild-${scanner-msbuild-version}.zip -O /opt/sonar-scanner-msbuild.zip

  mkdir -p ${homeDir}
  unzip /opt/sonar-scanner-msbuild.zip -d ${homeDir}
  rm /opt/sonar-scanner-msbuild.zip
  chmod 775 ${homeDir}/*.exe
  chmod 775 ${homeDir}/**/bin/*
  chmod 775 ${homeDir}/**/lib/*.jar

  PATH="${homeDir}:${homeDir}/sonar-scanner-${scanner-version}/bin:${PATH}"

	return 0
}
######################################
# Description:
# 	Before running the dotnet publish, setup Sonarqube
# Globals:
#   None
# Arguments:
#   1 - sonarHost
#   2 - sonarLoginKey
#   3 - sonarProjectKey
#   4 - sonarProjectName
#   5 - pipelineVersion
#	Global Returns:
#   None
# Returns:
#   0: success
#   1: error
#######################################
function beginMSBuildScanner(){
  local sonarHost="${1}"
  local sonarLoginKey="${2}"
  local sonarProjectKey="${3}"
  local sonarProjectName="${4}"
  local pipelineVersion="${5}"

  local urlstatus=$(curl -o /dev/null --silent --head --write-out '%{http_code}' "${sonarHost}" )
  if [[ ${urlstatus} -ne 200 ]]; then
    echo "ERROR: Sonar host could not be reached [${sonarHost}]"
    return 1
  fi

  mono /opt/sonar-scanner-msbuild/SonarQube.Scanner.MSBuild.exe begin \
    /d:sonar.host.url="${sonarHost}" \
    /d:sonar.login="${sonarLoginKey}" \
    /k:"${sonarProjectKey}" \
    /n:"${sonarProjectName}" \
    /v:"${pipelineVersion}"

  return 0
}
######################################
# Description:
# 	Finalize the scan
# Globals:
#   None
# Arguments:
#   1 - sonarLoginKey
#	Global Returns:
#   None
# Returns:
#   0: success
#   1: error
#######################################
function endMSBuildScanner(){
  local sonarLoginKey="${1}"

  mono /opt/sonar-scanner-msbuild/SonarQube.Scanner.MSBuild.exe end \
    /d:sonar.login="${sonarLoginKey}"

  return 0
}
######################################
# Description:
# 	Immedicatly after the scan is complete, begin polling for the quality gate rating.
#   THe rating is a pass|fail and the pipeline should not continue if it fails.
# Globals:
#   None
# Arguments:
#   1 - sonarHost
#   2 - sonarWorkspace: during the scan, a tmp directory was created by Sonarqube
#   3 - timeoutSeconds: how long to wait for the quality gate before exiting as error
#	Global Returns:
#   None
# Returns:
#   0: success
#   1: error
#######################################
function checkQualityGate(){
  local sonarHost="${1}"
  local sonarWorkspace="${2}"
  local timeoutSeconds="${3}"

  #Need to check sonarqube quality gate for pass/fail
  #  https://docs.sonarqube.org/display/SONARQUBE53/Breaking+the+CI+Build

  local urlstatus=$(curl -o /dev/null --silent --head --write-out '%{http_code}' "${sonarHost}" )
  if [[ ${urlstatus} -ne 200 ]]; then
    echo "ERROR: Sonar host could not be reached [${sonarHost}]"
    return 1
  fi

  if [[ ! -d ${sonarWorkspace}/.sonar ]]; then #this won't exist until after the sonar job has run
    echo "ERROR: Sonar workspace not found [${sonarWorkspace}/.sonar]"
    return 1
  fi
  if [[ ! -f ${sonarWorkspace}/.sonar/report-task.txt ]]; then #this won't exist until after the sonar job has run
    echo "ERROR: Sonar report file not found [${sonarWorkspace}/.sonar/report-task.txt]"
    return 1
  fi

  url="$(grep -i "ceTaskUrl" ${sonarWorkspace}/.sonar/report-task.txt | sed 's/^ceTaskUrl=//')"
  echo "${url}"

  interval=5 #poll every 5 seconds
  return_code=1
  ((end_time=${SECONDS}+${timeoutSeconds})) #try for X minutes

  while ((${SECONDS} < ${end_time}))
  do
    status="$(curl ${url} | jq '.task.status' | sed 's/\"//g')"
    echo "Analysis status=${status}"
    
    if [[ "${status}" == "SUCCESS" ]]; then
      return_code=0
      break
    fi

    sleep ${interval}
  done

  if [[ ${return_code} -ne 0 ]]; then
    echo "ERROR: Sonar analysis did not complete in time or was not successful"
    return 1
  fi

  return_code=1 #reset from above
  ((end_time=${SECONDS}+${timeoutSeconds})) #try for X minutes

  analysisID="$(curl ${url} | jq '.task.analysisId' | sed 's/\"//g')"
  analysisUrl="${sonarHost}/api/qualitygates/project_status?analysisId=${analysisID}"
  echo "${analysisUrl}"

  while ((${SECONDS} < ${end_time}))
  do
    quality_gate_status=$(curl ${analysisUrl} | jq '.projectStatus.status' | sed 's/\"//g')
    echo "Quality gate status=${quality_gate_status}"
    
    if [[ "${quality_gate_status}" == "OK" ]]; then
      return_code=0
      break
    fi

    sleep ${interval}
  done

  #cp -r . $TASK_ROOT/log-message-build/ #FOR DEBUGGING
  return ${return_code}
}

scanner-msbuild-version=""
scanner-version=""

while [ $# -ne 0 ]
do
	name="$1"
	case "$name" in
		--scanner-msbuild-version|-[Ss]canner[Mm]sbuild[Vv]ersion)
				shift
				scanner-msbuild-version="$1"
				;;
		--scanner-version|-[Ss]canner-[Vv]ersion)
				shift
				scanner-version="$1"
				;;
		*)
				say_err "Unknown argument \`$name\`"
				exit 1
				;;
	esac

	shift
done

#INITIALIZE THE LIBRARY
install