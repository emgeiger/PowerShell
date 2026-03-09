[CmdletBinding()]
param(
    [switch]$Force
)

$moduleName = 'Invoke-Robocopy'
$sourcePath = $PSScriptRoot
$targetRoot = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath 'PowerShell\Modules'
$targetPath = Join-Path -Path $targetRoot -ChildPath $moduleName

if (-not (Test-Path -LiteralPath $targetRoot -PathType Container)) {
    New-Item -Path $targetRoot -ItemType Directory -Force | Out-Null
}

if (Test-Path -LiteralPath $targetPath -PathType Container) {
    if (-not $Force) {
        throw "Module path already exists: $targetPath. Use -Force to overwrite."
    }

    Remove-Item -LiteralPath $targetPath -Recurse -Force
}

Copy-Item -Path $sourcePath -Destination $targetPath -Recurse -Force
Write-Host "Installed module to: $targetPath"
Write-Host 'Import with: Import-Module Invoke-Robocopy'
