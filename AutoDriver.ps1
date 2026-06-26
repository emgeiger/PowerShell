<#
.SYNOPSIS
Automates Dell driver deployment by reading the PC model and Windows version, downloading Dell's driver catalog, finding the matching driver pack, and installing the drivers.

.DESCRIPTION
Keeps the system's Dell drivers up to date using Dell's catalog-based deployment workflow and switches between CAB and DUP packages as needed for the target Windows version.

.NOTES
Author: Eric Geiger
#>

Set-PSDebug -Off # -Trace 2 -Step

#main code
$wc = New-Object System.Net.WebClient

function Write-DriverPackLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$LogFile,
        [Parameter(Mandatory)] [object]$SelectedPackage,
        [Parameter(Mandatory)] [string]$Model,
        [Parameter(Mandatory)] [string]$Major,
        [Parameter(Mandatory)] [string]$Minor
    )

    $logDir = Split-Path -Parent $LogFile
    if ($logDir -and -not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory | Out-Null
    }

    $entry = @"
timestamp:    $(Get-Date -Format o)
model:        $Model
osVersion:    $Major.$Minor
selectedPath: $($SelectedPackage.path)
hash:         $($SelectedPackage.hashMD5)
releaseId:    $($SelectedPackage.releaseID)
dellVersion:  $($SelectedPackage.dellVersion)

"@


    $existing = if (Test-Path $LogFile) {
        [System.IO.File]::ReadAllText($LogFile)
    } else {
        [string]::Empty
    }
    
    $combined = $entry + [System.Environment]::NewLine + $existing
    [System.IO.File]::WriteAllText($LogFile, $combined, [System.Text.UTF8Encoding]::new($false))
    Write-Output "Log file written to $LogFile"
}

function Invoke-AutoDriver {
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
if (!(Test-Path -Path "C:\Dell\" -PathType Container))
{
    New-Item -Path "C:\Dell\" -ItemType Directory
}
$source = "http://downloads.dell.com/catalog/DriverPackCatalog.cab"
# $ftpSource = "ftp://downloads.dell.com/catalog/DriverPackCatalog.cab"
# $altFtpSource = "ftp://ftp.dell.com/catalog/DriverPackCatalog.cab"
$workingDir = "C:\Dell\"
# $destination = "$workingDir" + "\DriverPackCatalog.cab "
$destination = Join-Path -Path $workingDir -ChildPath "DriverPackCatalog.cab"

# Invoke-WebRequest $source $destination
$wc.DownloadFile($source, $destination)
# wget $source $destination

# 2. How to get "DriverPackCatalog.xml" from "DriverPackCatalog.cab" ?
# Driver Pack Catalog ("DriverPackCatalog.xml") is digitally signed and delivered as "DriverPackCatalog.cab" file, 
# that can be extracted.

$catalogCabFile = Join-Path -Path $workingDir -ChildPath "DriverPackCatalog.cab"
$catalogXmlFile = Join-Path -Path $workingDir -ChildPath "DriverPackCatalog.xml"
EXPAND $catalogCabFile $catalogXmlFile

# 3.  How to find the list of Models supported by "DriverPackCatalog.xml"?
<# Note:
    Although, LOB title and model codes are present in child nodes, 
    we recommend you to use the BIOS/System ID and Name to evaluate the applicability of the Driver Pack.
#>

<# Description:
    Get Mapping between Model name and BIOS/System ID along with Line of Business,
    for system supported by the catalog from "DriverPackCatalog.xml" available in the current directory.
#>

$catalogXmlFile = Join-Path -Path $workingDir -ChildPath "DriverPackCatalog.xml"
[xml]$catalogXmlDoc = Get-Content $catalogXmlFile

# $catalogXMLDoc.DriverPackManifest.DriverPackage | Select-Object @{Expression={$_.SupportedSystems.Brand.key};Label="LOBKey";}, @{Expression=
# {$_.SupportedSystems.Brand.prefix};Label="LOBPrefix";}, @{Expression={$_.SupportedSystems.Brand.Model.systemID};Label="SystemID";}, @{Expression=
# {$_.SupportedSystems.Brand.Model.name};Label="SystemName";} –unique

# 4. How to locate or find Driver Packs for a System from "DriverPackCatalog.xml"?

# After the "DriverPackCatalog.xml" is made available in the current directory, 
# the xml can be parsed to find all Driver Packs applicable for a model using BIOS/System ID or Name.

<#
    Description: In order to get all applicable System and WinPE Driver Packs for a given System, 
    replace the 'BIOS ID' or 'System Name' in the script.
#>

# PowerShell snippet:

$catalogXMLFile = Join-Path -Path $workingDir -ChildPath "DriverPackCatalog.xml"
[xml]$catalogXMLDoc = Get-Content $catalogXMLFile

# $catalogXMLDoc.DriverPackManifest.DriverPackage | Where-Object { ($_.SupportedSystems.Brand.Model.systemID -eq "BIOS ID") -or ($_.type -eq "WinPE")} |sort type
# or
# $catalogXMLDoc.DriverPackManifest.DriverPackage | Where-Object { ($_.SupportedSystems.Brand.Model.name -eq "System Name") -or ($_.type -eq "WinPE")} |sort type

$catalogXmlDoc.DriverPackManifest.DriverPackage | Where-Object {($_.SupportSystems.Brand.Model.name -eq $model)} | Sort-Object type # | format-table
# $catalogXmlDoc.DriverPackManifest.DriverPackage | Where-Object {($_.SupportSystems.Brand.Model.name -eq $modelObject.model)} |Sort-Object type # | format-table

# 5.

$catalogXMLFile = Join-Path -Path $workingDir -ChildPath "DriverPackCatalog.xml"
[xml]$catalogXMLDoc = Get-Content $catalogXMLFile

# Examples
#--------------------------------------------------------------------------------------------------------------

# $catalogXMLDoc.DriverPackManifest.DriverPackage | Where-Object { ($_.SupportedSystems.Brand.Model.systemID -eq "BIOS ID") -and ($_.type -ne "WinPE") -and
#  ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq "OS Major Version" ) -and ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq "OS Minor Version" )}

# or

# $catalogXMLDoc.DriverPackManifest.DriverPackage | Where-Object { ($_.SupportedSystems.Brand.Model.name -eq "System Name") -and ($_.type -ne "WinPE") -and
#  ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq "OS Major Version" ) -and ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq "OS Minor Version" )}

#--------------------------------------------------------------------------------------------------------------

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

# 7. How to download the link for Driver Packs for a model, operating system and type from "DriverPackCatalog.xml"?
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

<#

 $catalogXMLDoc.DriverPackManifest.DriverPackage | Where-Object { ($_.SupportedSystems.Brand.Model.name -eq $model) -and
  ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $majorVersion ) -and
   ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minorVersion )} | Out-File $logFile
   
   [Console]::Write("Log file wrote to ") + $logFile
#>

$logDir = "C:\Logs"
$logFile = Join-Path -Path $logDir -ChildPath "autoDriver.log"

if (Test-Path -Path $logFile -PathType Leaf)
{
    $hashMatch = Select-String -Path $logFile -Pattern "^hash:\s*(?<regHash>.+)$" | Select-Object -Last 1
    if($hashMatch)
    {
        $log = $hashMatch.Matches[0].Groups['regHash'].Value.Trim()
    }
}

if(Test-Path -Path "C:\Dell\$cab" -PathType Leaf -Include *.cab -Exclude *.exe)
{
    $cabFile = Get-ChildItem "C:\Dell\" -Name -Include *.cab
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
} elseif (Test-Path -Path $workingDir\$selectedPackage -PathType Leaf -Include *.exe -Exclude *.cab) {
    $exeFile = Get-ChildItem $workingDir -Name -Include *.exe
    $exeFile -match "(?s)^(?<Model>\w?\d+\w?)-(?<releaseId>.+)_(?<os>.+\d+?)_(?<vendorVersion>\d\.\d)_(?<revision>A\d+)\.exe$" | Out-Null

    $modelId = $Matches[1]
    $modelId = $Matches.Model
    $release = $Matches[2]
    $release = $Matches.releaseId
    $os = $Matches[3]
    $os = $Matches.os
    $vendorVersion = $Matches[4]
    $vendorVersion = $Matches.vendorVersion
    $revision = $Matches[5] # DellVersion
    $revision = $Matches.revision # DellVersion

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

if (-not (Test-Path -Path $downloadDestination -PathType Leaf))
{
    $syncHash = [hashtable]::Synchronized(@{
        Progress = 0
        Total    = 0L
        Read     = 0L
        Complete = $false
        Error    = $null
    })

    $rs = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
    $rs.Open()
    $rs.SessionStateProxy.SetVariable('syncHash',            $syncHash)
    $rs.SessionStateProxy.SetVariable('downloadLink',        $downloadLink)
    $rs.SessionStateProxy.SetVariable('downloadDestination', $downloadDestination)

    $ps = [System.Management.Automation.PowerShell]::Create()
    $ps.Runspace = $rs
    $ps.AddScript({
        $httpClient = [System.Net.Http.HttpClient]::new()
        try {
            $response  = $httpClient.GetAsync($downloadLink,
                           [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead
                         ).GetAwaiter().GetResult()
            $syncHash.Total = $response.Content.Headers.ContentLength
            $srcStream = $response.Content.ReadAsStreamAsync().GetAwaiter().GetResult()
            $dstStream = [System.IO.FileStream]::new($downloadDestination,
                           [System.IO.FileMode]::Create)
            try {
                $buffer = [byte[]]::new(81920)
                $read   = 0
                while (($read = $srcStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                    $dstStream.Write($buffer, 0, $read)
                    $syncHash.Read += $read
                    if ($syncHash.Total) {
                        $syncHash.Progress = [int]($syncHash.Read / $syncHash.Total * 100)
                    }
                }
            } finally {
                $dstStream.Dispose()
                $srcStream.Dispose()
                $response.Dispose()
            }
        } catch {
            $syncHash.Error = $_
        } finally {
            $httpClient.Dispose()
            $syncHash.Complete = $true
        }
    }) | Out-Null

    $handle = $ps.BeginInvoke()
    do {
        Write-Progress -Activity "Downloading $fileName" -Status "$($syncHash.Progress)% complete" -PercentComplete $syncHash.Progress
        Start-Sleep -Milliseconds 300
    } while (-not $syncHash.Complete)
    $ps.EndInvoke($handle)
    $ps.Dispose()
    $rs.Dispose()
    Write-Progress -Activity "Downloading $fileName" -Completed
    if ($syncHash.Error) { throw $syncHash.Error }
} else {
    Write-Output "Using cached $fileName - skipping download."
}

$infFiles = Get-ChildItem -Path $workingDir -Filter *.inf -Recurse -ErrorAction SilentlyContinue

if ($targetExtension -eq ".cab")
{
    if (-not $infFiles)
    {
        $job = Start-Job { & EXPAND $args[0] -F:* $args[1] } -ArgumentList $downloadDestination, $workingDir
        $i = 0
        while ($job.State -eq 'Running')
        {
            Write-Progress -Activity "Extracting $fileName" -Status "Extracting..." -PercentComplete ($i % 100)
            $i += 5
            Start-Sleep -Milliseconds 300
        }
        Receive-Job $job | Out-Null
        Remove-Job $job
        Write-Progress -Activity "Extracting $fileName" -Completed
    }
    & PNPUTIL /add-driver "$workingDir\*.inf" /subdirs /install
} else {
    if (-not $infFiles)
    {
        # Write-Output "Extracting $fileName driver pack to $workingDir"
        Start-Process -FilePath $downloadDestination -ArgumentList "/s", "/e=$workingDir" -Wait
        & PNPUTIL /add-driver "$workingDir\*.inf" /subdirs /install
    }
}

# write-verbose -Message Done
Write-DriverPackLog -logFile $logFile -SelectedPackage $selectedPackage -Model $model -Major $major -Minor $minor
# write-warning "Need to run BIOS manually"
[Console]::Write("Your BIOS version is ") + $bios

Pause

# Remove-Item -Path "C:\Dell\CabInstall" -Recurse

# $DebugPreference = "Continue"
# $VerbosePreference = "Continue"
}

$scriptMutexName = 'Global\AutoDriverScriptMutex'
$scriptMutex = [System.Threading.Mutex]::new($false, $scriptMutexName)
$hasScriptMutex = $false

try {
    try {
        $hasScriptMutex = $scriptMutex.WaitOne(0, $false)
    } catch [System.Threading.AbandonedMutexException] {
        $hasScriptMutex = $true
    }

    if (-not $hasScriptMutex) {
        Write-Error "Another AutoDriver instance is already running. Exiting."
        exit 1
    }

    Invoke-AutoDriver
}
finally {
    if ($hasScriptMutex) {
        $scriptMutex.ReleaseMutex() | Out-Null
    }
    $scriptMutex.Dispose()
}
