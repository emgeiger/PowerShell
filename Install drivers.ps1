Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

<#
$model = ""
$models = [System.Collections.ArrayList]@(
  'Latitude 5480', 'Latitude E5470', 'Latitude 5490', 'Latitude E5270', 'Latitude 5280', 'Latitude 5285', 'Latitude 5290', 
  'Latitude E7440', 'Latitude 5400', 'Latitude 5300 2-in-1', 'Latitude 7390', 
  'Latitude 7390 2-in-1', 'Latitude 7400 2-in-1', 'Latitude 7480', 
  'Optiplex 7050', 'Optiplex 7060', 'Optiplex 7070', 'Optiplex 9020', 
  'Precision Tower 5810', 'Precision 5510', 'Precision 5520', 'Precision 5530', 'Precision 5530 2-in-1', 
  'Precision 5540', 'Precision 5820 Tower', 'XPS 13 9365', 'XPS 13 9370', 'XPS 13 9380')
#>

# function Get-FileName
function Get-FolderName
{
[cmdletBinding()]
param($initialDirectory)
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.SelectedPath = $initialDirectory
    $folderBrowser.ShowNewFolderButton = $false
    $folderBrowser.Description = "Select a directory"

    if($folderBrowser.ShowDialog() -eq "OK")
    {
        $folder += $folderBrowser.SelectedPath
    }
    return $folder
}

# function Get-FileName($initialDirectory)
function Get-FolderName
{
[cmdletBinding()]
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    # $folderBrowser.SelectedPath = ""
    $folderBrowser.ShowNewFolderButton = $false
    $folderBrowser.Description = "Select a directory"

    if($folderBrowser.ShowDialog() -eq "OK")
    {
        $folder += $folderBrowser.SelectedPath
    }
    return $folder

<#    $fileBrowse = New-Object System.Windows.Forms.openFileDialog
    $fileBrowse.InitialDirectory = $initialDirectory
    $fileBrowse.Filter = "Batch (*.bat)|*.bat | All Files (*.*) | *.*"
    $fileBrowse.ShowDialog() | Out-Null
#>
}

$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
# $folderBrowser.SelectedPath = ""
$folderBrowser.ShowNewFolderButton= $false
$folderBrowser.Description = "Select a directory"
$folder = Get-FolderName

<# $fileBrowse = New-Object System.Windows.Forms.openFileDialog
$fileBrowse.InitialDirectory = "."
$fileBrowse.Filter = "Batch (*.bat)|*.bat | All Files (*.*) | *.*"
$fileBrowse.ShowDialog() | Out-Null
$file = $fileBrowse.FileName
#>

# Register-EngineEvent PowerShell.Exiting

# $null = Register-EngineEvent -SourceIdentifier ` ([System.Management.Automation.PSEngineEvent]::Exiting) -Action {}

<#
$user= ""
$keyFile = ""
$passFile = ""
#>
# $securePass = (Get-Content $passFile) | ConvertTo-SecureString -Key (Get-Content $keyFile)

# Start-Process $file -ArgumentList $user, $securePass

<#
When you create a standard array with @(), you'll use the += operator but to add elements to an 
ArrayList, you'd use the Add method. These methods differ in that the += operator actually destroys
 the existing array and creates a new one with the new item.
#>

# $counts = $models.Count
<#
<#    [array]$models = 'Latitude 5480', 'Latitude E5470', 'Latitude 5490', 'Latitude E5270', 'Latitude 5280', 'Latitude 5285', 'Latitude 5290', 
    'Latitude E7440', 'Latitude 5400', 'Latitude 5300 2-in-1', 'Latitude 7390', 
    'Latitude 7390 2-in-1', 'Latitude 7400 2-in-1', 'Latitude 7480', 
    'Optiplex 7050', 'Optiplex 7060', 'Optiplex 7070', 'Optiplex 9020', 
    'Precision Tower 5810', 'Precision 5510', 'Precision 5520', 'Precision 5530', 'Precision 5530 2-in-1', 
    'Precision 5540', 'Precision 5820 Tower', 'XPS 13 9365', 'XPS 13 9370', 'XPS 13 9380'#>

<#
  $models = 'Latitude 5480', 'Latitude E5470', 'Latitude 5490', 'Latitude E5270', 'Latitude 5280', 'Latitude 5285', 'Latitude 5290', 
    'Latitude E7440', 'Latitude 5400', 'Latitude 5300 2-in-1', 'Latitude 7390', 
    'Latitude 7390 2-in-1', 'Latitude 7400 2-in-1', 'Latitude 7480', 
    'Optiplex 7050', 'Optiplex 7060', 'Optiplex 7070', 'Optiplex 9020', 
    'Precision Tower 5810', 'Precision 5510', 'Precision 5520', 'Precision 5530', 'Precision 5530 2-in-1', 
    'Precision 5540', 'Precision 5820 Tower', 'XPS 13 9365', 'XPS 13 9370', 'XPS 13 9380'#>

<#$models=@(
    'Latitude 5480', 'Latitude E5470', 'Latitude 5490', 'Latitude E5270', 'Latitude 5280', 'Latitude 5285', 'Latitude 5290', 
    'Latitude E7440', 'Latitude 5400', 'Latitude 5300 2-in-1', 'Latitude 7390', 
    'Latitude 7390 2-in-1', 'Latitude 7400 2-in-1', 'Latitude 7480', 
    'Optiplex 7050', 'Optiplex 7060', 'Optiplex 7070', 'Optiplex 9020', 
    'Precision Tower 5810', 'Precision 5510', 'Precision 5520', 'Precision 5530', 'Precision 5530 2-in-1', 
    'Precision 5540', 'Precision 5820 Tower', 'XPS 13 9365', 'XPS 13 9370', 'XPS 13 9380')#>
#>

#Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Install drivers"
$form.Size = New-Object System.Drawing.Size(300, 200)
$form.ShowInTaskbar = $true
$form.StartPosition = "CenterScreen"
$form.TopLevel = $true
$form.TopMost = $false
# $form.Visible = $true
# $form.ShowInTaskbar = $true

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10, 20)
$textBox.Size = New-Object System.Drawing.Size(00, 20)
$textBox.Multiline = $false
$textBox.Height = 20
$textBox.Width = 200
$textBox.Text = $folder
$form.Controls.Add($textBox)

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(50, 110)
$okButton.Size = New-Object System.Drawing.Size(75, 20)
$okButton.Text = "Install"
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(150, 110)
$cancelButton.Size = New-Object System.Drawing.Size(75, 20)
$cancelButton.Text = "Cancel"
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$result = $form.ShowDialog()

if($cancelButton.DialogResult -eq $result)
{
    $form.Close()
}
elseif($okButton.DialogResult -eq $result)
{
    Get-ChildItem $textBox.Text -Recurse -Filter "*.inf" | ForEach-Object { PNPUTIL /add-driver $_.FullName /subdirs /install }
}