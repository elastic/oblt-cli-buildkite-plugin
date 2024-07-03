# oblt-cli-buildkite-plugin

A Buildkite plugin to set up oblt-cli

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
