#***********************************************************************************
# @Author Eric Geiger
#
# Provides a GUI list of machines/computers to choose from to download drivers for.
# Might need to change the PWD - path working directory - Line 145
# If you want a log file or to log to a file edit line between 157 and 165
#***********************************************************************************

# $DebugPreference = "Continue"
# $VerbosePreference = "Continue"

$model=""
$path=""
# $models=[System.Collections.ArrayList]@('Latitude 5480', 'Latitude 5490', 'Latitude 5280', 'Latitude 5290', 'Latitude 5400', 'Latitude 5300 2-in-1', 'Latitude 7390 2-in-1',
#                                         'Latitude 7400 2-in-1', 'Latitude 7480', 'Optiplex 7060', 'Optiplex 9020', )
#'Precision 5510', 'Precision 5520', 'Precision 5530', 'Precision 5530 2-in-1', 'Precision 5540', 
#                                         'XPS 13 9365', 'XPS 13 9370')

# GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$frame = New-Object Windows.Forms.form
$form = New-Object System.Windows.Forms.Form
# $form.Text = "Select a computer"
$form.Size = New-Object System.Drawing.Size(300, 200)
$form.StartPosition = "CenterScreen"

$okButton = New-Object System.Windows.Forms.Button
$okButton.Anchor = "Left"
$okButton.Location = New-Object System.Drawing.Point(25, 120)
$okButton.Size = New-Object System.Drawing.Size(75, 22)
$okButton.Text = "OK"
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Anchor = "Left"
$cancelButton.Location = New-Object System.Drawing.Point(100, 120)
$cancelButton.Size = New-Object System.Drawing.Size(75, 22)
$cancelButton.Text = "Cancel"
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$apply = New-Object System.Windows.Forms.Button
$apply.Anchor = "Left"
$apply.Location = New-Object System.Drawing.Point(175, 120)
$apply.Size = New-Object System.Drawing.Size(75, 22)
$apply.Text = "Apply"
# $apply.DialogResult = [System.Windows.Forms.DialogResult]::
$form.Controls.Add($apply)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280, 20)
$label.Text = "Please select a computer"
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10, 40)
$listBox.Size = New-Object System.Drawing.Size(120, 20)
$listBox.Height = 80

[void] $listBox.Items.Add("Optiplex 7060")
[void] $listBox.Items.Add("Optiplex 7090")
# [void] $listBox.Items.Add("Optiplex 9020")
# [void] $listBox.Items.Add("Precision T1700")
[void] $listBox.Items.Add("Precision Tower 3620")
[void] $listBox.Items.Add("Precision 3650 Tower")
[void] $listBox.Items.Add("Precision 5540")

<#
[void] $listBox.Items.Add("Latitude E5470")
[void] $listBox.Items.Add("Latitude 5480")
[void] $listBox.Items.Add("Latitude 5490")
[void] $listBox.Items.Add("Latitude E5270")
[void] $listBox.Items.Add("Latitude 5280")
[void] $listBox.Items.Add("Latitude 5290")
[void] $listBox.Items.Add("Latitude 7390 2-in-1")
[void] $listBox.Items.Add("Latitude 7400 2-in-1")
[void] $listBox.Items.Add("Precision 5510")
[void] $listBox.Items.Add("Precision 5520")
[void] $listBox.Items.Add("Precision 5530")
[void] $listBox.Items.Add("Precision 5530 2-in-1")
[void] $listBox.Items.Add("Precision 5540")
[void] $listBox.Items.Add("Latitude 5400")
[void] $listBox.Items.Add("Latitude 5300 2-in-1")
[void] $listBox.Items.Add("XPS 13 9365")
[void] $listBox.Items.Add("XPS 13 9370")
[void] $listBox.Items.Add("XPS 13 9380")
#>

# foreach($model in $models)
# {
#    [void] $listBox.Items.AddRange($models)
# }

$listBox.SelectionMode = "MultiExtended"

$form.Controls.Add($listBox)

$form.TopMost = $true

$result = $form.ShowDialog()

$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.InitialDirectory = $initialDirectory
$openFileDialog.Filter = "All Files (*.*) | *.*"
$openFileDialog.FileName

# driverDownload

#-----------------------------------------------------------------------------------------

function Get-FileName($initialDirectory)
{
    # [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.InitialDirectory = $initialDirectory
    $openFileDialog.Filter = "All Files (*.*) | *.*"
    $openFileDialog.ShowDialog() | Out-Null
    $openFileDialog.FileName
}

#-----------------------------------------------------------------------------------------

function Get-FileName
{
[cmdletBinding()]
Param([string]$initialDirectory)

    # [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.InitialDirectory = $initialDirectory
    $openFileDialog.Filter = "*.*"
    $openFileDialog.ShowDialog() | Out-Null
    $openFileDialog.FileName
}

#-----------------------------------------------------------------------------------------

function driversDownload
{
[cmdletBinding()]
Param([string]$model)
# main code
$wc = New-Object System.Net.WebClient

$source = "http://downloads.dell.com/catalog/DriverPackCatalog.cab"
# $ftpSource = "ftp://downloads.dell.com/catalog/DriverPackCatalog.cab"
# $altFtpSource = "ftp://ftp.dell.com/catalog/DriverPackCatalog.cab"

# $pwd = Get-Content $path
$destination = "$pwd" + "\DriverPackCatalog.cab"

$wc.DownloadFile($source, $destination)

#2.

$catalogCabFile = "$pwd" + "\DriverPackCatalog.cab"
$catalogXmlFile = "$pwd" + "\DriverPackCatalog.xml"
# $expansion = Experiment for a progress bar
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

$catalogXmlDoc.DriverPackManifest.DriverPackage| ? {($_.SupportSystems.Brand.Model.name -eq $model)} | sort type # | format-table
# $catalogXmlDoc.DriverPackManifest.DriverPackage| ? {($_.SupportSystems.Brand.Model.name -eq $modelObject.model)} |sort type # | format-table

#5.

$catalogXMLFile = "$pwd" + "\DriverPackCatalog.xml"
[xml]$catalogXMLDoc = Get-Content $catalogXMLFile

# Examples
#--------------------------------------------------------------------------------------------------------------

# $catalogXMLDoc.DriverPackManifest.DriverPackage| ? { ($_.SupportedSystems.Brand.Model.systemID -eq "BIOS ID") -and ($_.type -ne "WinPE") -and
#  ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq "OS Major Version" ) -and ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq "OS Minor Version" )}

# or

# $catalogXMLDoc.DriverPackManifest.DriverPackage| ? { ($_.SupportedSystems.Brand.Model.name -eq "System Name") -and ($_.type -ne "WinPE") -and
#  ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq "OS Major Version" ) -and ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq "OS Minor Version" )}

#--------------------------------------------------------------------------------------------------------------

# Get-Date | Out-File -Append $logFile

<# $catalogXMLDoc.DriverPackManifest.DriverPackage| ? { ($_.SupportedSystems.Brand.Model.name -eq $model) -and
 ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $major) -and
 ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minor)}
 #>
 <# $catalogXMLDoc.DriverPackManifest.DriverPackage| WHERE { ($_.SupportedSystems.Brand.Model.name -eq $model) -and
 ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $major) -and
 ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minor)}
 #>
 # | Out-File -Append $logFile

# [Console]::Write("Log file wrote to ") + $logFile

# Pull all
# $catalogXMLDoc.DriverPackManifest.DriverPackage | ? { ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $major) -and
# ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minor)}

# pause

# $catalogXMLDoc.DriverPackManifest.DriverPackage| ? { ($_.SupportedSystems.Brand.Model.name -eq $modelObject.model) -and
#  ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $major) -and
#   ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minor)}

#-----------------------------------------------------------------------------------------------------------------------------

# 6.

 $catalogXMLFile = "$pwd" + "\DriverPackCatalog.xml"

 [xml]$catalogXMLDoc = Get-Content $catalogXMLFile

<#
 $catalogXMLDoc.DriverPackManifest.DriverPackage| ? { ($_.type -eq "Win") -and 
 ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq "OS Major Version" ) -and 
 ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq "OS Minor Version" )}
# $catalogXMLDoc.DriverPackManifest.DriverPackage| ? { ($_.type -eq "WinPE") -and ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq "OS Major Version" ) -and ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq "OS Minor Version" )}
#>

#-----------------------------------------------------------------------------------------

 $catalogXMLFile = "$pwd" + "\DriverPackCatalog.xml"
[xml]$catalogXMLDoc = Get-Content $catalogXMLFile

# $cabSelected = $catalogXMLDoc.DriverPackManifest.DriverPackage| ? { ($_.SupportedSystems.Brand.Model.name -eq $modelObject.model) -and
#  ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $major) -and
#  ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minor)} #($_.type -eq " WinPE") -and ($_.type -eq " Win") -and 

# foreach($model in $models)
# {

# $majorVersion = [System.environment]::OSVersion.version.Major
# $minorVersion = [System.environment]::OSVersion.version.Minor

# $majorVersion = [Environment]::OSVersion.Version.Major
# $minorVersion = [Environment]::OSVersion.Version.Minor

# (Get-CimInstance Win32_OperatingSystem).Version

$build = (Get-CimInstance -ClassName Win32_OperatingSystem -Namespace root/cimv2).BuildNumber

$version = (Get-CimInstance -ClassName Win32_OperatingSystem).Version -match "(?s)^([0-9]+)\.([0-9]+)"
$minor = $Matches[2]
[string]$major = (Get-CimInstance -ClassName Win32_OperatingSystem).Version -match "(?s)^[0-9]+"
$major = $Matches[0]
$totalVersion = (Get-CimInstance -ClassName Win32_OperatingSystem).Version -match "(?s)^([0-9]+)\.([0-9]+)\.([0-9]+)"
$buildNumber = $Matches[3]
$rev = $Matches[3]

    <# $cabSelected = $catalogXMLDoc.DriverPackManifest.DriverPackage | ? { ($_.SupportedSystems.Brand.Model.name -eq $model) -and
      ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $major) -and
      ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minor)} #>

    $cabSelected = $catalogXMLDoc.DriverPackManifest.DriverPackage | WHERE { ($_.SupportedSystems.Brand.Model.name -eq $model) -and
      ($_.SupportedOperatingSystems.OperatingSystem.majorVersion -eq $major) -and
      ($_.SupportedOperatingSystems.OperatingSystem.minorVersion -eq $minor)}
    
    $arrayList = New-Object System.Collections.ArrayList
    $cabArray = New-Object System.Collections.ArrayList

    # $type = $cabSelected

    # $cab = Split-Path -Leaf $cabSelected.path

    #$cabArray.Add($cab)

    # $cab -match "(?s)^(?<Model>\w?\d+\w?)-(?<os>.+\d+?)-(?<revision>A\d+)-(?<releaseId>.+)\.cab$" # | Out-Null

<#
    ($cab | Select-String -Pattern "(?s)^(?<Model>\w?\d+\w?)-(?<os>.+\d+?)-(?<revision>A\d+)-(?<releaseId>.+)\.cab$" | Select-Object -ExpandProperty Matches).Groups | Out-Null
    ($cab | Select-String -Pattern "(?s)^(?<Model>\w?\d+\w?)-(?<os>.+\d+?)-(?<revision>A\d+)-(?<releaseId>.+)\.cab$").Matches.Groups | Out-Null

    $cab -split "(?s)^(?<Model>\w?\d+\w?)-(?<os>.+\d+?)-(?<revision>A\d+)-(?<releaseId>.+)\.cab$" | Out-Null

    $arrayList = New-Object System.Collections.ArrayList
    $table = New-Object System.Data.DataTable
    $modelCol = New-Object System.Data.DataColumn
    $osCol = New-Object System.Data.DataColumn
    $dellVerCol = New-Object System.Data.DataColumn
    $releaseIdCol = New-Object System.Data.DataColumn
    $table.Columns.Add($modelCol)
    $table.Columns.Add($osCol)
    $table.Columns.Add($dellVerCol)
    $table.Columns.Add($releaseIdCol)
#>
    # $results = 
<#
    $cab -split "(?s)^(?<Model>\w?\d+\w?)-(?<os>.+\d+?)-(?<revision>A\d+)-(?<releaseId>.+)\.cab$" | foreach {
       # $record = @();
        $cabfiles = $_
        $arrayList.Add($cabfiles)
    } | Out-Null
#>
    # $arrayList[2] | Out-Null
    
    <#
    $patterns = [regex]::new("(?s)^(?<Model>\w?\d+\w?)-(?<os>.+\d+?)-(?<revision>A\d+)-(?<releaseId>.+)\.cab$").Matches($cab)
    $pattern = [regex]::new("(?s)^(?<Model>\w?\d+\w?)-(?<os>.+\d+?)-(?<revision>A\d+)-(?<releaseId>.+)\.cab$") #.Matches()
    $pattern.Matches($cab)
    #>
    <#
        $modelId = $Matches[1]
        $modelId = $Matches.Model
        $os = $Matches[2]
        $os = $Matches.os
        $revision = $Matches[3]
        $revision = $Matches.revision
        $release = $Matches[4]
        $release = $Matches.releaseId
    #>

    $hash = $cabSelected.hashMD5
    $releaseId = $cabSelected.releaseID
    $dellVersion = $cabSelected.dellVersion

    if (!(Test-Path -Path "C:\Logs" -PathType Container))
    {
        New-Item -Path "C:\Logs" -ItemType Directory
    }

    $logFile = "C:\Logs\autoDriver.log"

    if (Test-Path -Path "C:\Logs\autoDriver.log" -PathType Leaf)
    {
        $logs = Get-ChildItem "C:\logs\" -Name -Include *.log | Where { $_ -match "^autoDriver\..+$" }
        Get-Content "C:\logs\$logs" | Where { $_ -match "hash.+:\s(?<regHash>.+)" } | Out-Null
        Get-Content "$env:SystemDrive\logs\$logs" | Where { $_ -match "hash.+:\s(?<regHash>.+)" } | Out-Null
        $log = $Matches.regHash
    }

    if (!(Test-Path -Path "C:\Dell\CabInstall\cab" -PathType Container))
    {
        New-Item -Path "C:\Dell\CabInstall\cab" -ItemType Directory
    }

    $pwd = "C:\Dell\CabInstall\cab"

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

    if($rev -lt 22000)
    {
        # $cabDownloadLink = "http://" + $catalogXMLDoc.DriverPackManifest.baseLocation + $cabSelected[0].path
        $cabDownloadLink = "http://" + $catalogXMLDoc.DriverPackManifest.baseLocation + "/" + $cabSelected[0].path
    }

    $Filename = [System.IO.Path]::GetFileName($cabDownloadLink)
    # $downloadDestination = "$pwd" + "\" + $Filename
    $downloadDestination = "$pwd\$Filename"
    # echo "Downloading driver pack. This may take a few minutes."
    Write-output "Downloading driver pack. This may take a few minutes."
    # $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($cabDownloadLink, $downloadDestination)

    $cabSource =  "$pwd" + "\" + $Filename

    EXPAND $cabSource -F:* "$pwd"
    # PNPUTIL /add-driver $pwd\*.inf /subdirs /install
}

#-----------------------------------------------------------------------------------------

$apply.Add_Click(
    {
        if($listBox.SelectedItems.Count -eq 1)
        {
            $model = $listBox.SelectedItem
            driversDownload($model)
        }
    }
)

if($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    if($listBox.SelectedItems.Count -eq 1)
    {
        $model = $listBox.SelectedItem
        driversDownload($model)
    }
    elseif($listBox.SelectedItems.Count -gt 1)
    {
        $models[$listBox.SelectedItems.Count]

        for($i = 0; $i -lt ($listBox.SelectedItems.Count - 1); $i += 1)
        {
            Write-Output $listBox.SelectedItems[$i]
            pause
            $models += $listBox.SelectedItems[$i]
            driversDownload($models[$i])
        }
        pause
        $models += $listBox.SelectedItems
        $openFileDialog.ShowDialog() | Out-Null
        $path = Get-FileName "$env:USERPROFILE" + "\Downloads"
        foreach($model in $models)
        {
            driversDownload($model)
        }


#        $models | foreach($_)
        {

        }
    
 #       ForEach-Object ($model in $models) # -Begin
        {
#            $model = 
        }
    }
}
elseif($result -eq [System.Windows.Forms.Dialogresult]::Cancel)
{
    $form.Close()
}

#-----------------------------------------------------------------------------------------

# Pause

# Remove-Item -Path "C:\Dell\CabInstall" -Recurse

# foreach($model in $models)
<#
{
#     driversDownload($model)
}
#>

<#
#Testing only below

function driversDownload
{
[cmdletBinding()]
Param([string]$models)

# $majorVersion = [System.environment]::OSVersion.version.Major
# $minorVersion = [System.environment]::OSVersion.version.Minor

# $majorVersion = [Environment]::OSVersion.Version.Major
# $minorVersion = [Environment]::OSVersion.Version.Minor

# (Get-CimInstance Win32_OperatingSystem).Version

# $version = (Get-CimInstance -ClassName Win32_OperatingSystem)."Version" -match "(?s)^([0-9]+)\.([0-9]+)"
# $minor = $Matches[2]
# [string]$major = (Get-CimInstance -ClassName Win32_OperatingSystem)."Version" -match "(?s)^[0-9]+"
# $major = $Matches[0]

# $model = (Get-WmiObject -Class Win32_computerSystem -ComputerName . -Namespace root\cimv2).model
# $modelObject = Get-WmiObject -Class Win32_computerSystem -ComputerName . -Namespace root\cimv2
# $modelList = Get-WmiObject -Query "Select * FROM Win32_ComputerSystem" -ComputerName . -Namespace root\cimv2 | Select-Object -Property model | Format-List -Expand EnumOnly
# $modelTable = Get-WmiObject -Query "Select * FROM Win32_ComputerSystem" -ComputerName . -Namespace root\cimv2 | Select-Object -Property model | Format-Table -HideTableHeaders
# if (!(Test-Path -Path "C:\Dell\CabInstall" -PathType Container))

# for($f=0; $f -lt $catalogXmlDoc.DriverPackManifest.DriverPackage.Length-1; $f++)
{
    # $models += $catalogXmlDoc.DriverPackManifest.driverPackage[$f].SupportedSystems.Brand.Model.name
}
#>
