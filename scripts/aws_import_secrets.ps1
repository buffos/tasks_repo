param (
    [string]$secretName
)

if ($secretName -eq $null -or $secretName -eq "") {
    Write-Output "Please provide a secret name."
    exit 1
}

$secret = aws secretsmanager list-secrets --filters "Key=name,Values=$secretName" | ConvertFrom-Json -AsHashTable
$arn = $secret.SecretList[0].ARN
# Now get the secret contents from the ARN
$secret_contents = aws secretsmanager get-secret-value --secret-id $arn | ConvertFrom-Json -AsHashTable
# convert the secret string to an env file
$env_contents = $secret_contents.SecretString | ConvertFrom-Json -AsHashtable
# write the env contents to a file
$env_file_path = [System.IO.Path]::GetFullPath("./secrets/exported.env")
$env_contents.GetEnumerator() | ForEach-Object {
    "$($_.Key)=$($_.Value)" | Out-File -Append -FilePath $env_file_path
}

Write-Output "Env file created at $env_file_path"