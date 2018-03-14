#!/bin/bash
#
# Task Description:
#   Functions to run dotnet actions. By adding this script as a source, the required binaries
#   will automatically be installed
#
#	The targeted dotnet version can be overwritten by exporting DOTNET_VERSION
#	ie: export DOTNET_VERSION=2.x.x
#

exec 5>&1

######################################
# Description:
# 	Install the dotnet core runtime and SDK
# Globals:
#		None
# Source Arguments:
#		Refer to dotnet docs for explainations: https://github.com/dotnet/docs/blob/master/docs/core/tools/dotnet-install-script.md
#   --channel
#		--version
#		--architecture
#		--skip-first-time-experience: default true
#		--cli-telemetry-output: default true
#	Global Returns:
#   None
# Returns:
#   0: success
#   1: error
#######################################
function install(){
	export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=${skip_first_first_time_experience}
	export DOTNET_CLI_TELEMETRY_OPTOUT=${cli_telemetry_output}

	apt-get update --quiet --assume-yes

  apt-get install --assume-yes --fix-broken --quiet \
    libunwind8 \
    liblttng-ust0 \
		libcurl3 \
		libssl1.0.0 \
		libuuid1 \
		libkrb5-3 \
		zlib1g \
		libicu55 \
		curl \
		openssl \
		apt-transport-https

	source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/dotnet-install.sh \
		--version ${version} \
		--channel ${channel} \
		--architecture ${architecture}

	return 0
}
#######################################
# Description:
# 	Given a dotnet project, run the 'publish'' command. Packs the application and its 
#		dependencies into a folder for deployment to a hosting system.
#		https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-publish?tabs=netcore2x
# Globals:
#   None
# Arguments:
#   1 - Configuration: Debug|Release
#		2 - Framework: Publishes the application for the specified target framework. https://docs.microsoft.com/en-us/dotnet/standard/frameworks
#		3 - ArtifactDirPath: The absolute path to a directory, where the result of the pubish will be put.
#		4 - Runtime: Publishes the application for a given runtime. https://docs.microsoft.com/en-us/dotnet/core/rid-catalog
#		5 - CsProjFilePath: The absolute path to c# project(csproj) file. !Not! the solution(sln) file.
# Returns:
#   None
#######################################
function publishProject(){
	local artifactDirPath="${1}"
	local csprojFilePath="${2}"

	dotnet clean "${csprojFilePath}"

	echo "Running dotnet publish on project [${csprojFilePath}]"
	#prepare the app to be published and output to provided publish dir
	# dotnet publish output is realative to the bin directory created during build, if an absolute path is not provided
	# dotnet restore will happen automatically

	dotnet publish \
		--output "${artifactDirPath}" \
		"${csprojFilePath}"
	
	return 0
}
#######################################
# Description:
# 	Given a dotnet test app, run the 'vstest' command against it. To access values needed at run time,
#		like APP_URL, access them via environment variables.
# Globals:
#   None
# Arguments:
#		1 - TestAppDllPath: The absolute path to the test app dll to execute
#		2 - Platform: https://docs.microsoft.com/en-us/dotnet/core/rid-catalog
#		3 - Framework: https://docs.microsoft.com/en-us/dotnet/standard/frameworks
#		4 - Logger: optional, the logger to use with test results
#			refer to https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-vstest
# Returns:
#   None
#######################################
function testProject(){
	local testAppDllPath="${1}"

	echo "Discovered tests"
	dotnet vstest "${testAppDllPath}" --ListTests 
	echo "-----------------------------------------------"
	echo "-----------------------------------------------"

	echo "Running dotnet vstest [${testAppDllPath}]"
	dotnet vstest "${testAppDllPath}"

	return 0
}
#######################################
# Description:
# 	Given the current working folder, run the 'clean' command
# Globals:
#   None
# Arguments:
#		None
# Returns:
#   None
#######################################
function cleanSolution(){
	dotnet clean
	return 0
}
#######################################
# Description:
# 	Given the current working folder, run the 'build' command. Assumptions:
#			- The current folder either has a solution(sln) file or a project file (csproj)
#			- All direction for the build (including output folder) will be provided from either sln or csproj
# Globals:
#   None
# Arguments:
#		1 - DotnetFramework: https://docs.microsoft.com/en-us/dotnet/standard/frameworks
#		2 - RuntimeId: https://docs.microsoft.com/en-us/dotnet/core/rid-catalog
#		3 - Configuration: release|build
# Returns:
#   None
#######################################
function buildSolution(){
	#build every project in the folder
	dotnet build

	return 0
}

skip_first_first_time_experience=true
cli_telemetry_output=true
version=""
channel=""
architecture=""

while [ $# -ne 0 ]
do
	name="$1"
	case "$name" in
		-c|--channel|-[Cc]hannel)
				shift
				channel="$1"
				;;
		-v|--version|-[Vv]ersion)
				shift
				version="$1"
				;;
		--arch|--architecture|-[Aa]rch|-[Aa]rchitecture)
				shift
				architecture="$1"
				;;
		--skip-first-time-experience|-[Ss]kip[Ff]irst[Tt]ime[Ee]xperience)
				shift
				skip_first_first_time_experience=false
				;;
		--cli-telemetry-output|-[Cc]li[Tt]elemetry[Oo]utput)
				shift
				cli_telemetry_output=$1
				;;
	esac

	shift
done

#INITIALIZE THE LIBRARY - if not installed
command -v dotnet >/dev/null 2>&1 || install
ret=$(echo "dotnet version: $(dotnet --info)"|tee >(cat - >&5))
basePath=$(grep -i "Base Path:" <<< "${ret}" | sed 's/^.*: //')
#export FrameworkPathOverride=/usr/lib/mono/4.5/ #direct all dotnet commands to use this library