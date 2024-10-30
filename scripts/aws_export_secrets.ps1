# Example of how to use the script
# .\export_secrets.ps1 -envFile .env

param (
    [string]$envFile,
    [string]$secretName
)

# Check if the environment file is provided
if ($envFile -eq $null -or $envFile -eq "") {
    Write-Output "Please provide an environment file."
    exit 1
}

$envFile = Resolve-Path $envFile

# Check if the environment file exists
if (-not (Test-Path $envFile)) {
    Write-Output "The file $envFile does not exist"
    exit
}

# Check if the secret name is provided
if ($secretName -eq $null -or $secretName -eq "") {
    Write-Output "Please provide a secret name."
    exit 1
}


$envTable = @{}
$envs = Get-Content $envFile
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