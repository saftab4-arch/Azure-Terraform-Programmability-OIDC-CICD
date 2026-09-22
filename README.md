# Azure Terraform Programmability OIDC CI/CD

# Azure Terraform Programmability with GitHub Actions OIDC CI/CD

A hands-on Azure infrastructure lab focused on advanced Terraform programmability and a production-style GitHub Actions CI/CD workflow using Microsoft Entra ID and OpenID Connect (OIDC).

The goal of this lab was not only to deploy Azure infrastructure, but to practice reusable Terraform patterns, remote state, security scanning, pull-request validation, and passwordless Azure authentication from GitHub Actions.

---

## Project Objectives

This lab covered:

- Terraform `for_each`
- Maps and objects
- Nested data structures
- Locals
- Conditional expressions
- Terraform functions
- Dynamic resource creation
- Azure Virtual Network and subnet deployment
- Network Security Groups
- Dynamic NSG rules
- NIC creation
- Linux VM deployment
- Azure Blob remote state
- Git feature branch workflow
- Pull Requests
- GitHub Actions CI/CD
- Microsoft Entra ID App Registration
- GitHub Actions OIDC federation
- Azure RBAC
- TFLint
- Checkov
- Terraform Plan validation
- Automated Terraform Apply

---

## Architecture

The Terraform configuration was designed to create a three-tier Azure network:

```text
Azure Subscription
│
└── Resource Group
    │
    └── VNet
        │
        ├── Web Subnet
        │   ├── NSG
        │   ├── NIC
        │   └── Linux VM
        │
        ├── App Subnet
        │   ├── NSG
        │   ├── NIC
        │   └── Linux VM
        │
        └── DB Subnet
            ├── NSG
            ├── NIC
            └── Linux VM
```

Rather than manually writing separate Terraform resources for each tier, maps, objects, `for_each`, locals, and conditional logic were used to generate infrastructure dynamically.

---

## Terraform Repository Structure

```text
.
├── .github/
│   └── workflows/
│       ├── terraform-ci.yml
│       └── terraform-cd.yml
├── .gitignore
├── .terraform.lock.hcl
├── backend.tf
├── locals.tf
├── main.tf
├── providers.tf
├── terraform.tfvars
├── variables.tf
└── versions.tf
```

---

## Terraform Programmability

A major focus of this lab was moving away from repetitive resource blocks.

The environment was represented using structured Terraform data.

Example concept:

```hcl
subnets = {
  web = {
    address_prefix = "10.20.1.0/24"
  }

  app = {
    address_prefix = "10.20.2.0/24"
  }

  db = {
    address_prefix = "10.20.3.0/24"
  }
}
```

Resources could then use:

```hcl
for_each = var.subnets
```

and reference the current object using:

```hcl
each.key
each.value
```

This allowed a single Terraform resource block to create multiple Azure resources.

---

## Locals and Standardized Naming

Terraform locals were used to centralize reusable values such as:

- Naming prefixes
- VM sizing
- Common tags
- Environment information

Example naming pattern:

```text
dev-lab4-web-vm
dev-lab4-app-vm
dev-lab4-db-vm
```

Common tags included:

```text
Environment = dev
ManagedBy   = Terraform
Project     = Terraform-Lab4
```

This provided consistent naming and tagging across dynamically generated resources.

---

## Azure Remote State

Terraform state was stored remotely using an Azure Storage Account and Blob Container.

Conceptual structure:

```text
Azure Storage Account
│
└── Blob Container: tfstate
    │
    └── lab4/terraform.tfstate
```

The remote backend allowed both the local workstation and GitHub Actions to work with the same Terraform state.

Terraform state locking also protected the state from simultaneous modification.

---

# GitHub Development Workflow

Infrastructure changes were developed on a feature branch:

```text
feature/lab4-infrastructure
```

The workflow was:

```text
Write Terraform
      ↓
Feature Branch
      ↓
Commit
      ↓
Push
      ↓
Pull Request
      ↓
CI Validation
      ↓
Review Terraform Plan
      ↓
Merge to Main
      ↓
CD Deployment
```

Infrastructure was not intentionally deployed from the feature branch.

---

# GitHub Actions CI

The CI workflow ran against the Pull Request before the code was merged into `main`.

The pipeline included:

```text
Checkout Repository
        ↓
Setup Terraform
        ↓
Terraform Format Check
        ↓
Azure Login using OIDC
        ↓
Terraform Init
        ↓
Terraform Validate
        ↓
TFLint
        ↓
Checkov
        ↓
Terraform Plan
```

The final successful CI plan reported:

```text
Plan: 20 to add, 0 to change, 0 to destroy.
```

This allowed the infrastructure changes to be reviewed before deployment.

---

## Terraform Formatting

```bash
terraform fmt -check -recursive
```

Ensures Terraform configuration follows standard formatting.

---

## Terraform Validation

```bash
terraform validate
```

Checks whether the Terraform configuration is syntactically and internally valid.

---

## TFLint

TFLint was added as an additional Terraform linting and quality check.

It helps identify Terraform configuration problems and provider-specific issues before deployment.

---

## Checkov

Checkov was used for Infrastructure-as-Code security scanning.

One VM-extension policy was intentionally excluded for this lab because VM extensions were not part of the configuration:

```text
CKV_AZURE_50
```

The rest of the Terraform configuration continued through the security scan.

This demonstrated that security exceptions should be explicit rather than disabling the entire security scanner.

---

# Passwordless Azure Authentication with OIDC

One of the most important parts of this lab was removing the need for a long-lived Azure client secret.

A Microsoft Entra ID App Registration was created for GitHub Actions:

```text
github-terraform-lab4
```

A federated credential established trust between the GitHub repository and Microsoft Entra ID.

Conceptually:

```text
GitHub Actions
      │
      │ requests OIDC token
      ▼
GitHub OIDC Provider
      │
      │ signed identity token
      ▼
Microsoft Entra ID
      │
      │ validates repository/branch identity
      ▼
Entra Application / Service Principal
      │
      │ Azure RBAC
      ▼
Azure Subscription
```

No Azure client secret was required.

---

## Azure RBAC

The GitHub/Entra workload identity was assigned the Azure:

```text
Contributor
```

role for the lab.

This provided the authorization Terraform required to create and manage the Azure resources.

Authentication and authorization remained separate concepts:

```text
OIDC / Entra ID
      ↓
Who are you?

Azure RBAC
      ↓
What are you allowed to do?
```

---

## GitHub Actions Configuration

The GitHub repository contained Azure identity configuration for the workflow:

```text
AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
```

No Azure client secret was stored.

GitHub Actions requested a temporary OIDC identity token during workflow execution.

---

# Continuous Deployment

After CI passed and the Terraform plan was reviewed, the Pull Request was merged into:

```text
main
```

The merge triggered the CD workflow.

```text
PR Merge
   ↓
main
   ↓
GitHub Actions CD
   ↓
OIDC Authentication
   ↓
Microsoft Entra ID
   ↓
Azure RBAC
   ↓
Terraform Init
   ↓
Terraform Apply
   ↓
Azure
```

The Azure Resource Group and networking resources were successfully created through the GitHub Actions workflow.

---

# Troubleshooting Performed

This lab also included several real troubleshooting scenarios.

### SSH Public Key Path

Initially Terraform referenced a local SSH key path.

This worked locally but failed inside GitHub Actions because the GitHub-hosted runner did not have the local workstation's filesystem.

The configuration was changed so the CI environment could access the required public key appropriately.

### Duplicate Terraform Resource

A duplicate:

```hcl
resource "azurerm_linux_virtual_machine" "vms"
```

block caused Terraform initialization to fail.

Terraform resource addresses must be unique within a module.

The duplicate block was identified and removed.

### Checkov Policy

Checkov flagged:

```text
CKV_AZURE_50
```

for the Linux VM resources.

Because VM extensions were intentionally outside the scope of this lab, the policy was explicitly excluded while retaining the remaining Checkov security checks.

### Azure VM Capacity

During CD, Azure returned:

```text
409 Conflict
SkuNotAvailable
```

for:

```text
Standard_B1s
```

in East US.

This demonstrated an important infrastructure behavior:

Terraform configuration can be valid and CI/CD can function correctly while an Azure deployment still fails because of cloud-provider capacity constraints.

Terraform successfully created other resources before Azure rejected the VM allocation.

---

# Partial Terraform Apply

The VM capacity failure also demonstrated that Terraform does not automatically roll back every previously created resource when one resource fails.

Conceptually:

```text
terraform apply
      ↓
Networking created       ✅
NSGs created             ✅
NICs created             ✅
VM allocation attempted
      ↓
Azure SKU unavailable    ❌
      ↓
Terraform exits with error
```

Successfully created resources remained represented in Terraform state and could later be destroyed.

---

# Cleanup and Remote State Lesson

The infrastructure was destroyed using:

```bash
terraform destroy
```

During cleanup, the Azure Storage Account containing the remote Terraform state was deleted before Terraform finished writing its final state.

Terraform therefore successfully destroyed the infrastructure but could no longer persist the updated state or release its backend lock.

This produced errors similar to:

```text
Failed to Save state
Failed to persist state to backend
Error releasing the state lock
```

Important lesson:

```text
1. terraform destroy
2. Wait for "Destroy complete!"
3. Delete Terraform backend
4. Remove RBAC
5. Remove OIDC federation
6. Delete Entra application
7. Remove GitHub configuration
```

Never remove the backend while Terraform is actively using it.

---

# Key Lessons

This lab connected several technologies that are often learned separately:

```text
Terraform
   +
Azure
   +
Remote State
   +
Git
   +
Pull Requests
   +
GitHub Actions
   +
TFLint
   +
Checkov
   +
Microsoft Entra ID
   +
OIDC
   +
Azure RBAC
```

The biggest takeaway was understanding that Terraform deployment is more than writing `.tf` files.

A professional workflow includes:

- Reusable Terraform configuration
- Remote state
- Version control
- Feature branches
- Pull Requests
- Automated validation
- Infrastructure security scanning
- Plan review
- Short-lived workload authentication
- RBAC authorization
- Controlled deployment to Azure
- Troubleshooting failed cloud deployments
- Clean infrastructure teardown

---

## Final Workflow

```text
Developer
   ↓
Feature Branch
   ↓
Terraform Code
   ↓
GitHub Pull Request
   ↓
CI
├── fmt
├── OIDC authentication
├── init
├── validate
├── TFLint
├── Checkov
└── plan
   ↓
Review
   ↓
Merge → main
   ↓
CD
├── OIDC authentication
├── init
└── apply
   ↓
Microsoft Azure
```

---

## Outcome

This lab successfully demonstrated an end-to-end Azure Terraform workflow using advanced Terraform data structures and GitHub Actions CI/CD with passwordless Microsoft Entra ID OIDC authentication.

The environment was intentionally cleaned up after testing so that the complete process—including remote state, identity, OIDC, RBAC, CI/CD, deployment, and cleanup—can be practiced repeatedly.

---

## Repository

Azure Terraform Programmability – OIDC CI/CD

https://github.com/saftab4-arch/Azure-Terraform-Programmability-OIDC-CICD
