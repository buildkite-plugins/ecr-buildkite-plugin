# ECR Buildkite Plugin

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) to login to an ECR repository before running a build step.

## Example

This will login docker to ECR prior to running your script.

```yml
steps:
  - command: ./run_build.sh
    plugins:
      - ecr#v2.0.0:
          login: true
```

If you want to log in to ECR on [another account](https://docs.aws.amazon.com/AmazonECR/latest/userguide/RepositoryPolicyExamples.html#IAM_allow_other_accounts):


```yml
steps:
  - command: ./run_build.sh
    plugins:
      - ecr#v2.0.0:
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

### `region` (optional)

Set a specific region for ECR, defaults to the current

### `retries` (optional)

Retries login after a delay N times. Defaults to 0.

## License

MIT (see [LICENSE](LICENSE))
