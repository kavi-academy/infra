# Infra Repository

This repository contains **Terraform** code that provisions the AWS infrastructure for the *Expenses‑Manager* application across the four environments (dev, test, uat, prod).  It follows the layout described in our design:

```
infra/
├─ modules/                 # reusable Terraform modules (VPC, RDS, ECS, Jenkins, etc.)
├─ environments/            # one folder per environment
│   ├─ dev/
│   │   ├─ main.tf
│   │   ├─ variables.tf
│   │   └─ backend.tf
│   ├─ test/   (same structure)
│   ├─ uat/    (same structure)
│   └─ prod/   (same structure)
└─ global/                  # shared resources – remote‑state bucket, lock table, IAM groups/roles
    └─ backend.tf           # backend configuration for all envs (points at the S3 bucket created by the bootstrap)
```

> **Note** – The actual Terraform resources are added later; this file only provides the scaffolding.
