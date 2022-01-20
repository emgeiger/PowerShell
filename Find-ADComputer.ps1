﻿$IPs = @(
"ARCACW100154760",
"ARCACW100154779",
"ARCACW100154812",
"ARCACW100154821",
"ARCACW100154835",
"ARCACW100154836",
"ARCACW100154840",
"ARCACW100154846",
"ARCACW100154860",
"ARCACW100154892",
"ARCACW100154893",
"ARCACW100154938",
"ARCACW100154955",
"ARCACW100154956",
"ARCACW100154964",
"ARCACW100154996",
"ARCACW100155006",
"ARCACW100155007",
"ARCACW100155010",
"ARCACW100154768",
"ARCACW100154770",
"ARCACW100154771",
"ARCACW100154772",
"ARCACW100154787",
"ARCACW100154798",
"ARCACW100154800",
"ARCACW100154801",
"ARCACW100154808",
"ARCACW100154810",
"ARCACW100154819",
"ARCACW100154883",
"ARCACW100154884",
"ARCACW100154886",
"ARCACW100154887",
"ARCACW100154894",
"ARCACW100155003",
"ARCACW100155039",
"ARCACW100155044",
"ARCACW100154751",
"ARCACW100154763",
"ARCACW100154765",
"ARCACW100154767",
"ARCACW100154788",
"ARCACW100154789",
"ARCACW100154793",
"ARCACW100154794",
"ARCACW100154814",
"ARCACW100154826",
"ARCACW100154829",
"ARCACW100154830",
"ARCACW100154833",
"ARCACW100154889",
"ARCACW100154908",
"ARCACW100154917",
"ARCACW100154979",
"ARCACW100155046",
"ARCACW100155050",
"ARCACW100154764",
"ARCACW100154766",
"ARCACW100154773",
"ARCACW100154774",
"ARCACW100154796",
"ARCACW100154804",
"ARCACW100154806",
"ARCACW100154807",
"ARCACW100154818",
"ARCACW100154825",
"ARCACW100154885",
"ARCACW100154890",
"ARCACW100155043",
"ARCACW100154784",
"ARCACW100154815",
"ARCACW100154837",
"ARCACW100154841",
"ARCACW100154842",
"ARCACW100154845",
"ARCACW100154847",
"ARCACW100154852",
"ARCACW100154864",
"ARCACW100154891",
"ARCACW100154931",
"ARCACW100154934",
"ARCACW100154963",
"ARCACW100154994",
"ARCACW100154997",
"ARCACW100154998",
"ARCACW100155014",
"ARCACW100154849",
"ARCACW100154937",
"ARCACW100154802",
"ARCACW100155041",
"ARCACW100155040",
"ARCACW100154823",
"ARCACW100154769",
"ARCACW100154791",
"ARCACW100155013",
"ARCACW100154888",
"ARCACW100155008",
"ARCACW100154816",
"ARCACW100155049",
"ARCACW100155009",
"ARCACW100155004",
"ARCACW100131991",
"ARCACW100131994",
"ARCACW100131984",
"ARCACW100131982",
"ARCACW100131997",
"ARCACW100132000",
"ARCACW100131989",
"ARCACW100131996",
"ARCACW100154862",
"ARCACW100139869",
"ARCACW100132053",
"ARCACW100139849",
"ARCACW100136569",
"ARCACW100128931",
"ARCACW100130233"
)

function Build-Table
{
[cmdletBinding()]
Param([string]$Label, [PSCustomObject[]]$Expression)

}

$path = $PSScriptRoot
$Script:sucuess = New-Object System.Collections.ArrayList
#[System.IO.File]::ReadLines("$path\IPs.txt") | Select-String -Pattern "[0-9]+.[0-9]+.[0-9]+.[0-9]+" | Select-Object -ExpandProperty Matches
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
