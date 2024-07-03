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
    agents:
      provider: gcp # currently only works on the gcp provider
    plugins:
      - elastic/oblt-cli#v1.0.0:
          version: 7.3.0

```

## GitHub Token
This plugin requires a GitHub token to work properly.
The token can be set in the following environment variables:

- `GH_TOKEN`
- `GITHUB_TOKEN`
- `VAULT_GITHUB_TOKEN`

If multiple are set, the plugin will use the first one it finds in the order they are listed.

### Permissions
The plugin requires the following GitHub token permissions in the [elastic/observability-test-environments](https://github.com/elastic/observability-test-environments) repository:
```
contents: write
pull_requests: read
```
