# Kubernetes Context Switcher

A simple bash script to switch between different Kubernetes clusters and AWS profiles following security best practices.
Created to avoid manually exporting environment variables and to ensure consistent configuration across different contexts.

## Requirements

- AWS CLI installed
- Kubernetes configuration files at `~/.kube-<context>/config`
- AWS credentials configured in `~/.aws/credentials` or `~/.aws/config`

## Usage Example

1. Create a `contexts.txt` file in the same directory as the script:

```
dev,staging,prod
```

2. Ensure your Kubernetes config files exist at:

```
~/.kube-dev/config
~/.kube-staging/config
~/.kube-prod/config
```

3. Make sure corresponding AWS profiles exist in your AWS credentials file:

```ini
[dev]
# Your dev credentials or SSO config

[staging]
# Your staging credentials or SSO config

[prod]
# Your production credentials or SSO config
```

4. Source the script:

```bash
. kube-context-switcher.sh
```

The script will update your current shell environment variables with the appropriate `KUBECONFIG` and `AWS_PROFILE`.
