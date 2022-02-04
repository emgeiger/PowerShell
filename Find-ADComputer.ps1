#############################################################################################################################
# SYNOPSIS
# @Author Eric Geiger
# @Name Find-ADComputer
# @Description Uses .NET to ping a computer, and determine the status, to let you know whether it is in AD, or just offline.
#############################################################################################################################

$IPs = @(

)

function Build-Table
{
[cmdletBinding()]
Param([string]$Label, [PSCustomObject[]]$Expression)

}

$path = $PSScriptRoot
$Script:sucuess = New-Object System.Collections.ArrayList
#[System.IO.File]::ReadLines("$path\IPs.txt") | Select-String -Pattern "[0-9]+.[0-9]+.[0-9]+.[0-9]+" | Select-Object -ExpandProperty Matches

# [System.IO.File]::ReadLines("$path\IPs.txt") | Select-String -Pattern "[0-9]+.[0-9]+.[0-9]+.[0-9]+" | Select-Object -ExpandProperty Matches

$IPs | foreach {
    $IP = $_
    try
    {
        # $IPStatus = New-Object System.Net.NetworkInformation.IPStatus
        $ping = New-Object System.Net.NetworkInformation.Ping
        $response = $ping.Send($_, 200)
        $pingResponse = $ping.Send($_, 2000)

        if($response.Status -eq [System.Net.NetworkInformation.IPStatus]::Success)
        {
            $Script:sucuess.Add($IP) | Out-Null
            # ping -a -n 2 -w 2000 $_ # | Out-Null
            Test-Connection -Count 2 -TimeToLive 2 $_ # | Out-Null
        }
        elseif($response.Status -eq [System.Net.NetworkInformation.IPStatus]::TimedOut)
        {
            Write-Output "$_ In AD, but Offline" | Out-File -Append "failed.txt"
            # Get-Service -ComputerName $_ -Name seclogon
            # Get-WmiObject -Credential $cred -ComputerName $_ -Namespace "root\cimv2" -Class "Win32_ComputerSystem" -Property Model
        }
    }
    catch [System.Net.NetworkInformation.PingException]
    {
        Write-Output "$IP Not in AD." | Out-File -Append "failed.txt"
    }
 }
 $Script:sucuess | Out-GridView
