function Test-RobocopyCommand {
    [CmdletBinding()]
    param()

    if (-not (Get-Command -Name robocopy.exe -ErrorAction SilentlyContinue)) {
        throw 'robocopy.exe was not found in PATH.'
    }
}

function New-RobocopyArgumentList {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$BoundParameters,

        [Parameter(Mandatory)]
        [string]$Source,

        [Parameter(Mandatory)]
        [string]$Destination
    )

    $argumentList = [System.Collections.Generic.List[string]]::new()
    $argumentList.Add($Source)
    $argumentList.Add($Destination)

    if ($BoundParameters.ContainsKey('File') -and $BoundParameters.File.Count -gt 0) {
        foreach ($item in $BoundParameters.File) {
            $argumentList.Add($item)
        }
    }
    else {
        $argumentList.Add('*.*')
    }

    if ($BoundParameters.ContainsKey('Subdirectories')) { $argumentList.Add('/S') }
    if ($BoundParameters.ContainsKey('IncludeEmptySubdirectories')) { $argumentList.Add('/E') }
    if ($BoundParameters.ContainsKey('Mirror')) { $argumentList.Add('/MIR') }
    if ($BoundParameters.ContainsKey('MoveFiles')) { $argumentList.Add('/MOV') }
    if ($BoundParameters.ContainsKey('MoveFilesAndDirectories')) { $argumentList.Add('/MOVE') }

    if ($BoundParameters.ContainsKey('ExcludeFile')) {
        $argumentList.Add('/XF')
        foreach ($item in $BoundParameters.ExcludeFile) { $argumentList.Add($item) }
    }

    if ($BoundParameters.ContainsKey('ExcludeDirectory')) {
        $argumentList.Add('/XD')
        foreach ($item in $BoundParameters.ExcludeDirectory) { $argumentList.Add($item) }
    }

    if ($BoundParameters.ContainsKey('MaxFileAgeDays')) { $argumentList.Add("/MAXAGE:$($BoundParameters.MaxFileAgeDays)") }
    if ($BoundParameters.ContainsKey('MinFileAgeDays')) { $argumentList.Add("/MINAGE:$($BoundParameters.MinFileAgeDays)") }

    if ($BoundParameters.ContainsKey('CopyAll')) {
        $argumentList.Add('/COPY:DATSOU')
    }
    elseif ($BoundParameters.ContainsKey('CopyFlags')) {
        $argumentList.Add("/COPY:$([string]::Join('', $BoundParameters.CopyFlags))")
    }

    if ($BoundParameters.ContainsKey('DirectoryCopyFlags')) {
        $argumentList.Add("/DCOPY:$([string]::Join('', $BoundParameters.DirectoryCopyFlags))")
    }

    if ($BoundParameters.ContainsKey('RestartableMode')) { $argumentList.Add('/Z') }
    if ($BoundParameters.ContainsKey('BackupMode')) { $argumentList.Add('/B') }
    if ($BoundParameters.ContainsKey('RestartableBackupMode')) { $argumentList.Add('/ZB') }

    $retryCount = if ($BoundParameters.ContainsKey('RetryCount')) { $BoundParameters.RetryCount } else { 1 }
    $retryWaitSeconds = if ($BoundParameters.ContainsKey('RetryWaitSeconds')) { $BoundParameters.RetryWaitSeconds } else { 5 }
    $argumentList.Add("/R:$retryCount")
    $argumentList.Add("/W:$retryWaitSeconds")

    if ($BoundParameters.ContainsKey('MultiThreaded')) {
        $threadCount = if ($BoundParameters.ContainsKey('ThreadCount')) { $BoundParameters.ThreadCount } else { 8 }
        $argumentList.Add("/MT:$threadCount")
    }

    if ($BoundParameters.ContainsKey('LogPath')) {
        $logSwitch = if ($BoundParameters.ContainsKey('AppendLog')) { '/LOG+' } else { '/LOG' }
        if ($BoundParameters.ContainsKey('UnicodeLog')) {
            $logSwitch = if ($BoundParameters.ContainsKey('AppendLog')) { '/UNILOG+' } else { '/UNILOG' }
        }
        $argumentList.Add("${logSwitch}:$($BoundParameters.LogPath)")
    }

    if ($BoundParameters.ContainsKey('Tee')) { $argumentList.Add('/TEE') }
    if ($BoundParameters.ContainsKey('NoProgress')) { $argumentList.Add('/NP') }

    if ($BoundParameters.ContainsKey('MonitorSourceChanges')) { $argumentList.Add("/MON:$($BoundParameters.MonitorSourceChanges)") }
    if ($BoundParameters.ContainsKey('MonitorRunMinutes')) { $argumentList.Add("/MOT:$($BoundParameters.MonitorRunMinutes)") }
    if ($BoundParameters.ContainsKey('LowFreeSpaceMode')) { $argumentList.Add('/LFSM') }
    if ($BoundParameters.ContainsKey('RunHoursOnly')) { $argumentList.Add('/RH:0000-2359') }

    if ($BoundParameters.ContainsKey('AdditionalArgument')) {
        foreach ($item in $BoundParameters.AdditionalArgument) {
            $argumentList.Add($item)
        }
    }

    return $argumentList.ToArray()
}

function Get-RobocopyResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [int]$ExitCode,

        [Parameter(Mandatory)]
        [string]$Source,

        [Parameter(Mandatory)]
        [string]$Destination
    )

    $isError = $ExitCode -ge 8
    $hasCopiedFiles = [bool]($ExitCode -band 1)
    $hasExtras = [bool]($ExitCode -band 2)
    $hasMismatches = [bool]($ExitCode -band 4)

    $messages = [System.Collections.Generic.List[string]]::new()
    if ($hasCopiedFiles) { $messages.Add('files copied') }
    if ($hasExtras) { $messages.Add('extra items detected') }
    if ($hasMismatches) { $messages.Add('mismatched items detected') }
    if ($messages.Count -eq 0 -and -not $isError) { $messages.Add('no changes') }
    if ($isError) { $messages.Add('robocopy reported a failure (exit code >= 8)') }

    [pscustomobject]@{
        Source = $Source
        Destination = $Destination
        ExitCode = $ExitCode
        IsError = $isError
        Message = [string]::Join('; ', $messages)
        HasCopiedFiles = $hasCopiedFiles
        HasExtras = $hasExtras
        HasMismatches = $hasMismatches
    }
}
