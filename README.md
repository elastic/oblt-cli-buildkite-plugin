# oblt-cli-buildkite-plugin

A Buildkite plugin to set up oblt-cli.

> [!NOTE]
> This plugin does not provide a way to automatically download the latest version of `oblt-cli` to ensure that the used version is stable and the plugin is reproducible.
> If you don't provide both the `version` or `version-file` input, then the default version defined in [.default-oblt-cli-version](.default-oblt-cli-version) will be used.
> The default version will be updated by updatecli when a new version of `oblt-cli` is available. Only maintainers will decide to merge the PR created by updatecli to update the version.

## Properties
| Name                         | Type     | Default            | Description                                                                                                         |
|------------------------------|----------|--------------------|---------------------------------------------------------------------------------------------------------------------|
| `version`                    | `string` | `7.3.0`            | The version of the oblt-cli to install.                                                                             |
| <nobr>`version-file`</nobr>  | `string` | -                  | The file to get the version from. If both `version` and `version-file` are provided, the plugin will use `version`. |
| `username`                   | `string` | `obltmachine`      | The oblt-cli username                                                                                               |
| <nobr>`slack-channel`</nobr> | `string` | `#observablt-bots` | The slack channel for oblt-cli notifications                                                                        |

## Usage

```yaml
steps:
  - command: oblt-cli cluster create serverless
    agents:
      provider: gcp # currently only works on the gcp provider
    plugins:
      - elastic/oblt-cli#v0.1.0:
          version-file: .tool-versions

```

## GitHub Token
This plugin requires the `VAULT_GITHUB_TOKEN`, which is set by default in Buildkite agents.

### Permissions
The plugin requires the following GitHub token permissions in the [elastic/observability-test-environments](https://github.com/elastic/observability-test-environments) repository:
```
contents: write
pull_requests: read
```
