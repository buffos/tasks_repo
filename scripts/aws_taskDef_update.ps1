param (
    [string]$region
)

$AWS_REGION = ""

if ($region -eq $null -or $region -eq "") {
    $AWS_REGION = "eu-central-1"
}
else {
    $AWS_REGION = $region
}

Clear-Host

Write-Output "AWS region: $AWS_REGION"

# List all clusters
$CLUSTERS = aws ecs list-clusters --region $AWS_REGION | ConvertFrom-Json | Select-Object -ExpandProperty clusterArns
$CLUSTERS = $CLUSTERS | ForEach-Object { $_.Split('/')[1] }

Write-Output "Select a cluster:"
$CLUSTER_NAME = menu @($CLUSTERS)

# Get the list of services in the specified cluster
$SERVICES = aws ecs list-services --cluster $CLUSTER_NAME --region $AWS_REGION | ConvertFrom-Json | Select-Object -ExpandProperty serviceArns
$SERVICES = $SERVICES | ForEach-Object { $_.Split('/')[2] }
Write-Output "Select a service:"
$SERVICE_NAME = menu @($SERVICES)

# Get the task definition for the selected service
$SERVICE_DETAILS = aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE_NAME --region $AWS_REGION | ConvertFrom-Json | Select-Object -ExpandProperty services
$TASKDEFINITIONS = $SERVICE_DETAILS | ForEach-Object { $_.taskDefinition }

Write-Output "Select a task definition:"
$TASK_DEFINITION_ARN = menu @($TASKDEFINITIONS)

# Get the container definitions for the selected task definition# Get the task definition details by ARN
$TASK_DEFINITION_DETAILS = aws ecs describe-task-definition --task-definition $TASK_DEFINITION_ARN --region $AWS_REGION | ConvertFrom-Json


$EXECUTION_ARN = $TASK_DEFINITION_DETAILS.taskDefinition.executionRoleArn
$TASK_ROLE_ARN = $TASK_DEFINITION_DETAILS.taskDefinition.taskRoleArn
$TASK_FAMILY = $TASK_DEFINITION_DETAILS.taskDefinition.family
$MEMORY = $TASK_DEFINITION_DETAILS.taskDefinition.memory
$CPU = $TASK_DEFINITION_DETAILS.taskDefinition.cpu
$ARCHITECTURE = $TASK_DEFINITION_DETAILS.taskDefinition.runtimePlatform.cpuArchitecture
$CONTAINER_DEFINITIONS = $TASK_DEFINITION_DETAILS.taskDefinition | Select-Object -ExpandProperty containerDefinitions

Write-Output "task role arn: $TASK_ROLE_ARN"
Write-Output "execution role arn: $EXECUTION_ARN"
Write-Output "task family: $TASK_FAMILY"
Write-Output "memory: $MEMORY"
Write-Output "cpu: $CPU"
Write-Output "architecture: $ARCHITECTURE"

Write-Output "Container image: $($CONTAINER_DEFINITIONS[0].image) " # we can use this to replace the image if we want
$CONTAINER_DEFINITIONS_JSON = $CONTAINER_DEFINITIONS[0] | ConvertTo-Json -Depth 10

Write-Output "Update the task (Y/N)"
$CONFIRM = Read-Host
if ($CONFIRM -ne "Y" -or $CONFIRM -ne "y") {
    Write-Output "Task not updated"
    exit
}
$NEW_TASK_INFO = aws ecs register-task-definition `
    --family $TASK_FAMILY `
    --container-definitions $CONTAINER_DEFINITIONS_JSON `
    --execution-role-arn $EXECUTION_ARN `
    --task-role-arn $TASK_ROLE_ARN `
    --requires-compatibilities FARGATE `
    --network-mode awsvpc `
    --runtime-platform cpuArchitecture="$ARCHITECTURE" `
    --cpu $CPU --memory $MEMORY


$NEW_REVISION = $NEW_TASK_INFO `
| ConvertFrom-Json `
| Select-Object -ExpandProperty taskDefinition `
| Select-Object -ExpandProperty revision

aws ecs update-service `
    --cluster $CLUSTER_NAME `
    --service $SERVICE_NAME `
    --task-definition ${TASK_FAMILY}:${NEW_REVISION} | out-null

Write-Output "Task updated"