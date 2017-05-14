# ECR Buildkite Plugin

__This is designed to run with Buildkite Agent v3.x beta. Plugins are not yet supported in Buildkite Agent v2.x.__

Interact with [Amazon Elastic Container Registry (ECR)](https://aws.amazon.com/ecr/) in your build steps.

Supports authenticating docker and removing tags/images.

## Login Example

This will login docker to ECR prior to running your script. 

```yml
steps:
  - command: ./run_build.sh
    plugins:
      lox/ecr#v1.0.0:
        login: "true"
```

## Delete Example

This will delete a set of tags used by the docker-compose plugin:

```yml
steps:
  - plugins:
      lox/ecr#v1.0.0:
        delete: 
          repository: myimagerepo
          tags: "${BUILDKITE_PIPELINE_SLUG}-app-build-${BUILDKITE_BUILD_NUMBER}""
```

See http://docs.aws.amazon.com/cli/latest/reference/ecr/batch-delete-image.html for more detail.

## Options

### `login`

Whether to login to your account's ECR.

### `account-ids`

A list of AWS account IDs that correspond to the Amazon ECR registries that you want to log in to.

## License

MIT (see [LICENSE](LICENSE))