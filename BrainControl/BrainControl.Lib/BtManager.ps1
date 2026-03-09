<# Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $PSScriptRoot 'bitmanager.designer.ps1')
$Form1.ShowDialog()
#>

using namespace System
using namespace System.Collections.Generic
using namespace System.IO.Ports

# Define a custom class for BtManager
class BtManager {
    static [int]$MAX_PACKET_LENGTH = 32
    static [int]$EEG_POWER_BANDS = 8

    [System.IO.Ports.SerialPort]$bt
    [byte]$lastByte
    [bool]$inPacket = $false
    [bool]$freshPacket = $false
    [int]$packetIndex = 0
    [int]$checksumAccumulator = 0
    [int]$packetLength = 0
    [int]$checkSum = 0
    [uint[]]$eegPower = New-Object uint[] $([BtManager]::EEG_POWER_BANDS)
    [byte[]]$packetData = New-Object byte[] $([BtManager]::MAX_PACKET_LENGTH)
    [int]$signalQuality = 200
    [int]$focus = 0
    [int]$meditation = 0

    BtManager([string]$comPort) {
        $this.bt = New-Object System.IO.Ports.SerialPort $comPort, 9600, 'None', 8, 'One'
        $this.bt.add_DataReceived({ param($sender, $e) $this.BtDataReceived($sender, $e) })
        $this.bt.Open()
    }

    function On-BtDataParsed {
        param($e)
    
        if ($script:BtDataParsed -ne $null) {
            & $script:BtDataParsed $this, $e
        }
    }
    
}

function BtDataReceived {
    param([System.object]$o, $e)

    $sender = [System.IO.Ports.SerialPort]$o

    $len = $sender.BytesToRead
    $buffer = New-Object byte[] $len
    $sender.Read($buffer, 0, $len)

    $sampleBuffer = New-Object byte[] 256

    if($buffer.Length -ge 256) {
        [Array]::Copy($buffer, $sampleBuffer, 256)
    }

    foreach ($b in $sampleBuffer) {
        if ($inPacket) {
            if ($packetIndex -eq 0) {
                $packetLength = $b

                if ($packetLength -gt $MAX_PACKET_LENGTH) {
                    $inPacket = $false
                }
            }
            elseif($packetIndex -le $packetLength) {
                $packetData[$packetIndex - 1] = $b

                $checksumAccumulator += $b
            }
            elseif($packetIndex -gt $packetLength) {
                $checkSum = $b
                $checksumAccumulator = 255 - $checksumAccumulator

                if($checkSum -eq $checksumAccumulator) {
                    if (Parse-Packet) {
                        $freshPacket = $true
                    }
                    else {
                        Write-Host "ERROR: PARSING PACKET FAILED"
                    }
                }
                $inPacket = $false
            }
            $packetIndex++
        }

        if ($b -eq 170 -and $lastByte -eq 170 -and !$inPacket) {
            $inPacket = $true
            $packetIndex = 0
            $checksumAccumulator = 0
        }

        $lastByte = $b
    }

    if ($freshPacket) {
        $freshPacket = $false
    }
}

function Parse-Packet {
    $parseSuccess = $true
    $rawValue = 0

    Clear-EegPower

    for ($i = 0; $i -lt $packetLength; $i++) {
        switch ($packetData[$i]) {
            0x2 {
                $signalQuality = $packetData[++$i]
            }
            0x4 {
                $focus = $packetData[++$i]
            }
            0x5 {
                $meditation = $packetData[++$i]
            }
            0x83 {
                $i++
                for ($j = 0; $j -lt $EEG_POWER_BANDS; $j++) {
                    $eegPower[$j] = [uint]($packetData[++$i] -shl 8) -bor $packetData[++$i]
                }
            }
            0x80 {
                $i++
                $rawValue = ($packetData[++$i] -shl 8) -bor $packetData[++$i]
            }
            default {
                $parseSuccess = $false
            }
        }
    }

    # Don't allow for outliers
    # if ($rawValue -le 200)
    On-BtDataParsed @{ rawValue = $rawValue }

    return $parseSuccess
}

function Clear-EegPower {
    for ($i = 0; $i -lt $EEG_POWER_BANDS; $i++) {
        $eegPower[$i] = 0
    }
}
function Start-BtManager {
    $bt.Open()
}

function Stop-BtManager {
    $bt.Close()
}

function Print-BtManagerValues {
    Write-Host "Focus: $($focus)"
    Write-Host "Meditation: $($meditation)"
    Write-Host "Signal: $($signalQuality)"
}

# PowerShell does not have a direct equivalent for C# finalizers (destructors).
# You might need to ensure that `Stop-BtManager` is called when you're done with the `$bt` object.