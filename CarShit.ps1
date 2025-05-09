Add-Type -AssemblyName System
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization.Charting

# Add mouse click functionality
$C_Sharp = @"
[DllImport("user32.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint cButtons, uint dwExtraInfo);

public static void Click()
{
    mouse_event(0x02 | 0x04, 0, 0, 0, 0); // LEFTDOWN | LEFTUP
}
"@
# $MouseClick = Add-Type -MemberDefinition $C_Sharp -Name "MouseClickUtils" -Namespace "WinAPIUtils" -PassThru

# Constants
$FOCUS_THRESHOLD = 1.15
$FOCUS_SCOPE = 0.2
$MAX_PACKET_LENGTH = 32
$EEG_POWER_BANDS = 8

# Create main form
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = "BrainPlotter PowerShell"
$mainForm.Size = New-Object System.Drawing.Size(800, 600)
$mainForm.StartPosition = "CenterScreen"

# Create chart
$chart = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
$chart.Width = 750
$chart.Height = 400
$chart.Left = 25
$chart.Top = 25
$chartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$chart.ChartAreas.Add($chartArea)
$chartArea.AxisX.Minimum = 0
$chartArea.AxisX.Maximum = 100
$chartArea.AxisY.Minimum = 0
$chartArea.AxisY.Maximum = 1000
$series = New-Object System.Windows.Forms.DataVisualization.Charting.Series
$series.ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Line
$chart.Series.Add($series)
$mainForm.Controls.Add($chart)

# Create labels
$fullAverageLabel = New-Object System.Windows.Forms.Label
$fullAverageLabel.Text = "Full Focus Average:" # 0"
$fullAverageLabel.Left = 25
$fullAverageLabel.Top = 440
$fullAverageLabel.Width = 200
$mainForm.Controls.Add($fullAverageLabel)

$sampleLabel = New-Object System.Windows.Forms.Label
$sampleLabel.Text = "Sample Buffer Average:" # 0"
$sampleLabel.Left = 25
$sampleLabel.Top = 470
$sampleLabel.Width = 200
$mainForm.Controls.Add($sampleLabel)

# Create checkboxes
$clickCheck = New-Object System.Windows.Forms.CheckBox
$clickCheck.Text = "Enable Mouse Click"
$clickCheck.Left = 300
$clickCheck.Top = 440
$clickCheck.Width = 150
$mainForm.Controls.Add($clickCheck)

$checkCom = New-Object System.Windows.Forms.CheckBox
$checkCom.Text = "Enable Arduino Communication"
$checkCom.Left = 300
$checkCom.Top = 470
$checkCom.Width = 200
$mainForm.Controls.Add($checkCom)

# Create text box for logs
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Multiline = $true
$textBox.ScrollBars = "Vertical"
$textBox.Left = 500
$textBox.Top = 440
$textBox.Width = 275
$textBox.Height = 100
$mainForm.Controls.Add($textBox)

# Initialize variables
$points = New-Object System.Collections.Generic.Queue[int]
$saveFile = "$([DateTime]::Now.ToString('dd__HH-mm-ss')).csv"
$null = New-Item -Path $saveFile -ItemType File -Force
$i = 0
$writeThreshold = 0

# Create Arduino Serial Port
$ard = New-Object System.IO.Ports.SerialPort
$ard.PortName = "COM4"
$ard.BaudRate = 9600

function Start-Arduino {
    try {
        if (-not $ard.IsOpen) {
            $ard.Open()
            $textBox.AppendText("Arduino connected on " + $ard.PortName + "`n") # COM4`n")
        }
    }
    catch {
        $textBox.AppendText("Failed to connect to Arduino: $_`n")
    }
}

# BCI Connection and Packet processing functions
function Start-BtConnection
{
    try {
        $script:bt = New-Object System.IO.Ports.SerialPort
        $script:bt.PortName = "COM10"
        $script:bt.BaudRate = 9600
        $script:bt.Parity = [System.IO.Ports.Parity]::None
        $script:bt.DataBits = 8
        $script:bt.StopBits = [System.IO.Ports.StopBits]::One
        $script:bt.Open()
        
        # Setup variables for packet processing
        $script:lastByte = 0
        $script:inPacket = $false
        $script:freshPacket = $false
        $script:packetIndex = 0
        $script:checksumAccumulator = 0
        $script:packetLength = 0
        $script:checkSum = 0
        $script:eegPower = New-Object uint[] $EEG_POWER_BANDS
        $script:packetData = New-Object byte[] $MAX_PACKET_LENGTH
        $script:signalQuality = 200
        $script:focus = 0
        $script:meditation = 0
        
        # Set up event handler
        $script:bt.add_DataReceived({
            $sender = $Event.Sender
            $len = $sender.BytesToRead
            $buffer = New-Object byte[] $len
            $sender.Read($buffer, 0, $len)
            
            $sampleBuffer = New-Object byte[] 256
            
            if($buffer.Length -ge 256) {
                [Array]::Copy($buffer, $sampleBuffer, 256)
            }
            
            foreach($b in $sampleBuffer) {
                if ($script:inPacket) {
                    if ($script:packetIndex -eq 0) {
                        $script:packetLength = $b
                        
                        if ($script:packetLength -gt $MAX_PACKET_LENGTH) {
                            $script:inPacket = $false
                        }
                    }
                    elseif($script:packetIndex -le $script:packetLength) {
                        $script:packetData[$script:packetIndex - 1] = $b
                        $script:checksumAccumulator += $b
                    }
                    elseif($script:packetIndex -gt $script:packetLength) {
                        $script:checkSum = $b
                        $script:checksumAccumulator = 255 - $script:checksumAccumulator
                        
                        if($script:checkSum -eq $script:checksumAccumulator) {
                            if (Parse-Packet) {
                                $script:freshPacket = $true
                            }
                            else {
                                Write-Host "ERROR: PARSING PACKET FAILED"
                            }
                        }
                        $script:inPacket = $false
                    }
                    $script:packetIndex++
                }
                
                if ($b -eq 170 -and $script:lastByte -eq 170 -and -not $script:inPacket) {
                    $script:inPacket = $true
                    $script:packetIndex = 0
                    $script:checksumAccumulator = 0
                }
                
                $script:lastByte = $b
            }
            
            if ($script:freshPacket) {
                $script:freshPacket = $false
            }
        })
        
        $textBox.AppendText("BCI device connected on " + $script:bt.PortName + "`n") # COM10`n")
        return $true
    }
    catch {
        $textBox.AppendText("Failed to connect to BCI device: $_`n")
        return $false
    }
}

function Parse-Packet
{
    $parseSuccess = $true
    $rawValue = 0
    
    # Clear EEG Power
    for ($i = 0; $i -lt $EEG_POWER_BANDS; $i++) {
        $script:eegPower[$i] = 0
    }
    
    for ($i = 0; $i -lt $script:packetLength; $i++) {
        switch ($script:packetData[$i]) {
            0x2 {
                $script:signalQuality = $script:packetData[++$i]
            }
            0x4 {
                $script:focus = $script:packetData[++$i]
            }
            0x5 {
                $script:meditation = $script:packetData[++$i]
            }
            0x83 {
                $i++
                for ($j = 0; $j -lt $EEG_POWER_BANDS; $j++) {
                    $script:eegPower[$j] = ([uint]$script:packetData[++$i] -shl 8) -bor $script:packetData[++$i]
                }
            }
            0x80 {
                $i++
                $rawValue = ($script:packetData[++$i] -shl 8) -bor $script:packetData[++$i]
            }
            default {
                $parseSuccess = $false
            }
        }
    }
    
    # Process the raw value - this happens on the UI thread
    $mainForm.Invoke([Action]{
        $script:points.Enqueue($rawValue)
        $fullAverageLabel.Text = "Full Focus Average: $([int]($script:points | Measure-Object -Average).Average)"
        
        $chart.Series[0].Points.Add($rawValue)
        
        if ($script:points.Count -gt $chart.ChartAreas[0].AxisX.Maximum - 1) {
            Check-FocusThreshold $script:points
            
            $null = $script:points.Dequeue()
            $chart.Series[0].Points.RemoveAt(0)
        }
        
        if (++$script:writeThreshold -ge $chart.ChartAreas[0].AxisX.Maximum - 1) {
            $script:writeThreshold = 0
            $values = $script:points -join ","
            Add-Content -Path $saveFile -Value $values
        }
    })
    
    return $parseSuccess
}

function Check-FocusThreshold {
    param([System.Collections.Generic.IEnumerable[int]]$vals)
    
    $fullRange = $vals | ForEach-Object { $_ }
    $scopeCount = [int]($vals.Count * $FOCUS_SCOPE)
    $focusRange = ($fullRange | Select-Object -First $scopeCount | Measure-Object -Average).Average
    $fullAverage = ($fullRange | Measure-Object -Average).Average
    
    if ($focusRange -gt $fullAverage * $FOCUS_THRESHOLD) {
        Write-Host "$($script:i++) BING BANG BOOM REEEEEE"
        
        if ($clickCheck.Checked) {
            [WinAPIUtils.MouseClickUtils]::Click()
        }
        
        if ($checkCom.Checked) {
            $textBox.AppendText("$($script:i) REEEE TRIGGERED`n")
            if ($ard.IsOpen) {
                $ard.Write("ON")
            }
        }
    }
    else {
        if ($checkCom.Checked -and $ard.IsOpen) {
            $ard.Write("OFF")
        }
    }
    
    $sampleLabel.Text = "Sample Buffer Average: $focusRange"
}

# Start the connections
$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = "Start BCI"
$startButton.Left = 25
$startButton.Top = 500
$startButton.Width = 100
$startButton.Add_Click({
    $success = Start-BtConnection
    if ($success) {
        Start-Arduino
    }
})
$mainForm.Controls.Add($startButton)

# Show the form
[void]$mainForm.ShowDialog()

# Clean up on exit
if ($bt -and $bt.IsOpen) {
    $bt.Close()
}

if ($ard -and $ard.IsOpen) {
    $ard.Close()
}