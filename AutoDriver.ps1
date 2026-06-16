#***********************************************************************************
# @Author Eric Geiger
#***********************************************************************************
Set-PSDebug -Off # -Trace 2 -Step

#main code
$wc = New-Object System.Net.WebClient

function logFile
{
[cmdletBinding()]
param([string]$logFile)

<# $catalogXMLDoc.DriverPackManifest.DriverPackage | ? { ($_.SupportedSystems.Brand.Model.name -eq $model) -and
 ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $major) -and
 ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minor)} | Out-File $logFile
 #>

$catalogXMLDoc.DriverPackManifest.DriverPackage | Where-Object { ($_.SupportedSystems.Brand.Model.name -eq $model) -and
 ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $major) -and
 ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minor)} | Out-File $logFile

 Get-Date | Out-File -Append $logFile

Write-Output "Log file wrote to $logFile"
}

$bios = (Get-CimInstance -ClassName Win32_BIOS).Name
$serial = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber

# $majorVersion = [System.environment]::OSVersion.version.Major
# $minorVersion = [System.environment]::OSVersion.version.Minor

# $majorVersion = [Environment]::OSVersion.Version.Major
# $minorVersion = [Environment]::OSVersion.Version.Minor

# (Get-CimInstance Win32_OperatingSystem).Version

$version = (Get-CimInstance -ClassName Win32_OperatingSystem).Version -match "(?s)^([0-9]+)\.([0-9]+)"
$minor = $Matches[2]
[string]$major = (Get-CimInstance -ClassName Win32_OperatingSystem).Version -match "(?s)^[0-9]+"
$major = $Matches[0]
$totalVersion = (Get-CimInstance -ClassName Win32_OperatingSystem).Version -match "(?s)^([0-9]+)\.([0-9]+)\.([0-9]+)"
$buildNumber = $Matches[3]
$rev = $Matches[3]

$model = (Get-WmiObject -Class Win32_computerSystem -ComputerName . -Namespace root\cimv2).model
# $modelObject = Get-WmiObject -Class Win32_computerSystem -ComputerName . -Namespace root\cimv2
# $modelList = Get-WmiObject -Query "Select * FROM Win32_ComputerSystem" -ComputerName . -Namespace root\cimv2 | Select-Object -Property model | Format-List -Expand EnumOnly
# $modelTable = Get-WmiObject -Query "Select * FROM Win32_ComputerSystem" -ComputerName . -Namespace root\cimv2 | Select-Object -Property model | Format-Table -HideTableHeaders
if (!(Test-Path -Path "C:\Dell\CabInstall" -PathType Container))
{
    New-Item -Path "C:\Dell\CabInstall" -ItemType Directory
}
$source = "http://downloads.dell.com/catalog/DriverPackCatalog.cab"
# $ftpSource = "ftp://downloads.dell.com/catalog/DriverPackCatalog.cab"
# $altFtpSource = "ftp://ftp.dell.com/catalog/DriverPackCatalog.cab"
$workingDir = "C:\Dell\CabInstall"
# $destination = "$workingDir" + "\DriverPackCatalog.cab "
$destination = "$workingDir" + "\DriverPackCatalog.cab "

# Invoke-WebRequest $source $destination
$wc.DownloadFile($source, $destination)
# wget $source $destination

#2.

$catalogCabFile = "$workingDir" + "\DriverPackCatalog.cab"
$catalogXmlFile = "$workingDir" + "\DriverPackCatalog.xml"
EXPAND $catalogCabFile $catalogXmlFile

#3.

$catalogXmlFile = "$workingDir" + "\DriverPackCatalog.xml"
[xml]$catalogXmlDoc = Get-Content $catalogXmlFile

# $catalogXMLDoc.DriverPackManifest.DriverPackage | Select-Object @{Expression={$_.SupportedSystems.Brand.key};Label="LOBKey";}, @{Expression=
# {$_.SupportedSystems.Brand.prefix};Label="LOBPrefix";}, @{Expression={$_.SupportedSystems.Brand.Model.systemID};Label="SystemID";}, @{Expression=
# {$_.SupportedSystems.Brand.Model.name};Label="SystemName";} –unique

#4.

$catalogXMLFile = "$workingDir" + "\DriverPackCatalog.xml"
[xml]$catalogXMLDoc = Get-Content $catalogXMLFile

# $catalogXMLDoc.DriverPackManifest.DriverPackage | Where-Object { ($_.SupportedSystems.Brand.Model.systemID -eq "BIOS ID") -or ($_.type -eq "WinPE")} |sort type
# or
# $catalogXMLDoc.DriverPackManifest.DriverPackage | Where-Object { ($_.SupportedSystems.Brand.Model.name -eq "System Name") -or ($_.type -eq "WinPE")} |sort type

$catalogXmlDoc.DriverPackManifest.DriverPackage | Where-Object {($_.SupportSystems.Brand.Model.name -eq $model)} |Sort-Object type # | format-table
# $catalogXmlDoc.DriverPackManifest.DriverPackage | Where-Object {($_.SupportSystems.Brand.Model.name -eq $modelObject.model)} |Sort-Object type # | format-table

#5.

$catalogXMLFile = "$workingDir" + "\DriverPackCatalog.xml"
[xml]$catalogXMLDoc = Get-Content $catalogXMLFile

# Examples
#--------------------------------------------------------------------------------------------------------------

# $catalogXMLDoc.DriverPackManifest.DriverPackage | Where-Object { ($_.SupportedSystems.Brand.Model.systemID -eq "BIOS ID") -and ($_.type -ne "WinPE") -and
#  ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq "OS Major Version" ) -and ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq "OS Minor Version" )}

# or

# $catalogXMLDoc.DriverPackManifest.DriverPackage | Where-Object { ($_.SupportedSystems.Brand.Model.name -eq "System Name") -and ($_.type -ne "WinPE") -and
#  ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq "OS Major Version" ) -and ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq "OS Minor Version" )}

#--------------------------------------------------------------------------------------------------------------

<#

if (!(Test-Path -Path "C:\Logs" -PathType Container))
{
    New-Item -Path "C:\Logs" -ItemType Directory
}

Get-Date | Out-File $logFile

 $catalogXMLDoc.DriverPackManifest.DriverPackage | Where-Object { ($_.SupportedSystems.Brand.Model.name -eq $model) -and
  ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $majorVersion ) -and
   ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minorVersion )} | Out-File $logFile
   
   [Console]::Write("Log file wrote to ") + $logFile
#>

# $catalogXMLDoc.DriverPackManifest.DriverPackage | Where-Object { ($_.SupportedSystems.Brand.Model.name -eq $modelObject.model) -and
#  ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $majorVersion ) -and
#   ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minorVersion )}

#-----------------------------------------------------------------------------------------------------------------------------

# 6. How to find WinPE Driver Packs for Operating System from "DriverPackCatalog.xml"?
# Description: Replace the 'OS Major Version' and 'OS Minor Version' to get WinPE Cab for an operating system.
# Note:  WinPE Cabs that support all the models in the Catalog do not have the list of supported systems.
<#
 $catalogXMLFile = "$pwd" + "\DriverPackCatalog.xml"

 [xml]$catalogXMLDoc = Get-Content $catalogXMLFile

 $catalogXMLDoc.DriverPackManifest.DriverPackage | Where-Object { ($_.type -eq "Win") -and
 ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq "OS Major Version" ) -and
 ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq "OS Minor Version" )}
<# $catalogXMLDoc.DriverPackManifest.DriverPackage | ? { ($_.type -eq "WinPE") -and
    ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq "OS Major Version" ) -and
    ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq "OS Minor Version" )}
  #>
#>
#-----------------------------------------------------------------------------------------

# 7 How to download the link for Driver Packs for a model, operating system and type from "DriverPackCatalog.xml"?
# After a Driver Pack is located for (Type)-(BIOS/System ID or System Name)-(Operating System), you can easily download it.
# Description: The example demonstrates downloading of a WinPE Cab. Replace 'OS Major Version' and 'OS Minor Version' to get WinPE Cab for a model and operating system and download the same to the current directory.

$catalogXMLFile = "$workingDir" + "\DriverPackCatalog.xml"
[xml]$catalogXMLDoc = Get-Content $catalogXMLFile

# $cabSelected = $catalogXMLDoc.DriverPackManifest.DriverPackage | ? { ($_.SupportedSystems.Brand.Model.name -eq $modelObject.model) -and
#   ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $major ) -and
#   ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minor )} #($_.type -eq " WinPE") -and ($_.type -eq " Win") -and 

 $cabSelected = $catalogXMLDoc.DriverPackManifest.DriverPackage | Where-Object { ($_.SupportedSystems.Brand.Model.name -eq $model) -and
  ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $major ) -and
  ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minor )}

#-----------------------------------------------------------------------------------------

if($rev -lt 22000)
{
    $targetExtension = ".cab"
    $targetOS = "Windows 10"
}
else
{
    $targetExtension = ".exe"
    $targetOS = "Windows 11"
}

$selectedPackage = $cabSelected | Where-Object {
    $_.path -and ([System.IO.Path]::GetExtension($_.path).ToLowerInvariant() -eq $targetExtension)
} | Select-Object -First 1

if(-not $selectedPackage)
{
    throw "No $targetOS driver package with extension $targetExtension was found for model '$model'."
}

$selectedExtension = [System.IO.Path]::GetExtension($selectedPackage.path).ToLowerInvariant()
if($selectedExtension -ne $targetExtension)
{
    throw "Selected package format '$selectedExtension' does not match expected '$targetExtension' for $targetOS."
}

# $cab = Split-Path -Leaf $cabSelected.path

$hash = $selectedPackage.hashMD5
$releaseId = $selectedPackage.releaseID
$dellVersion = $selectedPackage.dellVersion

if (!(Test-Path -Path "C:\Logs" -PathType Container))
{
    New-Item -Path "C:\Logs" -ItemType Directory
}

$logFile = "C:\Logs\autoDriver.log"

if (Test-Path -Path "C:\Logs\autoDriver.log" -PathType Leaf)
{
    $logs = Get-ChildItem "C:\logs\" -Name -Include *.log | Where-Object { $_ -match "^autoDriver\..+$" }
    Get-Content "C:\logs\$logs" | Where-Object { $_ -match "hash.+:\s(?<regHash>.+)" } | Out-Null
    Get-Content "$env:SystemDrive\logs\$logs" | Where-Object { $_ -match "hash.+:\s(?<regHash>.+)" } | Out-Null
    $log = $Matches.regHash
}

if (!(Test-Path -Path "C:\Dell\CabInstall\cab" -PathType Container))
{
    New-Item -Path "C:\Dell\CabInstall\cab" -ItemType Directory
}

$workingDir = "C:\Dell\CabInstall\cab"

if(Test-Path -Path "C:\Dell\CabInstall\cab\$cab" -PathType Leaf -Include *.cab)
{
    $cabFile = Get-ChildItem "C:\Dell\CabInstall\cab" -Name -Include *.cab
    $cabFile -match "(?s)^(?<Model>\w?\d+\w?)-(?<os>.+\d+?)-(?<revision>A\d+)-(?<releaseId>.+)\.cab$" | Out-Null

#   $cabFile | Select-String -Pattern "(?s)^(\w?\d+\w?)-(.+\d+?)-(A\d+)-(.+)\.cab$"
    
    $modelId = $Matches[1]
    $modelId = $Matches.Model
    $os = $Matches[2]
    $os = $Matches.os
    $revision = $Matches[3]
    $revision = $Matches.revision
    $release = $Matches[4]
    $release = $Matches.releaseId
}

if($hash -eq $log -or $log -eq $hash -and $revision -eq $dellVersion -and $release -eq $releaseId)
{
    Write-Output "Your drivers are already up-to-date"
    pause
    break
    exit
}
$downloadLink = "https://" + $catalogXMLDoc.DriverPackManifest.baseLocation + "/" + $selectedPackage.path
$fileName = [System.IO.Path]::GetFileName($downloadLink)
$downloadDestination = Join-Path -Path $workingDir -ChildPath $fileName # "$workingDir" + "\" + $fileName
Write-output "Downloading $selectedExtension driver pack for $targetOS. This may take a few minutes."
$wc.DownloadFile($downloadLink, $downloadDestination)

if($targetExtension -eq ".cab")
{
    & EXPAND "$downloadDestination" -F:* "$workingDir"
    & PNPUTIL /add-driver "$workingDir\*.inf" /subdirs /install
}
else
{
    # Start-Process -FilePath $downloadDestination -Wait
    Start-Process dup -ArgumentList "/e=$downloadDestination" -Wait
    & PNPUTIL /add-driver "$workingDir\*.inf" /subdirs /install
}

# write-verbose -Message Done
logFile($logFile)
# write-warning "Need to run BIOS manually"
[Console]::Write("Your BIOS version is ") + $bios

Pause

# Remove-Item -Path "C:\Dell\CabInstall" -Recurse

# $DebugPreference = "Continue"
# $VerbosePreference = "Continue"
