# dotnet-pipelines/scripts/tasks/integration-test

The integration-test task is used to run integration tests on the app.

The task has the following steps:
- validate that all values were correctly provided and file/folder locations exist
- install the needed cli's dotnet, mono, and artifactory
- download and extract the integration test archive from artifactory
- run dotnet test on the project dll

### Required Values
	ARTIFACTORY_HOST: The URL to access artifactory
	ARTIFACTORY_TOKEN: https://www.jfrog.com/confluence/display/RTF/Access+Tokens#AccessTokens-UsingTokens
	ARTIFACTORY_REPO_ID: The identifying key of the Artifactory repo associated with the solution
	INTEGRATION_TEST_ARTIFACT_NAME - The artifact name created from running the build-and-uplaod task
	INTEGRATION_TEST_DLL_NAME - The dll name of the artifact test project
	DOTNET_VERSION: Dotnet cli version https://github.com/dotnet/core/releases
	DOTNET_FRAMEWORK: https://docs.microsoft.com/en-us/dotnet/standard/frameworks
	DOTNET_PLATFORM: https://docs.microsoft.com/en-us/dotnet/core/rid-catalog

### Optional Values
	DOTNET_TEST_LOGGER: Leave blank to not use logger functions during tests https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-vstest

### Output Values
	none