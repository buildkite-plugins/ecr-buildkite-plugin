# ECR Buildkite Plugin [![Build status](https://badge.buildkite.com/152a3248fa274dab20f022ff7b68e9de96a4fc3388de29d013.svg?branch=master)](https://buildkite.com/buildkite/plugins-ecr)

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) to login to an ECR repository before running a build step.

This will use standard AWS credentials available [in the environment](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html), or as an [instance role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html) or task role as available. These must be granted [appropriate permissions](https://docs.aws.amazon.com/AmazonECR/latest/userguide/security_iam_id-based-policy-examples.html) for login to succeed and for push and pull to operate.

## Example

This will login docker to ECR prior to running your script.

```yml
steps:
  - command: ./run_build.sh
    plugins:
      - ecr#v2.9.0:
          login: true
```

If you want to log in to ECR on [another account](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-policy-examples.html#IAM_allow_other_accounts):

```yml
steps:
  - command: ./run_build.sh
    plugins:
      - ecr#v2.9.0:
          login: true
          account_ids: "0015615400570"
          region: "ap-southeast-2"
```

If you need to assume a role to perform that login:

```yml
steps:
  - command: ./run_build.sh
    plugins:
      - ecr#v2.9.0:
          login: true
          account-ids: "0015615400570"
          region: "ap-southeast-2"
          assume_role:
            role_arn: "arn:aws:iam::0015615400570:role/demo"
```

## Options

### `login`

Whether to login to your account's ECR.

### `account-ids` (optional)

Either a string, or a list of strings with AWS account IDs that correspond to the Amazon ECR registries that you want to log in to. Make sure to quote these if they start with a 0.

You can use the literal `public.ecr.aws` as a value to authenticate against AWS ECR public registries.

:warning: If you are using [ECR Credential Helper](https://github.com/awslabs/amazon-ecr-credential-helper/) in your docker configuration it is possible you have to add `https://` to your account IDs to prevent an error (see the [corresponding bug report](https://github.com/docker/cli/issues/3665) for more information).

### `no-include-email` (optional)

> Obsolete if using AWS CLI version 1.17.10 or newer.

Add `--no-include-email` to ecr get-login. Required for docker 17.06+, but needs aws-cli 1.11.91+.

### `region` (optional)

Set a specific region for ECR, defaults to `AWS_DEFAULT_REGION` on the agent, or `us-east-1` if none specified.

### `retries` (optional)

Retries login after a delay N times. Defaults to 0.

### `assume-role` (optional)

> Updates AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_SESSION_TOKEN environment variables.

Assume an AWS IAM role before ECR login. Supports `role-arn` and `duration-seconds` (optional) per the [associated AWS CLI command.](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/sts/assume-role.html)

### `profile` (optional)

> Requires AWS CLI version 1.17.10 or greater.

Use a different AWS profile from the default during ECR login.

## License

MIT (see [LICENSE](LICENSE))
