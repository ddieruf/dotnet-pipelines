# dotnet-pipelines/scripts/tasks/generate-version

The generate-version task is used to incrament from the previous version. After initializations, this task should be the first step of the build. Almost all subsiquent builds require the new version number. Note, the file holding version number should not be saved until the new app is completely pushed to production. Anything less would mean the version was not correctly created and thus the file's value should not be bumped.

The version file should have a single line holding the semantic format Major.Minor.Patch:
```
0.1.0
```
From this format the generate-version task will bump only the patch version. It is up to you to bump minor and/or major. Start at the number 0(zero) and let the task bump to 1(one).

### Required Values
	VERSION_ROOT: The absolute path to the version source folder

### Optional Values
	none

### Output Values
	NEW_VERSION_NUMBER: The bumped version number