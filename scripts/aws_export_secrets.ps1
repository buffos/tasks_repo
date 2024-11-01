# Example of how to use the script
# .\export_secrets.ps1 -envFile .env

param (
    [string]$key,
    [string]$project
)

if ($null -eq $project -or $project -eq "") {
    Write-Output "Please provide a project key."
    exit 1
}

# Check if the environment file is provided
if ($null -eq $key -or $key -eq "") {
    Write-Output "Please provide a secret key."
    exit 1
}

# first get the project json file and read the key = $project
$projectFilePath = "projects.json"
if (-not (Test-Path $projectFilePath)) {
    Write-Output "The project file $projectFilePath does not exist"
    exit 1
}

$projectJson = Get-Content $projectFilePath -Raw | ConvertFrom-Json
$secretFilePath = $projectJson."$project".secrets."$key".path
$secretName = $projectJson."$project".secrets."$key".name

$rootPath = $projectJson."$project".path.root

if (-not (Test-Path $rootPath)) {
    Write-Output "The root path $rootPath does not exist"
    exit 1
}

$secretFilePath = Join-Path $rootPath $secretFilePath
if (-not (Test-Path $secretFilePath)) {
    Write-Output "The secret file $secretFilePath does not exist"
    exit 1
}

if ( $null-eq $secretName -or $secretName -eq "") {
    Write-Output "Please provide a secret key."
    exit 1
}


$envTable = @{}
$envs = Get-Content $secretFilePath
foreach ($env in $envs) {
    $env = $env.Trim()
    if ($env -eq "") {
        continue # Skip empty lines
    }
    $key, $value = $env.Split('=', 2) #split on the first occurence of '='
    $envTable.Add($key, $value) # Add the key value pair to the hashtable
}
$sortedKeys = [System.Collections.SortedList] $envTable  # Sort the keys (https://stackoverflow.com/questions/59498570/powershell-sorting-hash-table)
$newSecret = $sortedKeys | convertTo-Json -Compress

aws secretsmanager put-secret-value --secret-id $secretName --secret-string $newSecret
# Write-Output $sortedKeys