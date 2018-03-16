# dotnet-pipelines/scripts/tasks/dotnet-test

The dotnet-test task is used to run tests on the app. I have derived these tests from [Microsoft documentation](https://docs.microsoft.com/en-us/aspnet/core/testing/integration-testing), [Spring pipelines](https://github.com/spring-cloud/spring-cloud-pipelines) documentation, and others. The following is my interpretation of how to set up testing...

### Unit Test
Unit testing should test each public method in my Interfaces folder. These methods "translate" data to and from a data transformation object(DTO) to a data model (otherwise known as a view) as well as validate. These methods are normally called from a controller method and "communicate" with the controller by exceptions. In example, if a method takes an object of type Models.DTOs.Message.Search and it is a required value in your data model, the method should do something like
```
if(srchObject == null)
	throw new ArgumentNullException("Models.DTOs.Message.Search");
```
The controller should not know anything about what a valid object looks like. Thats not the purpose of it. The contoller knows about endpoints. The Interfaces are the ones that know what a valid object looks like and talk back to the controller, who then translates an exception into an http status and (possibly) a message.

Thus, your unit testing is about making sure the data is being transformed, saved, or moved on to the next service correctly.

### Integration Test
Integration testing should test every public method in my Contollers folder. These methods establish a restful endpoint to Interface methods that do "work" on data. THe only validation these methods do, is to make sure the ModelState IsValid. Controller methods should not know all the details of what a valid object looks like, but can enforce primitives. THe Interface methods "communicate" to the controller methods through different exception types and the Contoller methods translate that to an HTTP status code and possible a message body.

Thus, integration tests require some type of web server (either in memory or for real) for the contoller methods to be tested but are not interested in data integrity. They just validate the endpoint is working correctly and respond with correct status codes.

### Smoke Test
Smoke tests validate that a given webapi has been pushed to the platform correctly. If you are at this point, it is assumed that unit testing and integration testing has passed. This test doesn't need to be involved it is simply to confirm the app is live (or correctly staged), has recevied a proper route, and all the intended endpoints are available publicly and/or privately. Like integration testing, smoke tests are not going to validate data integrity. They as just going to make sure the correct http status are being used.

The task has the following steps:
- validate that all values were correctly provided and file/folder locations exist
- install the needed cli's dotnet, mono, and artifactory
- download and extract the integration test archive from artifactory
- run dotnet test on the project dll

### Required Values
	ARTIFACTORY_HOST: The URL to access artifactory
	ARTIFACTORY_TOKEN: https://www.jfrog.com/confluence/display/RTF/Access+Tokens#AccessTokens-UsingTokens
	ARTIFACTORY_REPO_ID: The identifying key of the Artifactory repo associated with the solution
	TEST_ARTIFACT_NAME - The artifact name created from running the build-and-uplaod task
	TEST_DLL_NAME - The dll name of the artifact test project
	DOTNET_VERSION: Dotnet cli version https://github.com/dotnet/core/releases

### Optional Values
	APP_URL: The app's route to use in smoke tests

### Output Values
	none