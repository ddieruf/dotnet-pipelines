# dotnet-pipelines/scripts/tasks/unit-test

The unit-test task is used to run unit tests on the app. I have derived unit tests from [Microsoft documentation](https://docs.microsoft.com/en-us/dotnet/core/testing/), [Spring pipelines](https://github.com/spring-cloud/spring-cloud-pipelines) documentation, and others. The following is my interpretation of how to set up a unit test...

Unit testing should test each public method in my Interfaces folder. These methods "translate" data to and from a data transformation object(DTO) to a data model (otherwise known as a view) as well as validate. These methods are normally called from a controller method and "communicate" with the controller by exceptions. In example, if a method takes an object of type Models.DTOs.Message.Search and it is a required value in your data model, the method should do something like
```
if(srchObject == null)
	throw new ArgumentNullException("Models.DTOs.Message.Search");
```
The controller should not know anything about what a valid object looks like. Thats not the purpose of it. The contoller knows about endpoints. The Interfaces are the ones that know what a valid object looks like and talk back to the controller, who then translates an exception into an http status and (possibly) a message.

Thus, your unit testing is about making sure the data is being transformed, saved, or moved on to the next service correctly.

The task has the following steps:
- validate that all values were correctly provided and file/folder locations exist
- install the needed cli's dotnet, mono, and artifactory
- download and extract the unit test archive from artifactory
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