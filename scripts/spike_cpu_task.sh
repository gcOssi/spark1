#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 --cluster-name NAME --subnet-ids SUBNET_A,SUBNET_B --security-group-id SGID --task-def-name FAMILY --container-name NAME --region REGION

Example:
  $0 --cluster-name staging-ecs-cluster \
     --subnet-ids subnet-abc,subnet-def \
     --security-group-id sg-123456 \
     --task-def-name staging-be \
     --container-name backend \
     --region us-east-1
EOF
  exit 1
}

CLUSTER="" SUBNETS="" SG="" TASKDEF="" CONTAINER="" REGION=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --cluster-name) CLUSTER="$2"; shift 2;;
    --subnet-ids) SUBNETS="$2"; shift 2;;
    --security-group-id) SG="$2"; shift 2;;
    --task-def-name) TASKDEF="$2"; shift 2;;
    --container-name) CONTAINER="$2"; shift 2;;
    --region) REGION="$2"; shift 2;;
    *) usage;;
  esac
done

[[ -z "$CLUSTER" || -z "$SUBNETS" || -z "$SG" || -z "$TASKDEF" || -z "$CONTAINER" || -z "$REGION" ]] && usage

IFS=',' read -r SUBNET_A SUBNET_B <<< "$SUBNETS"

echo "[*] Running CPU spike task on cluster: $CLUSTER"
aws ecs run-task \
  --cluster "$CLUSTER" \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_A,$SUBNET_B],securityGroups=[$SG],assignPublicIp=DISABLED}" \
  --task-definition "$TASKDEF" \
  --overrides "$(cat <<JSON
{
  "containerOverrides":[{
    "name":"$CONTAINER",
    "command":["node","-e","for(;;){}"]
  }]
}
JSON
)" \
  --region "$REGION" \
  --query "tasks[0].taskArn" \
  --output text
