# Test Plan (Staging)

This guide helps you validate deployment, security, CI/CD, and monitoring.

## 1) Validate Public Access (HTTPS via CloudFront)
1. After `terraform apply`, copy the output `cloudfront_domain_name`.
2. Open `https://<cloudfront_domain_name>/` in an incognito window.
3. You should see a **Basic Auth** prompt. Use credentials:
   - Default: `staging / staging` (SSM parameters) or the values set in CI secrets.
4. After login, you should reach the frontend through the Nginx auth proxy.

## 2) Validate Backend Routing
- The ALB listener rule forwards `/api/*` to the backend service.
- Try `https://<cloudfront_domain_name>/api/health` (adjust path to your API).

## 3) Validate CI/CD
- Push any change to the repo's `main` branch (e.g., edit README).
- In GitHub → Actions → watch **Deploy Staging (ECS + Terraform)** run:
  - Builds FE/FE-nginx/BE images → pushes to ECR.
  - Runs `terraform apply` idempotently.
  - ECS services update to `:latest` images.

## 4) Validate Monitoring & Alerts (CPU > 70%)
There are two CloudWatch alarms: one for **frontend** service and one for **backend** service.
To trigger an alarm, you can **temporarily run a CPU-intensive command** in an ECS task.

### Option A: Quick spike using a one-off backend task override
Requirements:
- AWS CLI configured with the role that can run ECS tasks.
- The backend image already pushed by CI/CD (first successful deploy).

Run the helper script (Linux/macOS):
```bash
./scripts/spike_cpu_task.sh   --cluster-name staging-ecs-cluster   --subnet-ids subnet-xxxx,subnet-yyyy   --security-group-id sg-zzzz   --task-def-name staging-be   --container-name backend   --region us-east-1
```

What it does:
- Calls `aws ecs run-task` on the **backend TaskDefinition** with an **override command** that spins the CPU:
  ```bash
  node -e "for(;;){}"
  ```
- The task will increase CPU for a few minutes. CloudWatch should evaluate `Average CPUUtilization` > 70% over 2 periods (5 min each by default).
- Check the alarm state in CloudWatch → Alarms.
- Confirm the **SNS email** notification (ensure you confirmed the subscription first).

### Option B: Manual `aws ecs run-task` (if you prefer no script)
Replace placeholders and run:
```bash
aws ecs run-task   --cluster <clusterName>   --launch-type FARGATE   --network-configuration "awsvpcConfiguration={subnets=[<subnetA>,<subnetB>],securityGroups=[<sgId>],assignPublicIp=DISABLED}"   --task-definition <backendTaskDefFamilyOrArn>   --overrides '{
    "containerOverrides":[{
      "name":"backend",
      "command":["node","-e","for(;;){}"]
    }]
  }'   --region <region>
```

## 5) Cleanup of the spike task
- The one-off task will stop when you stop it in ECS console or let it run briefly then stop:
```bash
aws ecs list-tasks --cluster <cluster> --desired-status RUNNING
aws ecs stop-task --cluster <cluster> --task <taskArn>
```

## 6) Extra Checks
- **Only HTTPS**: CloudFront enforces `redirect-to-https`. HTTP should redirect to HTTPS.
- **Security Groups**: Public access allowed only to ALB (HTTP from CF). Tasks accessible only from ALB SG.
- **Logs**: View container logs in CloudWatch Log Groups `/ecs/staging-frontend` and `/ecs/staging-backend`.
