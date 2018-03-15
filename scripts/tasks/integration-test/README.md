# dotnet-pipelines/scripts/tasks/integration-test

The integration-test task is used to run integration tests on the app. I have derived integration tests from [Microsoft documentation](https://docs.microsoft.com/en-us/aspnet/core/testing/integration-testing), [Spring pipelines](https://github.com/spring-cloud/spring-cloud-pipelines) documentation, and others. The following is my interpretation of how to set up an integration test...

Integration testing should test every public method in my Contollers folder. These methods establish a restful endpoint to Interface methods that do "work" on data. THe only validation these methods do, is to make sure the ModelState IsValid. Controller methods should not know all the details of what a valid object looks like, but can enforce primitives. THe Interface methods "communicate" to the controller methods through different exception types and the Contoller methods translate that to an HTTP status code and possible a message body.

Thus, integration tests require some type of web server (either in memory or for real) for the contoller methods to be tested but are not interested in data integrity. They just validate the endpoint is working correctly and respond with correct status codes.

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

### Optional Values
	none

### Output Values
	none