# $DebugPreference = "Continue"
# $VerbosePreference = "Continue"
$wc = New-Object System.Net.WebClient
$majorVersion = [System.environment]::OSVersion.version.Major
$minorVersion = [System.environment]::OSVersion.version.Minor
$model = (Get-WmiObject -Class Win32_computerSystem -ComputerName . -Namespace root\cimv2).model
$modelObject = Get-WmiObject -Class Win32_computerSystem -ComputerName . -Namespace root\cimv2
$modelList = Get-WmiObject -Query "Select * FROM Win32_ComputerSystem" -ComputerName . -Namespace root\cimv2 | Select-Object -Property model | Format-List -Expand EnumOnly
$modelTable = Get-WmiObject -Query "Select * FROM Win32_ComputerSystem" -ComputerName . -Namespace root\cimv2 | Select-Object -Property model | Format-Table -HideTableHeaders
if (!(Test-Path -Path "C:\Dell\CabInstall" -PathType Container))
{
    New-Item -Path "C:\Dell\CabInstall" -ItemType Directory
}
$source = "http://downloads.dell.com/catalog/DriverPackCatalog.cab"
$ftpSource = "ftp://downloads.dell.com/catalog/DriverPackCatalog.cab"
$altFtpSource = "ftp://ftp.dell.com/catalog/DriverPackCatalog.cab"
$pwd = "C:\Dell\CabInstall"
$destination = "$pwd" + "\DriverPackCatalog.cab"

$wc.DownloadFile($source, $destination)

#2.

$catalogCabFile = "$pwd" + "\DriverPackCatalog.cab"
$catalogXmlFile = "$pwd" + "\DriverPackCatalog.xml"
EXPAND $catalogCabFile $catalogXmlFile

#3.

$catalogXmlFile = "$pwd" + "\DriverPackCatalog.xml"
[xml]$catalogXmlDoc = Get-Content $catalogXmlFile

# $catalogXMLDoc.DriverPackManifest.DriverPackage | Select-Object @{Expression={$_.SupportedSystems.Brand.key};Label="LOBKey";}, @{Expression=
# {$_.SupportedSystems.Brand.prefix};Label="LOBPrefix";}, @{Expression={$_.SupportedSystems.Brand.Model.systemID};Label="SystemID";}, @{Expression=
# {$_.SupportedSystems.Brand.Model.name};Label="SystemName";} –unique

#4.

$catalogXMLFile = "$pwd" + "\DriverPackCatalog.xml"
[xml]$catalogXMLDoc = Get-Content $catalogXMLFile

# $catalogXMLDoc.DriverPackManifest.DriverPackage| ? { ($_.SupportedSystems.Brand.Model.systemID -eq "BIOS ID") -or ($_.type -eq "WinPE")} |sort type
# or
# $catalogXMLDoc.DriverPackManifest.DriverPackage| ? { ($_.SupportedSystems.Brand.Model.name -eq "System Name") -or ($_.type -eq "WinPE")} |sort type

$catalogXmlDoc.DriverPackManifest.DriverPackage| ? {($_.SupportSystems.Brand.Model.name -eq $model)} |sort type # | format-table
$catalogXmlDoc.DriverPackManifest.DriverPackage| ? {($_.SupportSystems.Brand.Model.name -eq $modelObject.model)} |sort type # | format-table

#5.

$catalogXMLFile = "$pwd" + "\DriverPackCatalog.xml"
[xml]$catalogXMLDoc = Get-Content $catalogXMLFile

# $catalogXMLDoc.DriverPackManifest.DriverPackage| ? { ($_.SupportedSystems.Brand.Model.systemID -eq "BIOS ID") -and ($_.type -ne "WinPE") -and
#  ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq "OS Major Version" ) -and ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq "OS Minor Version" )}

# or

# $catalogXMLDoc.DriverPackManifest.DriverPackage| ? { ($_.SupportedSystems.Brand.Model.name -eq "System Name") -and ($_.type -ne "WinPE") -and
#  ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq "OS Major Version" ) -and ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq "OS Minor Version" )}

#--------------------------------------------------------------------------------------------------------------

# $catalogXMLDoc.DriverPackManifest.DriverPackage| ? { ($_.SupportedSystems.Brand.Model.name -eq $model) -and
#  ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $majorVersion ) -and
#   ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minorVersion )}

# $catalogXMLDoc.DriverPackManifest.DriverPackage| ? { ($_.SupportedSystems.Brand.Model.name -eq $modelObject.model) -and
#  ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $majorVersion ) -and
#   ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minorVersion )}

#-----------------------------------------------------------------------------------------------------------------------------

# 6.

 $catalogXMLFile = "$pwd" + "\DriverPackCatalog.xml"

 [xml]$catalogXMLDoc = Get-Content $catalogXMLFile

 $catalogXMLDoc.DriverPackManifest.DriverPackage| ? { ($_.type -eq "Win") -and 
 ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq "OS Major Version" ) -and 
 ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq "OS Minor Version" )}
# $catalogXMLDoc.DriverPackManifest.DriverPackage| ? { ($_.type -eq "WinPE") -and ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq "OS Major Version" ) -and ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq "OS Minor Version" )}

#-----------------------------------------------------------------------------------------

 $catalogXMLFile = "$pwd" + "\DriverPackCatalog.xml"
[xml]$catalogXMLDoc = Get-Content $catalogXMLFile

 $cabSelected = $catalogXMLDoc.DriverPackManifest.DriverPackage| ? { ($_.SupportedSystems.Brand.Model.name -eq $modelObject.model) -and
  ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $majorVersion ) -and
  ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minorVersion )} #($_.type -eq " WinPE") -and ($_.type -eq " Win") -and 

 $cabSelected = $catalogXMLDoc.DriverPackManifest.DriverPackage| ? { ($_.SupportedSystems.Brand.Model.name -eq $model) -and
  ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $majorVersion ) -and
  ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minorVersion )}

# $cabDownloadLink = "http://" + $catalogXMLDoc.DriverPackManifest.baseLocation + $cabSelected.path
$cabDownloadLink = "http://" + $catalogXMLDoc.DriverPackManifest.baseLocation + "/" + $cabSelected.path
$Filename = [System.IO.Path]::GetFileName($cabDownloadLink)
$downlodDestination = "$pwd" + "\" + $Filename
# echo "Downloading driver pack. This may take a few minutes."
Write-output "Downloading driver pack. This may take a few minutes."
# $wc = New-Object System.Net.WebClient
$wc.DownloadFile($cabDownloadLink, $downlodDestination)

if (!(Test-Path -Path "C:\Dell\CabInstall\cab" -PathType Container))
{
    New-Item -Path "C:\Dell\CabInstall\cab" -ItemType Directory
}
$cabSource =  $pwd + "\" + $Filename
$pwd = "C:\Dell\CabInstall\cab"
# $cabDestination = $pwd + "\" + $Filename
EXPAND $cabSource $pwd -F:*
PNPUTIL /add-driver $pwd\*.inf /subdirs /install

Pause

Remove-Item -Path "C:\Dell\CabInstall" -Recurse