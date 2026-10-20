# Terraform — Groups & Per-User Prefix Access (Advanced IAM + S3)

The third stage of my Terraform journey. It scales up the stage-2 single-user
idea into a realistic team setup: **multiple** interns and engineers, grouped,
with permissions applied at the **group** level and each user confined to their
own folder inside a shared bucket.

## What This Project Does

Models two teams and two S3 buckets, and enforces access entirely through IAM:

- **Interns** (`Mpho`, `Lesedi`, `Mpumi`) — in an `interns` group. Can list the
  whole intern bucket, but can only read/write objects inside their own prefix
  (`intern-bucket/<their-name>/`). Fully denied on the engineer bucket.
- **Engineers** (`Andile`, `Ntokozo`) — in an `engineers` group. Full access to
  both buckets, and each also scoped to their own prefix in the engineer bucket.

## Architecture

```
USERS        interns (for_each)        engineers (for_each)
                 │                          │
GROUPS      interns group             engineers group
                 │                          │
POLICIES    attached at GROUP level (not per user)
                 │
   ├── list-the-bucket policy (whole bucket)
   └── prefix policy using ${aws:username}  →  each user limited to their folder

BUCKETS     intern-bucket/                engineer-bucket/
              ├── Mpho/   (only Mpho)        ├── Andile/   (only Andile)
              ├── Lesedi/ (only Lesedi)      └── Ntokozo/  (only Ntokozo)
              └── Mpumi/  (only Mpumi)
```

## Project Structure

```
03-aws-iam-s3-Advanced/
├── providers.tf              # AWS provider
├── variables.tf             # intern + engineer name sets
├── main.tf                  # users, groups, memberships, policies, module calls
├── outputs.tf               # (empty — optional)
└── modules/
    ├── s3-bucket/           # reusable bucket module (bucket_name, team)
    └── aws-groups/          # reusable IAM group module (group_name, path)
```

## Key Concepts Covered

- Multiple users with `for_each` over a `set(string)`
- IAM groups and `aws_iam_group_membership` (one membership per group, whole list)
- **Group-level** policies (`aws_iam_group_policy`) instead of per-user
- Reusable **modules** with inputs/outputs, called with local `./modules/...` paths
- Implicit dependencies — policies reference `module.*.bucket_arn`, so Terraform
  creates the buckets first automatically (no `depends_on` needed)
- **Per-user prefix isolation** with the `${aws:username}` policy variable
- Splitting bucket-level (`ListBucket`) from object-level (`GetObject`/`PutObject`)
  actions, since they need different resource ARNs

## The Access Model (and why it works)

The headline idea is isolating each user to their own folder with a *single*
group policy rather than one policy per person:

```hcl
Resource = "${bucket_arn}/$${aws:username}/*"
```

- `aws:username` is resolved by AWS at request time to whoever is calling, so
  one policy behaves differently per user.
- The `$$` is a Terraform escape — it writes a literal `${...}` into the policy
  so **AWS** (not Terraform) does the substitution.

Two rules this stage taught me:

1. **An `Allow` can't be cancelled by another `Allow`.** For true isolation, the
   group policy must *not* grant whole-bucket object access — otherwise it
   overrides the prefix restriction. Listing is granted bucket-wide on purpose
   (everyone can see folders exist); only reading/writing contents is scoped.
2. **S3 has no real folders.** `Mpho/report.txt` is just an object whose key
   contains a `/`. The prefix "folder" appears when the first object is written;
   nothing needs to pre-create it for the permissions to work.

## How to Run

```bash
aws sts get-caller-identity   # confirm the account is YOUR own
terraform init
terraform plan
terraform apply
terraform destroy             # clean up when done
```

> S3 bucket names are globally unique — if the names in `main.tf` are taken,
> change them before applying.
