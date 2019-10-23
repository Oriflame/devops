# How to contribute

First of all it's recommended to discuss with existing project contributors like in the [issues](https://github.com/Oriflame/devops/issues) section.

**Oriflame contributors**

* Ask to be joined to the project contributors (ask Platform team)
* Create a new branch from **develop** under feature folder, e.g. **feature/cool-feature-name**
* Create a pull request to **develop** branch and ask for review

**Outside contributor**:

* Fork the repository
* Create a new branch from **develop** under feature folder, e.g. **feature/cool-feature-name**
* Create a pull request to **develop** branch and ask for review

## how to test it locally

**Init-Repo**

Before any commit it is recommended to test the script locally. Navigate to an empty directory and run

 ```
 . "$env:USERPROFILE\source\repos\devops\scripts\init-repo.ps1" -DevOpsProject XXX -RepositoryName XXX
 ```

 Please note: expected location of GIT repositories is in your profile. You need also to replace XXX with valid project name and repository name etc.
