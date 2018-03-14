# dotnet-pipelines/scripts/tasks/scan-code-quality

The scan-code-quality task uses a [SonarQube](https://www.sonarqube.org/) server to scan the app source for quality.

The task has the following steps:
- validate that all values were correctly provided
- install the needed cli's dotnet, mono, and sonar
- ping the sonar server to confirm URL
- run dotnet clean on the solution
- initialize the sonar msbuild scanner
- run dotnet build on the entire solution
- end the sonar scanner, so the quality scans can begin
- retrieve the newly created endpoints in SonarQube for the job
- poll the SonarQube job for a pass/fail quailty gate
- decide to fail the build if the scan did not pass the quailty scan

### Required Values
  PIPELINE_VERSION: The value from generate-version task
	SRC_AND_TEST_ROOT: The absolute path of the folder holding solution(sln) file
	SONAR_PROJECT_KEY: The identifying key of the SonarQube project associated with the solution
	SONAR_PROJECT_NAME: The name of the SonarQube project associated with the solution
	SONAR_HOST: The URL to access SonarQube
	SONAR_LOGIN_KEY: https://docs.sonarqube.org/display/SONAR/User+Token
	DOTNET_VERSION: Dotnet cli version https://github.com/dotnet/core/releases
	SONAR_SCANNER_VERSION: Version of sonar cli
	SONAR_SCANNER_MSBUILD_VERSION: Version of the sonar msbuild scanner
	SONAR_TIMEOUT_SECONDS: The time, in seconds, Sonar Qube should wait for a quality gate report

### Optional Values
	none

### Output Values
	none