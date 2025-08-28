param(
  [Parameter(Mandatory=$true)][string]$ClusterName,
  [Parameter(Mandatory=$true)][string]$SubnetIds, # comma-separated
  [Parameter(Mandatory=$true)][string]$SecurityGroupId,
  [Parameter(Mandatory=$true)][string]$TaskDefName,
  [Parameter(Mandatory=$true)][string]$ContainerName,
  [Parameter(Mandatory=$true)][string]$Region
)

$subnets = $SubnetIds.Split(',')
if ($subnets.Count -lt 1) { throw "Provide at least one subnet id" }

$overrides = @{
  containerOverrides = @(
    @{
      name    = $ContainerName
      command = @("node","-e","for(;;){}")
    }
  )
} | ConvertTo-Json -Compress

aws ecs run-task `
  --cluster $ClusterName `
  --launch-type FARGATE `
  --network-configuration ("awsvpcConfiguration={subnets=[" + ($subnets -join ',') + "],securityGroups=[$SecurityGroupId],assignPublicIp=DISABLED}") `
  --task-definition $TaskDefName `
  --overrides $overrides `
  --region $Region `
  --query "tasks[0].taskArn" `
  --output text
