# ECR Buildkite Plugin [![Build status](https://badge.buildkite.com/152a3248fa274dab20f022ff7b68e9de96a4fc3388de29d013.svg?branch=master)](https://buildkite.com/buildkite/plugins-ecr)

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) to login to an ECR repository before running a build step.

This will use standard AWS credentials available [in the environment](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html), or as an [instance role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html) or task role as available. These must be granted [appropriate permissions](https://docs.aws.amazon.com/AmazonECR/latest/userguide/security_iam_id-based-policy-examples.html) for login to succeed and for push and pull to operate.

## Example

This will perform a `docker login` to your ECR registries prior to running your step commands.

```yml
steps:
  - command: ./run_build.sh
    plugins:
      - ecr#v2.11.0: ~
```

If you want to log in to ECR on [another account](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-policy-examples.html#IAM_allow_other_accounts):

```yml
steps:
  - command: ./run_build.sh
    plugins:
      - ecr#v2.11.0:
          account-ids: "0015615400570"
          region: "ap-southeast-2"
```

If you need to assume a role to perform that login:

```yml
steps:
  - command: ./run_build.sh
    plugins:
      - ecr#v2.11.0:
          account-ids: "0015615400570"
          region: "ap-southeast-2"
          assume_role:
            role_arn: "arn:aws:iam::0015615400570:role/demo"
```

If you need to assume a role using [Buildkite OIDC](https://buildkite.com/docs/agent/v3/cli-oidc) (no long-lived AWS credentials required):

```yml
steps:
  - command: ./run_build.sh
    plugins:
      - ecr#v2.x.x:
          account-ids: "0015615400570"
          region: "ap-southeast-2"
          assume-role:
            role-arn: "arn:aws:iam::0015615400570:role/demo"
            oidc: true
```

> [!NOTE]
> OIDC requires a Buildkite OIDC identity provider configured in your AWS account. See the [aws-assume-role-with-web-identity plugin](https://github.com/buildkite-plugins/aws-assume-role-with-web-identity-buildkite-plugin) for setup instructions.

### Using ECR Credential Helper

You can use the [Amazon ECR credential helper](https://github.com/awslabs/amazon-ecr-credential-helper) instead of the traditional AWS CLI login methods. This provides automatic credential management and better performance through caching:

```yml
steps:
  - command: ./run_build.sh
    plugins:
      - ecr#v2.11.0:
          credential-helper: true
```

The credential helper works with any ECR registries you have access to, without needing to specify account IDs (though you can still specify them for explicit control):

```yml
steps:
  - command: ./run_build.sh
    plugins:
      - ecr#v2.11.0:
          credential-helper: true
          account-ids:
            - "123456789012"
            - "public.ecr.aws"
```

By default, the credential helper suppresses credential storage errors. The ECR credential helper provides credentials on-demand to Docker rather than storing them persistently, so Docker's store/delete operations aren't applicable. If you want to see these error messages, you can disable this behavior:

```yml
steps:
  - command: ./run_build.sh
    plugins:
      - ecr#v2.11.0:
          credential-helper: true
          credential-helper-ignore-creds-storage: false
```

## Options

### `login` (optional)

Whether to login to your account's ECR. Defaults to `true`. Set to `false` to disable ECR authentication.

### `credential-helper` (optional)

Use the [Amazon ECR credential helper](https://github.com/awslabs/amazon-ecr-credential-helper) instead of AWS CLI ECR login methods.

**Requires** the `amazon-ecr-credential-helper` binary to be installed and available in `PATH`.

### `credential-helper-ignore-creds-storage` (optional)

When using the ECR credential helper, this option controls the `AWS_ECR_IGNORE_CREDS_STORAGE` environment variable. **Defaults to `true`**.

The ECR credential helper provides credentials on-demand to Docker rather than storing them persistently. Docker's credential store and delete operations don't apply to this workflow. When set to `true` (the default), the credential helper silently ignores (returns success for) these store/delete operations rather than returning errors. This prevents benign error messages during `docker login` and `docker logout` operations.

You can set this to `false` if you want to see the error messages when Docker attempts these operations, though this is generally not recommended as the errors are expected and harmless.

**Note**: This option only applies when `credential-helper: true` is set.

### `account-ids` (optional)

Either a string, or a list of strings with AWS account IDs that correspond to the Amazon ECR registries that you want to log in to. Make sure to quote these if they start with a 0.

If not specified, the plugin automatically uses your current AWS account ID (obtained via `aws sts get-caller-identity`).

You can use the literal `public.ecr.aws` as a value to authenticate against the [AWS ECR Public](https://docs.aws.amazon.com/AmazonECR/latest/public/), which hosts publicly available container images. This is useful when you need to push to or pull from public ECR repositories. Note that public ECR authentication always uses the `us-east-1` region regardless of your configured region.

:warning: If you are using the [Amazon ECR Credential Helper](https://github.com/awslabs/amazon-ecr-credential-helper) in your Docker configuration it is possible you have to add `https://` to your account IDs to prevent an error (see the [corresponding bug report](https://github.com/docker/cli/issues/3665) for more information).

### `no-include-email` (optional)

> Obsolete if using AWS CLI version 1.17.10 or newer.

Add `--no-include-email` to ecr get-login. Required for Docker 17.06+, but needs aws-cli 1.11.91+.

### `region` (optional)

Set a specific region for ECR, defaults to `AWS_DEFAULT_REGION` on the agent, or `us-east-1` if none specified.

### `retries` (optional)

Retries login after a delay N times. Defaults to 0.

### `assume-role` (optional)

> Updates AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_SESSION_TOKEN environment variables.

Assume an AWS IAM role before ECR login. Supports the following sub-options:

#### `assume-role.role-arn` (required when using `assume-role`)

ARN of the IAM role to assume.

#### `assume-role.duration-seconds` (optional)

Duration in seconds for the assumed role session. Defaults to `3600`. Passed as `--duration-seconds` to the STS CLI command.

#### `assume-role.oidc` (optional)

When `true`, exchanges a [Buildkite OIDC token](https://buildkite.com/docs/agent/v3/cli-oidc) for AWS credentials using `sts:AssumeRoleWithWebIdentity` instead of the standard `sts:AssumeRole`. This avoids the need for any long-lived AWS credentials on the agent.

Defaults to `false`.

For AWS account setup (OIDC identity provider and IAM role trust policy), refer to the [aws-assume-role-with-web-identity plugin documentation](https://github.com/buildkite-plugins/aws-assume-role-with-web-identity-buildkite-plugin).

### `profile` (optional)

> Requires AWS CLI version 1.17.10 or greater.

Use a different AWS profile from the default during ECR login.

## Developing

Use docker to run the [Plugin Tester](https://github.com/buildkite-plugins/buildkite-plugin-tester):

```bash
docker run --rm -ti -v "${PWD}":/plugin buildkite/plugin-tester:latest
```

## License

MIT (see [LICENSE](LICENSE))
