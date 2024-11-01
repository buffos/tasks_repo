param (
    [string]$project,
    [string]$command
)

if ($null -eq $project -or $project -eq "") {
    Write-Output "Please provide a project key."
    exit 1
}

# check if the project file exists
$projectFilePath = "projects.json"
if (-not (Test-Path $projectFilePath)) {
    Write-Output "The project file $projectFilePath does not exist"
    exit 1
}

# read the project file
$projectJson = Get-Content $projectFilePath -Raw | ConvertFrom-Json

# get the root path
$rootPath = $projectJson."$project".path.root

$currentPath = Get-Location


# cd to the root path
Set-Location $rootPath

# execute the command
Invoke-Expression $command

# cd back to the current path
Set-Location $currentPath
