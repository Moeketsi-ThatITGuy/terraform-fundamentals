# Terraform Fundamentals — AWS IAM & S3 Access Control

A hands-on Terraform project for learning Infrastructure as Code (IaC) against
real AWS, using IAM users, IAM policies, and S3 buckets to model a simple
least-privilege access-control scenario.

> Earlier in my learning I built a **local-only** version of this project
> (using the `local` and `random` providers, no cloud account needed) to get
> comfortable with HCL, variables, `for_each`, `count`, lifecycle rules, data
> sources, and outputs. This repo now documents the AWS stage.

## What This Project Does

Models two team members and two S3 buckets, then uses IAM policies to enforce
who can touch what:

- **Intern (`Mpho`)** — read-only on the intern bucket, and an explicit
  **deny** on the engineer bucket.
- **Cloud Engineer (`Moeketsi`)** — full access to both buckets.

This is a small exercise in IAM policy evaluation, especially how an explicit
`Deny` always beats an `Allow`.

## Resources Created

| Resource | Purpose |
|---|---|
| `aws_iam_user.intern` | The intern user (`Mpho`) |
| `aws_iam_user.cloud_engineer` | The engineer user (`Moeketsi`) |
| `aws_s3_bucket.intern_bucket` | Bucket the intern can read |
| `aws_s3_bucket.Cloud_engineer_Bucket` | Bucket only the engineer can use |
| `aws_iam_policy.intern_policy` | Read intern bucket + deny engineer bucket |
| `aws_iam_policy.cloud_engineer_policy` | Full access to both buckets |
| `aws_iam_user_policy_attachment.*` | Attach each policy to its user |

## Project Structure

```
02-aws-iam-s3/
├── providers.tf       # AWS provider configuration
├── variables.tf       # User names and bucket names
├── main.tf            # IAM users, policies, attachments, S3 buckets
├── outputs.tf         # User and bucket names
└── terraform.tfvars   # (optional) variable overrides
```

## Concepts Covered

- The AWS provider and credential resolution (reads `~/.aws`, no keys in code)
- `aws_iam_user`, `aws_iam_policy`, `aws_iam_user_policy_attachment`
- Writing IAM policy documents with `jsonencode`
- Allow vs. explicit Deny, and why Deny wins
- `aws_s3_bucket`
- Input variables and outputs
- Verifying access safely with the IAM Policy Simulator (no login, no keys)

## How to Run

Authenticate to **your own** AWS account first, then confirm which account
you're pointed at before applying anything:

```bash
aws sts get-caller-identity   # check the Account field is the one you expect
terraform init
terraform plan                # read-only preview
terraform apply               # creates real resources
```

Tear everything down when you're done so nothing lingers or costs money:

```bash
terraform destroy
```

## Verifying Access (no credentials needed)

The IAM Policy Simulator proves the policies behave as intended — it logs in as
no one and needs only `iam:SimulatePrincipalPolicy`. Replace `<ACCOUNT_ID>` with
your own account and quote any ARN containing `*`:

```bash
# Intern should be ALLOWED on their own bucket
aws iam simulate-principal-policy \
  --policy-source-arn "arn:aws:iam::<ACCOUNT_ID>:user/Mpho" \
  --action-names s3:GetObject s3:ListBucket \
  --resource-arns "arn:aws:s3:::intern-bucket-moeketsi-2026" \
                  "arn:aws:s3:::intern-bucket-moeketsi-2026/*"

# Intern should be DENIED on the engineer bucket
aws iam simulate-principal-policy \
  --policy-source-arn "arn:aws:iam::<ACCOUNT_ID>:user/Mpho" \
  --action-names s3:GetObject s3:PutObject \
  --resource-arns "arn:aws:s3:::engineer-bucket-moeketsi-2026/*"

# Engineer should be ALLOWED on both
aws iam simulate-principal-policy \
  --policy-source-arn "arn:aws:iam::<ACCOUNT_ID>:user/Moeketsi" \
  --action-names s3:GetObject s3:PutObject \
  --resource-arns "arn:aws:s3:::intern-bucket-moeketsi-2026/*" \
                  "arn:aws:s3:::engineer-bucket-moeketsi-2026/*"
```

Expected results:

- Intern → own bucket: **allowed**
- Intern → engineer bucket: **explicitDeny**
- Engineer → both buckets: **allowed**

## Problems I Encountered and How I Fixed Them

### 1. `zsh: no matches found` on ARNs ending in `/*`

**Problem:** Running a simulator command directly, zsh tried to glob the `*` in
`arn:aws:s3:::my-bucket/*` against local files, found none, and failed before
the AWS call ran.

**Fix:** Quote any ARN containing `*`:

```bash
--resource-arns "arn:aws:s3:::my-bucket" "arn:aws:s3:::my-bucket/*"
```

### 2. Keeping account IDs out of a public repo

**Problem:** It's easy to hardcode a 12-digit account ID into a helper command
or script. That shouldn't be published to a public repo.

**Fix:** Pass the account ID in at runtime (`<ACCOUNT_ID>` placeholder, an
env var, or `aws sts get-caller-identity`) so nothing sensitive lands in git.

### 3. Keeping Terraform state out of git

**Problem:** IAM/S3 state can contain account details and sensitive values, and
this repo is public.

**Fix:** `.gitignore` excludes `*.tfstate`, `*.tfstate.*`, and `.terraform/`.
Verified with `git check-ignore` before pushing.

## Key Takeaways

- An explicit `Deny` in IAM always overrides an `Allow` — the core rule this
  project demonstrates.
- The IAM Policy Simulator verifies access without creating keys or logging in
  as anyone — the least-privilege way to test.
- Never hardcode account IDs or credentials in files headed for a public repo.
- Never commit Terraform state; confirm it's ignored before pushing.
- Always confirm `aws sts get-caller-identity` before `apply` or `destroy` so
  you act on the account you intend.

## Commands Used

```bash
aws sts get-caller-identity   # confirm the target account
terraform init                # download the AWS provider
terraform plan                # preview changes
terraform apply               # build
terraform destroy             # tear down
terraform state list          # see what's being managed
```
