#!/bin/bash
#
# Task Description:
#   Given an orphan banch named version, look up its value and incrament
# 
# Required Globals:
#   VERSION_ROOT - the full path to the version source directory
#
# Output Globals:
#   NEW_VERSION_NUMBER - the bumped version number

THIS_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#######################################
#       Validate required globals
#######################################
[[ ! -z "${VERSION_ROOT}" ]] || (echo "VERSION_ROOT is a required value" && exit 1)

[[ ! -d "${VERSION_ROOT}" ]] || (echo "VERSION_ROOT path invalid [${VERSION_ROOT}]" && exit 1)

#######################################
#       Source needed functions
#######################################

#######################################
#       Setup temporary directories
#######################################

#######################################
#       Begin task
#######################################
#make sure the "version" file is present in the version repo
# (no the file doesn't have an extension, it's just named "version")
if [[ ! -f "${VERSION_ROOT}/version" ]]; then
  echo "Creating version file [${VERSION_ROOT}/version]"
  touch "${VERSION_ROOT}/version"
fi

currentVersion=$(cat "${VERSION_ROOT}/version") #get the contents

if [[ ! -z "${currentVersion}" ]]; then
  echo "Seeding version [0.0.0]"
  currentVersion="0.0.0" #initialize if the file was empty
fi

#This pipeline is responsible for bumping the patch version only
#If you want the minor or major version changed edit the repo file manually
# ie: if the current version is 0.0.5 and you want to bump the major version,
#   change the file to be 1.0.0 and the next pipeline push will be 1.0.1
versionParts=(${currentVersion//./ })
if [[ ${#versionParts[@]} -lt 3 ]]; then
  echo "Version number msut follow semantic pattern major.minor.patch"
  exit 1
fi

echo "Found version ${currentVersion}"
newVersion="${currentVersion%.*}.$((${currentVersion##*.}+1))" #bump patch version by 1
echo "New version ${newVersion}"

#######################################
#       Return result
#######################################
export NEW_VERSION_NUMBER="${newVersion}"