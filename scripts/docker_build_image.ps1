Function Get-FileName($initialDirectory)
{
 [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.Title = "Select project configuration build file"
 $OpenFileDialog.filter = “All files (*.*)| *.*”
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName


Write-Output "Select build configuration file"
$configFile = Get-FileName -initialDirectory $PWD\build
Write-Output "Configuration file selected: $configFile"

# Get all keys from the configuration file in an array
$configKeys = Get-Content -Path $configFile | ConvertFrom-Json | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name

$release = menu @($configKeys)

Clear-Host
Write-Output "Building image for release: $release"

$config = Get-Content -Path $configFile | ConvertFrom-Json
$image = $config.$release.image
$dockerfile = $config.$release.dockerfile
$version = $config.$release.version
$build = $config.$release.build
$builder = $config.$release.builder
$load = $config.$release.load
$push = $config.$release.push
$platform = $config.$release.platform
$secretString = $config.$release.secretString
$tags = $config.$release.tag

# get the path of the dockerfile
$dockerfilePath = Split-Path -Path $dockerfile -Parent


# prepare build command as string
$buildCommand = "docker buildx build --builder $builder --platform $platform --progress=plain --secret $secretString"
$buildCommand = $buildCommand + " --file `"${dockerfile}`""
foreach ($tag in $tags) {
    $buildCommand = $buildCommand + " --tag $image`:$tag"
}
$buildCommand = $buildCommand + " --tag $image`:$release-$version.$build"
$buildCommand = $push ? $buildCommand + " --push" : $buildCommand
$buildCommand = $buildCommand + " " + "`"${dockerfilePath}`"" # context path
$buildCommand = $load ? $buildCommand + " --load" : $buildCommand

# execute build command
Invoke-Expression $buildCommand
if ($LASTEXITCODE -ne 0) {
    Write-Output "Build failed"
    exit 1
}

# if it was a success, increment the build number
$config.$release.build = [int]$config.$release.build + 1
$config | ConvertTo-Json -Depth 10 | Set-Content -Path $configFile