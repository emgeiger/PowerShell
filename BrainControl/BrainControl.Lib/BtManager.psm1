using namespace System
using namespace System.Collections.Generic
using namespace System.IO.Ports

class BtManager {
    static [int]$MAX_PACKET_LENGTH = 32
    static [int]$EEG_POWER_BANDS = 8

    [SerialPort]$bt
    [byte]$lastByte = 0
    [bool]$inPacket = $false
    [bool]$freshPacket = $false
    [int]$packetIndex = 0
    [int]$checksumAccumulator = 0
    [int]$packetLength = 0
    [int]$checkSum = 0
    [uint[]]$eegPower = [uint[]]::new([BtManager]::EEG_POWER_BANDS)
    [byte[]]$packetData = [byte[]]::new([BtManager]::MAX_PACKET_LENGTH)
    [int]$signalQuality = 200
    [int]$focus = 0
    [int]$meditation = 0
    [Collections.Generic.List[scriptblock]]$btDataParsedHandlers = [Collections.Generic.List[scriptblock]]::new()

    BtManager([string]$comPort) {
        $this.bt = [SerialPort]::new($comPort, 9600, [Parity]::None, 8, [StopBits]::One)
        $this.bt.add_DataReceived({
            param($sender, $e)
            $this.BtDataReceived($sender, $e)
        })
        $this.bt.Open()
    }

    [void]add_BtDataParsed([scriptblock]$handler) {
        if ($null -ne $handler) {
            $this.btDataParsedHandlers.Add($handler)
        }
    }

    hidden [void]OnBtDataParsed([int]$rawValue) {
        $args = [pscustomobject]@{ rawValue = $rawValue }
        foreach ($handler in $this.btDataParsedHandlers) {
            & $handler $this $args
        }
    }

    hidden [void]BtDataReceived([object]$serialSender, [object]$e) {
        $port = [SerialPort]$serialSender

        $len = $port.BytesToRead
        if ($len -le 0) {
            return
        }

        $buffer = [byte[]]::new($len)
        [void]$port.Read($buffer, 0, $len)

        foreach ($b in $buffer) {
            if ($this.inPacket) {
                if ($this.packetIndex -eq 0) {
                    $this.packetLength = $b
                    if ($this.packetLength -gt [BtManager]::MAX_PACKET_LENGTH) {
                        $this.inPacket = $false
                    }
                }
                elseif ($this.packetIndex -le $this.packetLength) {
                    $this.packetData[$this.packetIndex - 1] = $b
                    $this.checksumAccumulator += $b
                }
                elseif ($this.packetIndex -gt $this.packetLength) {
                    $this.checkSum = $b
                    $this.checksumAccumulator = 255 - $this.checksumAccumulator

                    if ($this.checkSum -eq $this.checksumAccumulator) {
                        if ($this.ParsePacket()) {
                            $this.freshPacket = $true
                        }
                    }
                    $this.inPacket = $false
                }
                $this.packetIndex++
            }

            if ($b -eq 170 -and $this.lastByte -eq 170 -and -not $this.inPacket) {
                $this.inPacket = $true
                $this.packetIndex = 0
                $this.checksumAccumulator = 0
            }

            $this.lastByte = $b
        }

        if ($this.freshPacket) {
            $this.freshPacket = $false
        }
    }

    hidden [bool]ParsePacket() {
        $parseSuccess = $true
        $rawValue = 0

        $this.ClearEegPower()

        for ($i = 0; $i -lt $this.packetLength; $i++) {
            switch ($this.packetData[$i]) {
                0x2 {
                    $this.signalQuality = $this.packetData[++$i]
                }
                0x4 {
                    $this.focus = $this.packetData[++$i]
                }
                0x5 {
                    $this.meditation = $this.packetData[++$i]
                }
                0x83 {
                    $i++
                    for ($j = 0; $j -lt [BtManager]::EEG_POWER_BANDS; $j++) {
                        $this.eegPower[$j] = [uint](($this.packetData[++$i] -shl 8) -bor $this.packetData[++$i])
                    }
                }
                0x80 {
                    $i++
                    $rawValue = (($this.packetData[++$i] -shl 8) -bor $this.packetData[++$i])
                }
                default {
                    $parseSuccess = $false
                }
            }
        }

        $this.OnBtDataParsed($rawValue)
        return $parseSuccess
    }

    hidden [void]ClearEegPower() {
        for ($i = 0; $i -lt [BtManager]::EEG_POWER_BANDS; $i++) {
            $this.eegPower[$i] = 0
        }
    }

    [void]Stop() {
        if ($null -ne $this.bt -and $this.bt.IsOpen) {
            $this.bt.Close()
        }
    }
}

function New-BtManager {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComPort
    )

    return [BtManager]::new($ComPort)
}

Export-ModuleMember -Function New-BtManager