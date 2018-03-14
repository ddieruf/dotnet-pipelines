# dotnet-pipelines/scripts/tasks/smoke-test

The smoke-test task is used to run smoke tests on the app endpoints once pushed to cloud foundry.

The task has the following steps:
- validate that all values were correctly provided and file/folder locations exist
- install the needed cli's dotnet, mono, and artifactory
- download and extract the smoke test archive from artifactory
- run dotnet test on the project dll

### Required Values
	ARTIFACTORY_HOST: The URL to access artifactory
	ARTIFACTORY_TOKEN: https://www.jfrog.com/confluence/display/RTF/Access+Tokens#AccessTokens-UsingTokens
	ARTIFACTORY_REPO_ID: The identifying key of the Artifactory repo associated with the solution
	SMOKE_TEST_ARTIFACT_NAME - The artifact name created from running the build-and-uplaod task
	SMOKE_TEST_DLL_NAME - The dll name of the artifact test project
	DOTNET_VERSION: Dotnet cli version https://github.com/dotnet/core/releases

### Optional Values
	none

### Output Values
	none