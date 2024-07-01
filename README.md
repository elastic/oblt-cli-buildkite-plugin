# oblt-cli-buildkite-plugin


## Usage

```yaml
steps:
  - command: integration-test.sh
    plugins:
      - elastic/oblt-cli#v1.0.0:
          github-token: ${GITHUB_TOKEN}
```
