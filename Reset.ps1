[System.IO.File]::ReadLines("") | foreach { # % {
	ping -a -n 2 -w 2000 $_ | Out-Null
    Test-Connection -Count 2 -TimeToLive 2 $_ | Out-Null

    if($?)
    {
		Start-Process "P:\psexec.exe" -ArgumentList "\\$_ -d -e -h -s cmd /c reg import C:\tools\dump.reg"	
	}
}