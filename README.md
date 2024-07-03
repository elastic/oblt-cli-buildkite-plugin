# oblt-cli-buildkite-plugin

A Buildkite plugin to set up oblt-cli

> [!NOTE]
> If you are using a different GitHub access token than the one provided by the Buildkite pipeline,
> you will need to set up the git configuration and authenticate with GitHub.
> This is required because `oblt-cli` pushes to the `elastic/observability-test-environments` repository.
>
> The following example demonstrate hot to set up the git configuration and authenticate with GitHub using gh CLI:
> ```shell
> git config --global user.name "${GIT_USER}"
> git config --global user.email "${GIT_EMAIL}"
> gh auth setup-git # Assumes GH_TOKEN or GITHUB_TOKEN is set with write access to elastic/observability-test-environments
> ```
> 
> But you can also use [git-credential-manager](https://github.com/git-ecosystem/git-credential-manager) or any other method to authenticate with GitHub.

## Properties

| Name            | Type     | Default            | Description                                                                                                         |
|-----------------|----------|--------------------|---------------------------------------------------------------------------------------------------------------------|
| `version`       | `string` | `7.3.0`            | The version of the oblt-cli to install.                                                                             |
| `version-file`  | `string` | -                  | The file to get the version from. If both `version` and `version-file` are provided, the plugin will use `version`. |
| `username`      | `string` | `obltmachine`      | The oblt-cli username                                                                                               |
| `slack-channel` | `string` | `#observablt-bots` | The slack channel for oblt-cli notifications                                                                        |

## Usage

```yaml
steps:
  - command: oblt-cli cluster create serverless
    env: 
      GITHUB_TOKEN: ${GITHUB_TOKEN} # Needs write access to elastic/observability-test-environments
    agents:
      provider: gcp # currently only works on the gcp provider
    plugins:
      - elastic/oblt-cli#v1.0.0:
          version: 7.3.0

```
