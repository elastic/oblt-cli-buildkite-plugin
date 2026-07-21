# oblt-cli-buildkite-plugin

[![usages](https://img.shields.io/badge/usages-white?logo=buildkite&logoColor=blue)](https://github.com/search?q=elastic%2Foblt-cli+%28path%3A.buildkite%29&type=code)

A Buildkite plugin to set up oblt-cli.

> [!NOTE]
> This plugin does not provide a way to automatically download the latest version of `oblt-cli` to ensure that the used version is stable and the plugin is reproducible.
> If you don't provide both the `version` or `version-file` input, then the default version defined in [.default-oblt-cli-version](.default-oblt-cli-version) will be used.
> The default version will be updated by updatecli when a new version of `oblt-cli` is available. Only maintainers will decide to merge the PR created by updatecli to update the version.

## Properties
| Name                         | Type     | Default            | Description                                                                                                         |
|------------------------------|----------|--------------------|---------------------------------------------------------------------------------------------------------------------|
| `version`                    | `string` | `8.0.4`            | The version of the oblt-cli to install.                                                                             |
| <nobr>`version-file`</nobr>  | `string` | -                  | The file to get the version from. If both `version` and `version-file` are provided, the plugin will use `version`. |
| `username`                   | `string` | repository name    | The oblt-cli username. Defaults to the repository name derived from `BUILDKITE_REPO` (e.g. `my-project` from `git@github.com:acme-inc/my-project.git`), or `obltmachine` if `BUILDKITE_REPO` is not set. |
| <nobr>`slack-channel`</nobr> | `string` | `#observablt-bots` | The slack channel for oblt-cli notifications                                                                        |
| `command`                    | `string` | -                  | The command to run after setup. Supported value: `credentials`.                                                     |
| <nobr>`cluster-name`</nobr>  | `string` | -                  | The cluster name. Required when `command` is `credentials`.                                                         |

## Usage

```yaml
steps:
  - command: oblt-cli cluster create serverless
    agents:
      provider: gcp # currently only works on the gcp provider
    plugins:
      - elastic/oblt-cli#v0.4.3:
          version-file: .tool-versions

```

### Credentials command

Use `command: credentials` to fetch cluster credentials and export them as masked environment variables, equivalent to [oblt-actions/oblt-cli/cluster-credentials](https://github.com/elastic/oblt-actions/tree/main/oblt-cli/cluster-credentials).

```yaml
steps:
  - command: curl -X GET $${ELASTICSEARCH_HOST}/_cluster/health -u $${ELASTICSEARCH_USERNAME}:$${ELASTICSEARCH_PASSWORD}
    plugins:
      - elastic/oblt-cli#v0.4.3:
          command: credentials
          cluster-name: edge-oblt

```

The following environment variables are exported and masked:

- `ELASTIC_AGENT_STANDALONE_API_KEY`
- `ELASTIC_APM_SERVER_URL`, `ELASTIC_APM_JS_SERVER_URL`, `ELASTIC_APM_JS_BASE_SERVER_URL`
- `ELASTIC_APM_SECRET_TOKEN`, `ELASTIC_APM_API_KEY`
- `ELASTICSEARCH_API_TOKEN`, `ELASTICSEARCH_HOSTS`, `ELASTICSEARCH_HOST`, `ELASTICSEARCH_USERNAME`, `ELASTICSEARCH_PASSWORD`
- `FLEET_ELASTICSEARCH_HOST`, `FLEET_ENROLLMENT_TOKEN`, `FLEET_SERVER_SERVICE_TOKEN`, `FLEET_SERVER_POLICY_ID`, `FLEET_TOKEN_POLICY_NAME`, `FLEET_URL`
- `INGEST_URL`
- `KIBANA_HOST`, `KIBANA_HOSTS`, `KIBANA_FLEET_HOST`, `KIBANA_FLEET_USERNAME`, `KIBANA_FLEET_PASSWORD`, `KIBANA_USERNAME`, `KIBANA_PASSWORD`
- `SYNTHETICS_API_KEY`

## GitHub Token
This plugin requires the `VAULT_GITHUB_TOKEN`, which is set by default in Buildkite agents.

### Permissions
The plugin requires the following GitHub token permissions in the [elastic/observability-test-environments](https://github.com/elastic/observability-test-environments) repository:
```
contents: write
pull_requests: read
```
