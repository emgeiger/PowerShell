[CmdletBinding()]
param(
    [string]$OutputPath = (Join-Path -Path $PSScriptRoot -ChildPath 'Invoke-Robocopy.exe'),
    [switch]$NoConsole,
    [switch]$Force
)

$launcherPath = Join-Path -Path $PSScriptRoot -ChildPath 'Invoke-Robocopy.Launcher.ps1'
if (-not (Test-Path -LiteralPath $launcherPath -PathType Leaf)) {
    throw "Launcher script not found: $launcherPath"
}

$invokePs2Exe = Get-Command -Name Invoke-PS2EXE -ErrorAction SilentlyContinue
if (-not $invokePs2Exe) {
    throw 'Invoke-PS2EXE command was not found. Install the ps2exe module first.'
}

if ((Test-Path -LiteralPath $OutputPath -PathType Leaf) -and -not $Force) {
    throw "Output already exists: $OutputPath. Use -Force to overwrite."
}

$buildArgs = @{
    InputFile = $launcherPath
    OutputFile = $OutputPath
}

if ($NoConsole) {
    $buildArgs['NoConsole'] = $true
}

if ($Force) {
    $buildArgs['Force'] = $true
}

Invoke-PS2EXE @buildArgs
Write-Host "Launcher executable created: $OutputPath"
