# zen [![master](https://travis-ci.com/zensurance/zen.svg?token=DDoJ2FFmSQy7sJTjMVEY&branch=master)](https://travis-ci.com/zensurance/dashboard)

&nbsp;
<p align="center">
  <img src ="https://www.zensurance.com/wp-content/uploads/2019/06/logo_zensurance.svg">
</p>



# Zensurance Salesforce App

- ### Welcome to Salesforce App! This guide helps Salesforce developers who are new to Visual Studio Code go from zero to a deployed app using Salesforce Extensions for VS Code and Salesforce CLI.
- ### Please navigate to `"scripts"` section inside `.package.json` to see what commands are available for running packages from the the root directory.

## Part 1: Choosing a Development Model

There are two types of developer processes or models supported in Salesforce Extensions for VS Code and Salesforce CLI. These models are explained below. Each model offers pros and cons and is fully supported.

### Package Development Model

The package development model allows you to create self-contained applications or libraries that are deployed to your org as a single package. These packages are typically developed against source-tracked orgs called scratch orgs. This development model is geared toward a more modern type of software development process that uses org source tracking, source control, and continuous integration and deployment.

If you are starting a new project, we recommend that you consider the package development model. To start developing with this model in Visual Studio Code, see [Package Development Model with VS Code](https://forcedotcom.github.io/salesforcedx-vscode/articles/user-guide/package-development-model). For details about the model, see the [Package Development Model](https://trailhead.salesforce.com/en/content/learn/modules/sfdx_dev_model) Trailhead module.

If you are developing against scratch orgs, use the command `SFDX: Create Project` (VS Code) or `sfdx force:project:create` (Salesforce CLI) to create your project. If you used another command, you might want to start over with that command.

When working with source-tracked orgs, use the commands `SFDX: Push Source to Org` (VS Code) or `sfdx force:source:push` (Salesforce CLI) and `SFDX: Pull Source from Org` (VS Code) or `sfdx force:source:pull` (Salesforce CLI). Do not use the `Retrieve` and `Deploy` commands with scratch orgs.

### Org Development Model

The org development model allows you to connect directly to a non-source-tracked org (sandbox, Developer Edition (DE) org, Trailhead Playground, or even a production org) to retrieve and deploy code directly. This model is similar to the type of development you have done in the past using tools such as Force.com IDE or MavensMate.

To start developing with this model in Visual Studio Code, see [Org Development Model with VS Code](https://forcedotcom.github.io/salesforcedx-vscode/articles/user-guide/org-development-model). For details about the model, see the [Org Development Model](https://trailhead.salesforce.com/content/learn/modules/org-development-model) Trailhead module.

If you are developing against non-source-tracked orgs, use the command `SFDX: Create Project with Manifest` (VS Code) or `sfdx force:project:create --manifest` (Salesforce CLI) to create your project. If you used another command, you might want to start over with this command to create a Salesforce DX project.

When working with non-source-tracked orgs, use the commands `SFDX: Deploy Source to Org` (VS Code) or `sfdx force:source:deploy` (Salesforce CLI) and `SFDX: Retrieve Source from Org` (VS Code) or `sfdx force:source:retrieve` (Salesforce CLI). The `Push` and `Pull` commands work only on orgs with source tracking (scratch orgs).

## The `sfdx-project.json` File

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

The most important parts of this file for getting started are the `sfdcLoginUrl` and `packageDirectories` properties.

The `sfdcLoginUrl` specifies the default login URL to use when authorizing an org.

The `packageDirectories` filepath tells VS Code and Salesforce CLI where the metadata files for your project are stored. You need at least one package directory set in your file. The default setting is shown below. If you set the value of the `packageDirectories` property called `path` to `force-app`, by default your metadata goes in the `force-app` directory. If you want to change that directory to something like `src`, simply change the `path` value and make sure the directory you’re pointing to exists.

```json
"packageDirectories" : [
    {
      "path": "force-app",
      "default": true
    }
]
```

## Part 2: Working with Source

For details about developing against scratch orgs, see the [Package Development Model](https://trailhead.salesforce.com/en/content/learn/modules/sfdx_dev_model) module on Trailhead or [Package Development Model with VS Code](https://forcedotcom.github.io/salesforcedx-vscode/articles/user-guide/package-development-model).

For details about developing against orgs that don’t have source tracking, see the [Org Development Model](https://trailhead.salesforce.com/content/learn/modules/org-development-model) module on Trailhead or [Org Development Model with VS Code](https://forcedotcom.github.io/salesforcedx-vscode/articles/user-guide/org-development-model).

## Part 3: Deploying to Production

Don’t deploy your code to production directly from Visual Studio Code. The deploy and retrieve commands do not support transactional operations, which means that a deployment can fail in a partial state. Also, the deploy and retrieve commands don’t run the tests needed for production deployments. The push and pull commands are disabled for orgs that don’t have source tracking, including production orgs.

Deploy your changes to production using [packaging](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_dev2gp.htm) or by [converting your source](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_force_source.htm#cli_reference_convert) into metadata format and using the [metadata deploy command](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_force_mdapi.htm#cli_reference_deploy).

### Deployment commands

First, run the tests to get a job ID:

```sh
sfdx force:source:deploy --checkonly \
    --sourcepath force-app --targetusername {PRODUCTION_ORG_HERE} \
    --testlevel RunLocalTests
```

The job ID will be available when the deployment finishes:

```
Deployment finished in 78000ms

=== Result
Status:  Failed         <<==== NOTE: status should be SUCCESSFUL, this is an example.
jobid:  0Af4o00000mdJnRCAU
Completed:  2019-12-09T18:04:26.000Z
Component errors:  0
Components checked:  32
Components total:  32
Tests errors:  7
Tests completed:  12
Tests total:  19
Check only: true
```

Wait for the tests to finish running. At the end you should see a test summary like this:

```
=== Apex Code Coverage
NAME                                % COVERED           UNCOVERED LINES
──────────────────────────────────  ──────────────────  ──────────────────────────────────────────────────────────────────────
Accounts                            96%                 50
CarrierProducts                     100%
Carriers                            100%
DAO                                 100%
Policies                            88%                 30,31,52,56,60
PolicyOptions                       57.99999999999999%  4,8,9,10,11,12,13,14,15,20,21,22,24,32,71
QuoteCoverages                      0%                  3,4,7,8,10,11,23,26,39,43,47,48,49,53,54,55,56,57,58,63,64,65,66,67,68
Quotes                              0%                  3,4,12,14,17,18,32,37,38,40,41,42,43,44,46,47,48,49,52,54,55,57
setCalculatedPremiumAndFeesOnQuote  0%                  5,6,7,8,9,10,12,13,14,15,18,19,20,24,25,26,27,28
```

Finally, assuming the tests have PASSED, you're ready to deploy:

```
sfdx force:source:deploy \
    --targetusername {PRODUCTION_ORG_HERE} \
    --validateddeployrequestid {JOB_ID_HERE}
```

# Useful Documentation
* [API Documentation](./docs/api/api.md)
* [Technical Documentation](./docs/tech/tech.md)
* See `./docs/tech/` for other misc tech docs.
