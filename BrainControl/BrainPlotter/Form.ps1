# Define the Form1 class

using module ..\BrainControl.Lib\BtManager.psm1
class Form1 {
    [string]$saveFile
    [System.IO.Ports.SerialPort]$ard
    [BtManager]$bt
    [System.Collections.Generic.Queue[int]]$points = [System.Collections.Generic.Queue[int]]::new()
    [int]$writeThreshold = 0
    [uint]$i = 0
    [double]$focusThreshold = 1.15
    [double]$focusScope = 0.2

    Form1() {
        $this.saveFile = (Get-Date).ToString('dd__HH-mm-ss') + '.csv'
        New-Item -Path $this.saveFile -ItemType File
        $this.startArd('COM4')
        $this.startBT()
    }

    [void]startArd([string]$portName) {
        $this.ard = New-Object System.IO.Ports.SerialPort $portName, 9600
        # $this.ard.Open()
    }

    [void]startBT() {
        $this.bt = New-Object BtManager 'COM10'

        # BT data received
        $this.bt.add_BtDataParsed({
            param($o, $e)

            $this.points.Enqueue($e.rawValue)
            # Update UI elements here

            # Keeps queue and chart counts below max chart x axis
            if ($this.points.Count -gt $chart1.ChartAreas[0].AxisX.Maximum - 1) {
                $this.checkFocusThreshold($this.points)

                $this.points.Dequeue()
                # Update chart here
            }

            # Writes values to CSV
            if (++$this.writeThreshold -ge $chart1.ChartAreas[0].AxisX.Maximum - 1) {
                $this.writeThreshold = 0
                Add-Content -Path $this.saveFile -Value ($this.points -join ',')
            }
        })
    }

    [void]checkFocusThreshold([System.Collections.Generic.IEnumerable[int]]$vals) {
        $fullRange = $vals.ToArray()
        $upperBound = [Math]::Max(0, [Math]::Round($vals.Count * $this.focusScope))
        $focusRange = ($fullRange[0..$upperBound]).Average()

        if ($focusRange -gt $fullRange.Average() * $this.focusThreshold) {
            Write-Host "$($this.i++)  BING BANG BOOM REEEEEE"
            if ($clickCheck.Checked) {
                $this.click()
            }

            if ($checkCom.Checked) {
                # Update UI elements here
                $this.ard.Write('ON')
            }
        }
        else {
            if ($checkCom.Checked) {
                $this.ard.Write('OFF')
            }
        }

        # Update UI elements here
    }
}

# PowerShell does not support direct P/Invoke. You need to use Add-Type to define a C# type that calls the function.
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Mouse {
    [DllImport("user32.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
    public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint cButtons, uint dwExtraInfo);
}
"@

# Define the mouse event constants
$MOUSEEVENTF_LEFTDOWN = 0x02
$MOUSEEVENTF_LEFTUP = 0x04
$MOUSEEVENTF_RIGHTDOWN = 0x08
$MOUSEEVENTF_RIGHTUP = 0x10

# Define the click function
function Click {
    [Mouse]::mouse_event($MOUSEEVENTF_LEFTDOWN -bor $MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
}

# Define the AppendToFile function
function AppendToFile {
    param($path, $txt)

    # PowerShell does not support the lock keyword. You might need to use other synchronization mechanisms if you're writing to the file from multiple threads.
    Add-Content -Path $path -Value $txt -Encoding UTF8
}

# PowerShell does not have a direct equivalent for C# finalizers (destructors).
# You might need to ensure that `ard.Close()` is called when you're done with the `$ard` object.
$ard.Close()