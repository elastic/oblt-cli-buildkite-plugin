# oblt-cli-buildkite-plugin

A Buildkite plugin to set up oblt-cli

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
