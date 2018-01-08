# ECR Buildkite Plugin

__This is designed to run with Buildkite Agent v3.x beta. Plugins are not yet supported in Buildkite Agent v2.x.__

Login to ECR in your build steps.

## Example

This will login docker to ECR prior to running your script.

```yml
steps:
  - command: ./run_build.sh
    plugins:
      ecr#v1.1.3:
        login: true
```

If you want to log in to ECR on [another account](https://docs.aws.amazon.com/AmazonECR/latest/userguide/RepositoryPolicyExamples.html#IAM_allow_other_accounts):


```yml
steps:
  - command: ./run_build.sh
    plugins:
      ecr#v1.1.3:
        login: true
        account_ids: "0015615400570"
```

## Options

### `login`

Whether to login to your account's ECR.

### `account-ids` (optional)

Either a string, or a list of strings with AWS account IDs that correspond to the Amazon ECR registries that you want to log in to. Make sure to quote these if they start with a 0.

### `no-include-email` (optional)

Add `--no-include-email` to ecr get-login. Required for docker 17.06+, but needs aws-cli 1.11.91+.

### `registry-region` (optional)

Set a specific region for ECR, defaults to the current

## License

MIT (see [LICENSE](LICENSE))
