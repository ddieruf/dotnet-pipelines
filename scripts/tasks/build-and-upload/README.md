# dotnet-pipelines/scripts/tasks/build-and-upload

The build-and-upload task is used to run dotnet publish on each project in the solution, archive(zip) the publish result, and upload the archive to Artifactory. Every subsiquent step will pull the archive from Artifactory and unpack. This is a single build strategy, where you are not continually testing on the source code.

The task has the following steps:
- validate that all values were correctly provided and file/folder locations exist
- install the needed cli's
- for the app source, copy manifests into the publish folder and run dotnet publish on source project
- archive the publish result and save
- for the unit test source (if provided), run dotnet publish on the project
- archive the publish result and save
- for the integration test source (if provided), run dotnet publish on the project
- archive the publish result and save
- for the smoke test source (if provided), run dotnet publish on the project
- archive the publish result and save
- export the resulting archive name(s) for reference

### Required Values
	APP_SRC_CSPROJ_PATH: From the sln file, the location of the app source code project file
	PIPELINE_VERSION: The result of the generate-version task
	CF_STAGE_MANIFEST_PATH: From the sln file, the location of the staging cf manifest
	CF_PROD_MANIFEST_PATH: From the sln file, the location of the prod cf manifest
	DOTNET_VERSION: Dotnet cli version https://github.com/dotnet/core/releases
	ARTIFACT_LOCATION_TYPE: Where to save the artifacts, supported values are ```local``` or ```artifactory```

### Optional Values
	APP_UNIT_TEST_CSPROJ_PATH: From the sln file, the location of the app unit test project file
	APP_INTEGRATION_TEST_CSPROJ_PATH: From the sln file, the location of the app integration test project file
	APP_SMOKE_TEST_CSPROJ_PATH: From the sln file, the location of the app smoke test project file
	ARTILLERY_MANIFEST_PATH: From the sln file, the location of the artillery manifest
	ARTIFACTORY_HOST: The URL to access artifactory. Required if ```ARTIFACT_LOCATION_TYPE==artifactory```
	ARTIFACTORY_TOKEN: https://www.jfrog.com/confluence/display/RTF/Access+Tokens#AccessTokens-UsingTokens Required if ```ARTIFACT_LOCATION_TYPE==artifactory```
	ARTIFACTORY_REPO_ID: The identifying key of the Artifactory repo associated with the solution. Required if ```ARTIFACT_LOCATION_TYPE==artifactory```
	ARTIFACT_FOLDER_PATH: Where to save the newly created artifact. Required if ```ARTIFACT_LOCATION_TYPE==local```

### Output Values
	SRC_ARTIFACT_NAME: The generated and saved archive name holding the app dll's
	UNIT_TEST_ARTIFACT_NAME: The generated and saved archive name holding the unit test dll's
	INTEGRATION_TEST_ARTIFACT_NAME: The generated and saved archive name holding the integration test dll's
	SMOKE_TEST_ARTIFACT_NAME: The generated and saved archive name holding the smoke test dll's