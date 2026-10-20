# Terraform Fundamentals

My hands-on journey learning Terraform and Infrastructure as Code (IaC), one
stage at a time. Each numbered folder is a self-contained project with its own
`.tf` files and its own README explaining what it covers and the problems I hit
along the way.

## Stages

| Stage | Folder | What it covers |
|---|---|---|
| 1 | [`01-local-fundamentals`](01-local-fundamentals/) | Core HCL on the `local` + `random` providers — variables, `for_each`, `count`, lifecycle rules, data sources, outputs. No cloud account needed. |
| 2 | [`02-aws-iam-s3`](02-aws-iam-s3/) | First real AWS project — IAM users, IAM policies, and S3 buckets modelling a least-privilege access-control scenario (Allow vs. explicit Deny). |
| 3 | [`03-aws-iam-s3-Advanced`](03-aws-iam-s3-Advanced/) | Scaling up — multiple users via `for_each`, IAM groups with group-level policies, reusable modules, and per-user prefix isolation using the `${aws:username}` policy variable. |

## How This Repo Is Organised

Each stage stands on its own. To run one, `cd` into its folder and use the
normal Terraform loop:

```bash
cd 01-local-fundamentals      # or 02-aws-iam-s3
terraform init
terraform plan
terraform apply
terraform destroy             # when you're done
```

Stage 2 creates real AWS resources, so authenticate to your own account and
confirm it first:

```bash
aws sts get-caller-identity   # check the Account is the one you expect
```

## Conventions

- Terraform state (`*.tfstate`), the `.terraform/` provider cache, and local
  build output are git-ignored — never committed.
- No credentials or account IDs live in the committed files.
- New topics (modules, remote state, EC2, etc.) get added as new numbered
  stages so the history reads like a learning journal.
