Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

$components = New-Object System.ComponentModel.IContainer

function dispose
{
[cmdletBinding()]
params(boolean $disposing)
    
    if($disposing -and ($components -ne $null))
    {
        $components.Dispose()
    }
    base.Dispose($disposing)
}

$frame = New-Object System.Windows.Forms.Form
$frame.Size = New-Object System.Drawing.Size(1200, 600)
$frame.StartPosition = "CenterScreen"
$frame.Visible = $true

$fullFocusAverageLabel = New-Object System.Windows.Forms.Label
$fullFocusAverageLabel.Text = "Full Focus Average"
$frame.Controls.Add($fullFocusAverageLabel)

$fullFocusAverage = New-Object System.Windows.Forms.Label
$fullFocusAverage.Text = ""
$frame.Controls.Add($fullFocusAverage)

$sampleBufferAverageLabel = New-Object System.Windows.Forms.Label
$sampleBufferAverageLabel.Text = "Sample Buffer Average"
$frame.Controls.Add($sampleBufferAverageLabel)

$sampleBufferAverage = New-Object System.Windows.Forms.Label
$sampleBufferAverage.Text = ""
$frame.Controls.Add($sampleBufferAverage)

$serialComOnfocus = New-Object System.Windows.Forms.CheckBox
$serialComOnfocus.Text = "Serial Com on Focus"
$frame.Controls.Add($serialComOnfocus)

$clickOnFocus = New-Object System.Windows.Forms.CheckBox
$clickOnFocus.Text = "Click on Focus"
$frame.Controls.Add($clickOnFocus)

# $bt = [System.IO.Ports.SerialPort]
[int]MAX_PACKET_LENGTH = 32
[int]EEG_POWER_BANDS = 8
[byte]$lastByte
[bool]inPacket = $false
[bool]freshPacket = $false
[int]packetIndex = 0
[int]checksumAccuumulator = 0
[int]packetLength = 0
[int]checkSum = 0
[uint64[]]$eegPower = [$EEG_POWER_BANDS]
[byte[]]$packetData = [$MAX_PACKETS_BANDS]

[int]s$ignalQuality = 200
[int]$focus = 0
[int]$meditation = 0

function btManager
{
   [CmdletBinding()]
   param ([string] comPort)

   $bt = New-Object System.IO.Ports.SerialPort comPort, 9600, none, 8, one
   $bt.DataReceived += BtDataReceived
}

function initComponents
{
   $chart = New-Object System.windows.Forms.DataVisualizations.charting.chart
   $tableLayout = New-Object System.Windows.Forms.TableLayoutPanel
   $flowLayout = New-Object System.Windows.Forms.FlowLayoutPanel
   $chartArea = New-Object System.Windows.Forms.DataVisualizations.Charting.ChartArea
   $legend = New-Object System.Windows.Forms.DataVisualizations.Charting.Legend
   $series = New-Object System.Windows.Forms.DataVisualizations.Charting.Series
}