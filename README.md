# Staging Deployment: ECS Fargate + ALB + CloudFront + CI/CD + Monitoring

This repo deploys a **Dockerized React (frontend)** and **Node.js (backend)** to **AWS ECS Fargate**, fronted by **ALB** and **CloudFront (HTTPS)**, with **Basic Auth** via an **Nginx sidecar**, **auto-deploy from GitHub Actions**, and **CPU > 70% CloudWatch alarms** to **SNS**.

> Public access is **HTTPS-only** through CloudFront’s default certificate on the `*.cloudfront.net` domain (no custom domain required).

## Repo Structure
```
.
├─ infrastructure/          # Terraform IaC
│  ├─ main.tf
│  ├─ variables.tf
│  ├─ outputs.tf
│  ├─ vpc.tf
│  ├─ ecr.tf
│  ├─ ecs.tf
│  ├─ alb.tf
│  ├─ cloudfront.tf
│  ├─ security_groups.tf
│  ├─ iam.tf
│  ├─ ssm.tf
│  ├─ sns_cloudwatch.tf
│  └─ locals.tf
├─ cicd/.github/workflows/deploy.yml   # GitHub Actions
├─ docs/architecture.md                # Mermaid + ASCII diagram
├─ frontend/                           # your React app (Dockerfile included)
├─ backend/                            # your Node API (Dockerfile included)
└─ docker-compose.yml                  # local reference
```

## One-time setup
1) Create an **SNS subscription** email (Terraform will create the topic; confirm the email from your inbox).
2) In GitHub → Settings → Secrets and variables → Actions → **Variables** and **Secrets**:
   - Variables:
     - `AWS_REGION` (e.g., `us-east-1`)
     - `ECR_REPO_FE` (default set by Terraform output: `staging-frontend`)
     - `ECR_REPO_BE` (default set by Terraform output: `staging-backend`)
   - Secrets:
     - `AWS_ACCOUNT_ID`
     - (Optional) `BASIC_AUTH_USER`, `BASIC_AUTH_PASS` (else Terraform sets defaults `staging`/`staging` via SSM)
3) Configure **GitHub OIDC to AWS** and set the **role ARN** in the workflow (`ROLE_TO_ASSUME`).

## Deploy (CI/CD)
- Push to `main` triggers:
  - Build & push images to ECR.
  - `terraform init` + `terraform apply` (idempotent).
  - ECS service is updated with the new images.

## Outputs
- `cloudfront_domain_name` → Paste this in your submission as the public URL.

## Cleanup
```
cd infrastructure
terraform destroy -auto-approve
```
