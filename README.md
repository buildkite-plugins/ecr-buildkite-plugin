# ECR Buildkite Plugin

__This is designed to run with Buildkite Agent v3.x beta. Plugins are not yet supported in Buildkite Agent v2.x.__

Login to ECR in your build steps.

## Example

This will login docker to ECR prior to running your script. 

```yml
steps:
  - command: ./run_build.sh
    plugins:
      lox/ecr#v1.0.0:
        login: "true"
```

## Options

### `login`

Whether to login to your account's ECR.

### `account-ids`

A list of AWS account IDs that correspond to the Amazon ECR registries that you want to log in to.

## License

MIT (see [LICENSE](LICENSE))