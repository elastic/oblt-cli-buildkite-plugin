# oblt-cli-buildkite-plugin

A Buildkite plugin to set up oblt-cli

## Usage

```yaml
steps:
  - command: oblt-cli cluster create serverless
    env: 
      GITHUB_TOKEN: ${GITHUB_TOKEN}
    plugins:
      - elastic/oblt-cli#v1.0.0:
          version: 7.3.0

```
