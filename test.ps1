# $Script:pathPanel = Split-Path -Parent $MyInvocation.MyCommand.Definition

function Get-FileName
{
[cmdletBinding()]
param($initialDirectory)
    $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
    $fileBrowser.Multiselect = $false
    $fileBrowser.Filter = 'XML files (*.xml)|*.xaml;*.xml'

    if($fileBrowser.ShowDialog() -eq "OK")
    {
        $file += $fileBrowser.FileName
    }
    return $file

<#    $fileBrowse = New-Object System.Windows.Forms.openFileDialog
    $fileBrowse.InitialDirectory = $initialDirectory
    $fileBrowse.Filter = "Batch (*.bat)|*.bat | All Files (*.*) | *.*"
    $fileBrowse.ShowDialog() | Out-Null
#>
}

function Get-FileName($initialDirectory)
{
[cmdletBinding()]
    $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
    $fileBrowser.Multiselect = $false
    $fileBrowser.Filter = 'XML files (*.xml)|*.xaml;*.xml'

    if($fileBrowser.ShowDialog() -eq "OK")
    {
        $file = $fileBrowser.FileName
    }
    return $file
}

$xmlFile = Get-FileName

function Load-XML
{
[cmdletBinding()]
Param($file)
    $xmlLoader = New-Object System.Xml.XmlDocument
    $xmlLoader.Load($file)
    return $xmlLoader
}

function Load-XAML($file)
{
[cmdletBinding()]
    $xmlLoader = New-Object System.Xml.XmlDocument
    $xmlLoader.Load($file)
    return $xmlLoader
}

    $xmlMainWindow = Load-XAML $xmlFile
    # $reader = New-Object System.Xml.XmlReader $xmlMainWindow
    # $form = [System.Windows.Markup.XamlReader]::Load($reader)

#    $form.ShowDialog() | Out-Null
