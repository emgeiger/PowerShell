#main code
$wc = New-Object System.Net.WebClient

function logFile
{
[cmdletBinding()]
param([string]$logFile)

$catalogXMLDoc.DriverPackManifest.DriverPackage| ? { ($_.SupportedSystems.Brand.Model.name -eq $model) -and
 ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $major) -and
 ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minor)} | Out-File $logFile

 Get-Date | Out-File -Append $logFile

[Console]::Write("Log file wrote to ") + $logFile
}

# $majorVersion = [System.environment]::OSVersion.version.Major
# $minorVersion = [System.environment]::OSVersion.version.Minor

# $majorVersion = [Environment]::OSVersion.Version.Major
# $minorVersion = [Environment]::OSVersion.Version.Minor

# (Get-CimInstance Win32_OperatingSystem).Version

$version = (Get-CimInstance -ClassName Win32_OperatingSystem)."Version" -match "(?s)^([0-9]+)\.([0-9]+)"
$minor = $Matches[2]
[string]$major = (Get-CimInstance -ClassName Win32_OperatingSystem)."Version" -match "(?s)^[0-9]+"
$major = $Matches[0]

$model = (Get-WmiObject -Class Win32_computerSystem -ComputerName . -Namespace root\cimv2).model
# $modelObject = Get-WmiObject -Class Win32_computerSystem -ComputerName . -Namespace root\cimv2
# $modelList = Get-WmiObject -Query "Select * FROM Win32_ComputerSystem" -ComputerName . -Namespace root\cimv2 | Select-Object -Property model | Format-List -Expand EnumOnly
# $modelTable = Get-WmiObject -Query "Select * FROM Win32_ComputerSystem" -ComputerName . -Namespace root\cimv2 | Select-Object -Property model | Format-Table -HideTableHeaders
if (!(Test-Path -Path "C:\Dell\CabInstall" -PathType Container))
{
    New-Item -Path "C:\Dell\CabInstall" -ItemType Directory
}
$source = "http://downloads.dell.com/catalog/DriverPackCatalog.cab"
$ftpSource = "ftp://downloads.dell.com/catalog/DriverPackCatalog.cab"
$altFtpSource = "ftp://ftp.dell.com/catalog/DriverPackCatalog.cab"
$pwd = "C:\Dell\CabInstall"
$destination = "$pwd" + "\DriverPackCatalog.cab "

Invoke-WebRequest $source $destination
# $wc.DownloadFile($source, $destination)
wget $source $destination

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

# $catalogXMLDoc.DriverPackManifest.DriverPackage | Where-Object { ($_.SupportedSystems.Brand.Model.systemID -eq "BIOS ID") -or ($_.type -eq "WinPE")} |sort type
# or
# $catalogXMLDoc.DriverPackManifest.DriverPackage | Where-Object { ($_.SupportedSystems.Brand.Model.name -eq "System Name") -or ($_.type -eq "WinPE")} |sort type

$catalogXmlDoc.DriverPackManifest.DriverPackage | Where-Object {($_.SupportSystems.Brand.Model.name -eq $model)} |Sort-Object type # | format-table
# $catalogXmlDoc.DriverPackManifest.DriverPackage | Where-Object {($_.SupportSystems.Brand.Model.name -eq $modelObject.model)} |Sort-Object type # | format-table

#5.

$catalogXMLFile = "$pwd" + "\DriverPackCatalog.xml"
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

# 6.

 $catalogXMLFile = "$pwd" + "\DriverPackCatalog.xml"

 [xml]$catalogXMLDoc = Get-Content $catalogXMLFile

 $catalogXMLDoc.DriverPackManifest.DriverPackage | Where-Object { ($_.type -eq "Win") -and 
 ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq "OS Major Version" ) -and 
 ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq "OS Minor Version" )}
# $catalogXMLDoc.DriverPackManifest.DriverPackage | Where-Object { ($_.type -eq "WinPE") -and ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq "OS Major Version" ) -and ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq "OS Minor Version" )}

#-----------------------------------------------------------------------------------------

$catalogXMLFile = "$pwd" + "\DriverPackCatalog.xml"
[xml]$catalogXMLDoc = Get-Content $catalogXMLFile

# $cabSelected = $catalogXMLDoc.DriverPackManifest.DriverPackage | Where-Object { ($_.SupportedSystems.Brand.Model.name -eq $modelObject.model) -and
#   ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $major ) -and
#   ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minor )} #($_.type -eq " WinPE") -and ($_.type -eq " Win") -and 

 $cabSelected = $catalogXMLDoc.DriverPackManifest.DriverPackage | Where-Object { ($_.SupportedSystems.Brand.Model.name -eq $model) -and
  ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $major ) -and
  ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minor )}

$cab = Split-Path -Leaf $cabSelected.path

$hash = $cabSelected.hashMD5
$releaseId = $cabSelected.releaseID
$dellVersion = $cabSelected.dellVersion

if (!(Test-Path -Path "C:\Logs" -PathType Container))
{
    New-Item -Path "C:\Logs" -ItemType Directory
}

$logFile = "C:\Logs\autoDriver.log"

$logs = Get-ChildItem "C:\logs\" -Name -Include *.log | Where-Object { $_ -match "^autoDriver\..+$" }
Get-Content "C:\logs\$logs" | Where-Object { $_ -match "hash.+:\s(?<regHash>.+)" } | Out-Null
Get-Content "$env:SystemDrive\logs\$logs" | Where-Object { $_ -match "hash.+:\s(?<regHash>.+)" } | Out-Null
$log = $Matches.regHash

if (!(Test-Path -Path "C:\Dell\CabInstall\cab" -PathType Container))
{
    New-Item -Path "C:\Dell\CabInstall\cab" -ItemType Directory
}

$pwd = "C:\Dell\CabInstall\cab"

if(Test-Path -Path "C:\Dell\CabInstall\cab\$cab" -PathType Leaf -Include *.cab)
{
    $cabFile = Get-ChildItem "C:\Dell\CabInstall\cab" -Name -Include *.cab
    $cabFile -match "(?s)^(?<Model>\d+\w?)-(?<os>win.+)-(?<revision>A\d+)-(?<releaseId>.+)\.cab$" | Out-Null

#   $cabFile | Select-String -Pattern "(?s)^(\d+\w?)-(win.+)-(A\d+)-(.+)\.cab$"
    
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

# $cabDownloadLink = "http://" + $catalogXMLDoc.DriverPackManifest.baseLocation + $cabSelected.path
$cabDownloadLink = "http://" + $catalogXMLDoc.DriverPackManifest.baseLocation + "/" + $cabSelected.path
$Filename = [System.IO.Path]::GetFileName($cabDownloadLink)
# $fileName  = Split-Path -Leaf $cabDownloadLink
$fileName  = Split-Path -Leaf $cabSelected.path
$downloadDestination = "$pwd" + "\" + $fileName
# echo "Downloading driver pack. This may take a few minutes."
Write-output "Downloading driver pack. This may take a few minutes."
Invoke-WebRequest -Uri $cabDownloadLink -OutFile $downloadDestination
# $wc = New-Object System.Net.WebClient
$wc.DownloadFile($cabDownloadLink, $downloadDestination)

$cabSource =  $pwd + "\" + $Filename

# $cabDestination = $pwd + "\" + $Filename
EXPAND $cabSource $pwd -F:*
PNPUTIL /add-driver $pwd\*.inf /subdirs /install

if (!(Test-Path -Path "C:\Logs" -PathType Container))
{
    New-Item -Path "C:\Logs" -ItemType Directory
}

# write-verbose -Message Done
logFile($logFile)
write-warning "Need to run BIOS manually"

Pause

# Remove-Item -Path "C:\Dell\CabInstall" -Recurse

# $DebugPreference = "Continue"
# $VerbosePreference = "Continue"

<#
# Testing

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$frame = New-Object Windows.Forms.form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Select a computer"
$form.Size = New-Object System.Drawing.Size(300, 200)
$form.StartPosition = "CenterScreen"

$logFile = "C:\logs\autoDriver.log"

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(50, 120)
$okButton.Size = New-Object System.Drawing.Size(50, 22)
$okButton.Text = "OK"
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(100, 120)
$cancelButton.Size = New-Object System.Drawing.Size(50, 22)
$cancelButton.Text = "Cancel"
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$apply = New-Object System.Windows.Forms.Button
$apply.Location = New-Object System.Drawing.Point(150, 120)
$apply.Size = New-Object System.Drawing.Size(50, 22)
$apply.Text = "Apply"
# $apply.DialogResult = [System.Windows.Forms.DialogResult]::

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280, 20)
$label.Text = "Please select a computer"
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10, 40)
$listBox.Size = New-Object System.Drawing.Size(120, 20)
$listBox.Height = 80

[void] $listBox.Items.Add("")

# $listBox.SelectionMode = "MultiExtended"

$form.Controls.Add($listBox)

$form.TopMost = $true

$result = $form.ShowDialog()

if($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $model = $listBox.SelectedItem
}
elseif($result -eq [System.Windows.Forms.Dialogresult]::Cancel)
{
    $form.Close()
}
#>
