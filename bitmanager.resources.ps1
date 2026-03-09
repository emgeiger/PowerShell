Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

$frame = New-Object System.Windows.Forms.Form
$frame.Size = New-Object System.Drawing.Size(1200, 600)
$frame.StartPosition = "CenterScreen"
$frame.Visible = $true
