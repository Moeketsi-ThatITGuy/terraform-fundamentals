# Terraform Fundamentals — DevOps Team File Server

A hands-on Terraform project built to practice core Infrastructure as Code (IaC)
concepts using only local resources. No cloud account needed.

## What This Project Does

Creates a local file-based system that manages a DevOps team's documentation:
a README file stamped with a random team ID, per-environment config files,
per-member role files, and a set of numbered log files. Everything is written
under `/tmp/devops-server`, so it's completely safe to build and destroy.

## Concepts Covered

- HCL (HashiCorp Configuration Language) basics
- Multiple providers (`local` + `random`)
- Input variables (string, set, map, number)
- `terraform.tfvars` for assigning values
- Resource attributes and references
- Implicit (resource-to-resource) dependencies
- `for_each` with sets and maps
- `count` with a dynamic variable
- Lifecycle rules (`create_before_destroy`)
- Data sources (`data "local_file"`)
- Output variables (including `for` expressions over resources)
- Terraform state

## Project Structure

```
01-local-fundamentals/
├── providers.tf       # Provider configuration (local + random)
├── variables.tf       # Input variable declarations
├── main.tf            # All resources + a data source
├── outputs.tf         # Output values
└── terraform.tfvars   # Variable values
```

## File Structure Created

```
/tmp/devops-server/
├── read_me.txt                 # README stamped with the random_id
├── enviroments/
│   ├── dev.txt                 # for_each over a set
│   ├── staging.txt
│   └── prod.txt
├── roles/
│   ├── moeketsi.txt            # for_each over a map (key: name, value: role)
│   ├── emmanuel.txt
│   └── james.txt
└── logs/
    ├── 0.txt                   # count
    ├── 1.txt
    ├── 2.txt
    └── 3.txt
```

## How It Maps to the Code

| Concept | Where |
|---|---|
| `random` provider | `random_id.id` generates an 8-byte hex ID |
| `create_before_destroy` | `local_file.read_me` lifecycle block |
| `for_each` (set) | `local_file.enviroments_folder` over `var.enviroments` |
| `for_each` (map) | `local_file.teams` over `var.team_members` |
| `count` | `local_file.log_count` driven by `var.log_count` |
| data source | `data "local_file" "read_back"` reads the README back |
| `for` expression in output | `outputs.tf` builds filename lists from the resources |

## Problems I Encountered and How I Fixed Them

### 1. Terraform State Lock Error

**Problem:** `terraform plan` failed with `Error acquiring the state lock`. A
previous process crashed mid-run and left the state locked. `terraform
force-unlock` also failed with `Local state cannot be unlocked by another
process`.

**Fix:** Found the stuck processes, killed them, then removed the lock file:

```bash
ps aux | grep terraform
kill -9 <PID>
rm -f .terraform.tfstate.lock.info
```

### 2. Provider Source Copy-Paste Bug

**Problem:** Both providers pointed at `hashicorp/local` — I copied the local
provider source for `random` too.

```hcl
random = {
  source = "hashicorp/local"   # should be hashicorp/random
}
```

**Fix:** Changed the random provider source to `hashicorp/random`.

### 3. Space in a Variable Name

**Problem:** A space in a variable name is invalid HCL.

```hcl
variable "adopt folder" {}   # spaces not allowed
```

**Fix:** Used an underscore: `"adopt_folder"`.

### 4. Forgot to Save Files

**Problem:** Ran `terraform init`/`plan` but the old config kept showing — the
file wasn't saved.

**Fix:** Save (`⌘ + S`) before every terraform command, or enable auto-save.

### 5. Confusing `count` with `count.index`

**Problem:** Mixed up the variable with the loop index.

```hcl
filename = "${var.base_path}/logs/${var.log_count.index}.txt"  # wrong
```

**Fix:** `var.log_count` is the total; `count.index` is the current iteration:

```hcl
resource "local_file" "log_count" {
  count    = var.log_count
  filename = "${var.base_path}/logs/${count.index}.txt"
}
```

### 6. Accessing a `count` Resource Without an Index

**Problem:** Referencing a counted resource without an index gave `Missing
resource instance key`.

**Fix:** A counted resource is a list — index it or use the splat `[*]`:

```hcl
value = local_file.log_count[0].content   # one instance
value = local_file.log_count[*].content   # all instances
```

### 7. Stray Dot/Slash in a File Path

**Problem:** An extra slash produced broken filenames like `/.txt`.

```hcl
filename = "${var.base_path}/roles/${each.key}/.txt"   # creates "/.txt"
```

**Fix:** Removed the stray slash:

```hcl
filename = "${var.base_path}/roles/${each.key}.txt"    # creates "moeketsi.txt"
```

## Key Takeaways

- Terraform merges ALL `.tf` files in a directory — no imports needed.
- File names (`main.tf`, `variables.tf`) are convention, not requirement.
- `for_each` beats `count` for named resources — removing one item doesn't
  shift the others.
- A `count` resource becomes a list; index it or splat it.
- `terraform.tfvars` both supplies values for variables without defaults AND
  overrides existing defaults.
- Check for stuck terraform processes when you hit a state lock error.

## Commands Used

```bash
terraform init          # download providers
terraform plan          # preview changes
terraform apply         # build
terraform destroy       # tear down
terraform state list    # see what's being managed
terraform fmt           # format the config
```
