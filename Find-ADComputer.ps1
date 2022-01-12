$path = $PSScriptRoot
[System.IO.File]::ReadLines("$path\IPs.txt") | Select-String -Pattern "[0-9]+.[0-9]+.[0-9]+.[0-9]+" | Select-Object -ExpandProperty Matches | foreach {
    $IP = $_
    try
    {
        # $IPStatus = New-Object System.Net.NetworkInformation.IPStatus
        $ping = New-Object System.Net.NetworkInformation.Ping
        $response = $ping.Send($_, 200)
        $pingResponse = $ping.Send($_, 2000)
        # ping -a -n 2 -w 2000 $_ # | Out-Null
        # Test-Connection -Count 2 -TimeToLive 2 $_ # | Out-Null

        if($response.Status -eq [System.Net.NetworkInformation.IPStatus]::Success)
        {
        }
        elseif($response.Status -eq [System.Net.NetworkInformation.IPStatus]::TimedOut)
        {
            Write-Output "$_ In AD, but Offline"
            # Get-Service -ComputerName $_ -Name seclogon
            # Get-WmiObject -Credential $cred -ComputerName $_ -Namespace "root\cimv2" -Class "Win32_ComputerSystem" -Property Model
        }
    }
    catch [System.Net.NetworkInformation.PingException]
    {
        Write-Output "$IP Not in AD."
    }
 }
