Set-StrictMode -Version Latest

. "$PSScriptRoot\Private\Robocopy.Helpers.ps1"

function Invoke-Robocopy {
    <#
    .SYNOPSIS
        PowerShell wrapper for Robocopy with section-mapped parameters and advanced validation.

    .DESCRIPTION
        Invoke-Robocopy provides a PowerShell-native interface to robocopy.exe with parameters
        organized into logical sections matching Robocopy's command structure:
        
        - Source/Destination: Path specification and validation
        - File Selection: Include/exclude patterns and age filters
        - Copy: Recursion, mirroring, move operations, and metadata flags
        - Retry/Logging/Job: Resilience, output control, and multithreading
        - Monitoring/Performance: Change monitoring and resource management
        
        The wrapper handles Robocopy's exit code semantics correctly (0-7 are informational/success,
        8+ indicates errors), provides path normalization, and supports -WhatIf/-Confirm for safety.

    .PARAMETER Source
        Source directory path (must exist). Validates that the path exists before execution.
        Alias: Src

    .PARAMETER Destination
        Destination directory path. Will be created by Robocopy if it doesn't exist.
        Alias: Dst

    .PARAMETER File
        File specification(s) to copy. Supports wildcards. Default is '*.*' (all files).
        Can specify multiple patterns like '*.txt', '*.log'.
        Alias: FileSpec

    .PARAMETER ExcludeFile
        File name(s) or pattern(s) to exclude from the copy operation. Maps to /XF.
        Alias: XF

    .PARAMETER ExcludeDirectory
        Directory name(s) or pattern(s) to exclude from the copy operation. Maps to /XD.
        Alias: XD

    .PARAMETER MaxFileAgeDays
        Exclude files older than N days. Maps to /MAXAGE:N.

    .PARAMETER MinFileAgeDays
        Exclude files newer than N days (minimum age). Maps to /MINAGE:N.

    .PARAMETER Subdirectories
        Copy subdirectories (excludes empty ones unless combined with -IncludeEmptySubdirectories).
        Maps to /S.
        Alias: S

    .PARAMETER IncludeEmptySubdirectories
        Copy subdirectories including empty ones. Maps to /E.
        Alias: E

    .PARAMETER Mirror
        Mirror source to destination (copies and deletes destination files not in source).
        DESTRUCTIVE: Use with caution. Maps to /MIR. Requires parameter set 'Mirror'.
        Alias: MIR

    .PARAMETER MoveFiles
        Move files (delete from source after copying). Maps to /MOV.
        Alias: MOV

    .PARAMETER MoveFilesAndDirectories
        Move files and directories (delete from source after copying). Maps to /MOVE.
        Alias: MOVE

    .PARAMETER CopyAll
        Copy all file attributes (equivalent to -CopyFlags D,A,T,S,O,U).
        Automatically sets D (Data), A (Attributes), T (Timestamps), S (Security/NTFS ACLs),
        O (Owner info), U (aUditing info). Cannot be combined with -CopyFlags.
        Maps to /COPY:DATSOU.

    .PARAMETER CopyFlags
        File attributes to copy. Default: D,A,T (Data, Attributes, Timestamps).
        Valid values: D (Data), A (Attributes), T (Timestamps), S (Security/NTFS ACLs),
        O (Owner info), U (aUditing info), X (skip alt data streams).
        Maps to /COPY:flags. Cannot be combined with -CopyAll.

    .PARAMETER DirectoryCopyFlags
        Directory attributes to copy. Default: D,A (Data, Attributes).
        Valid values: D (Data), A (Attributes), T (Timestamps), E (EAs), X (skip alt data streams).
        Maps to /DCOPY:flags.

    .PARAMETER RestartableMode
        Copy in restartable mode (survive network interruptions). Maps to /Z.

    .PARAMETER BackupMode
        Copy in backup mode (bypass file security). Maps to /B.

    .PARAMETER RestartableBackupMode
        Use restartable mode; fall back to backup mode if access denied. Maps to /ZB.

    .PARAMETER RetryCount
        Number of retries on failed copies. Default: 1. Maps to /R:N.

    .PARAMETER RetryWaitSeconds
        Wait time between retries in seconds. Default: 5. Maps to /W:N.

    .PARAMETER MultiThreaded
        Enable multi-threaded copying. Requires -ThreadCount parameter. Maps to /MT:N.

    .PARAMETER ThreadCount
        Number of threads for multi-threaded copying (1-128). Default: 8.
        Only valid with -MultiThreaded switch.

    .PARAMETER LogPath
        Path to log file. Maps to /LOG: or /LOG+: (with -AppendLog).

    .PARAMETER AppendLog
        Append to existing log file instead of overwriting. Requires -LogPath. Maps to /LOG+.

    .PARAMETER UnicodeLog
        Write log in Unicode format. Requires -LogPath. Maps to /UNILOG or /UNILOG+.

    .PARAMETER Tee
        Output to console and log file. Requires -LogPath. Maps to /TEE.

    .PARAMETER NoProgress
        Suppress percentage progress display. Maps to /NP.

    .PARAMETER MonitorSourceChanges
        Monitor source and run when more than N changes detected. Must be used with -MonitorRunMinutes.
        Maps to /MON:N.

    .PARAMETER MonitorRunMinutes
        Monitor source and run after N minutes if changes detected. Must be used with -MonitorSourceChanges.
        Maps to /MOT:N.

    .PARAMETER LowFreeSpaceMode
        Operate in low free space mode (pause/resume copying). Maps to /LFSM.

    .PARAMETER RunHoursOnly
        Restrict run to specific hours. Maps to /RH:hhmm-hhmm.

    .PARAMETER AdditionalArgument
        Pass-through array of additional Robocopy arguments not explicitly mapped by this wrapper.

    .PARAMETER PassThruResult
        Return a structured result object with exit code interpretation instead of just raw output.

    .EXAMPLE
        Invoke-Robocopy -Source C:\Data -Destination D:\Backup

        Basic copy of all files from C:\Data to D:\Backup (non-recursive).

    .EXAMPLE
        Invoke-Robocopy -Source C:\Data -Destination D:\Backup -Subdirectories -IncludeEmptySubdirectories

        Recursive copy including empty subdirectories. Equivalent to robocopy /S /E.

    .EXAMPLE
        Invoke-Robocopy -Source C:\Data -Destination D:\Backup -File '*.txt','*.log' -ExcludeDirectory 'temp','cache'

        Copy only .txt and .log files, excluding 'temp' and 'cache' directories.

    .EXAMPLE
        Invoke-Robocopy -Source C:\Data -Destination D:\Backup -Mirror -WhatIf

        Preview a mirror operation without executing (safe dry-run for destructive operations).

    .EXAMPLE
        Invoke-Robocopy -Source C:\Data -Destination D:\Backup -Mirror -Confirm

        Mirror operation with interactive confirmation prompt before execution.

    .EXAMPLE
        Invoke-Robocopy -Source C:\Source -Destination D:\Dest -MultiThreaded -ThreadCount 16 -RetryCount 3 -RetryWaitSeconds 10

        Multi-threaded copy with 16 threads, 3 retries, and 10-second wait between retries.

    .EXAMPLE
        Invoke-Robocopy -Source C:\Logs -Destination D:\LogBackup -LogPath C:\RobocopyLogs\backup.log -Tee -NoProgress

        Copy with logging to file and console, without percentage progress display.

    .EXAMPLE
        Invoke-Robocopy -Source C:\Data -Destination \\Server\Share\Data -BackupMode -CopyFlags D,A,T,S,O -DirectoryCopyFlags D,A,T

        Copy to network share in backup mode, preserving all NTFS attributes and timestamps.

    .EXAMPLE
        Invoke-Robocopy -Source C:\Data -Destination D:\Backup -CopyAll -Subdirectories

        Recursive copy with all file attributes (Data, Attributes, Timestamps, Security, Owner, Auditing).

    .EXAMPLE
        Invoke-Robocopy -Source C:\Data -Destination D:\Backup -MaxFileAgeDays 30 -PassThruResult

        Copy only files modified within the last 30 days and return structured result object.

    .EXAMPLE
        Invoke-Robocopy -Source C:\Source -Destination D:\Dest -MonitorSourceChanges 10 -MonitorRunMinutes 5

        Monitor source for changes; run copy operation when 10+ changes detected or after 5 minutes.

    .NOTES
        Robocopy Exit Codes (interpreted automatically):
        0 = No files copied, no failures
        1 = Files copied successfully
        2 = Extra files/directories detected
        3 = Files copied + extras detected
        4 = Mismatched files/directories
        5 = Files copied + mismatches
        6 = Extras + mismatches
        7 = Files copied + extras + mismatches
        8+ = Errors occurred (written as PowerShell error)

        The wrapper treats exit codes 0-7 as non-error states (informational) and only
        raises errors for exit codes 8 and above.

    .LINK
        https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy
    #>
    [CmdletBinding(DefaultParameterSetName = 'Standard', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        # Source and Destination
        [Parameter(Mandatory, Position = 0)]
        [Alias('Src')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [string]$Source,

        [Parameter(Mandatory, Position = 1)]
        [Alias('Dst')]
        [ValidateNotNullOrEmpty()]
        [string]$Destination,

        # File Selection
        [Parameter(Position = 2)]
        [Alias('FileSpec')]
        [ValidateNotNullOrEmpty()]
        [string[]]$File = '*.*',

        [Alias('XF')]
        [string[]]$ExcludeFile,

        [Alias('XD')]
        [string[]]$ExcludeDirectory,

        [ValidateRange(0, 365000)]
        [int]$MaxFileAgeDays,

        [ValidateRange(0, 365000)]
        [int]$MinFileAgeDays,

        # Copy
        [Alias('S')]
        [switch]$Subdirectories,

        [Alias('E')]
        [switch]$IncludeEmptySubdirectories,

        [Parameter(ParameterSetName = 'Mirror', Mandatory)]
        [Alias('MIR')]
        [switch]$Mirror,

        [Alias('MOV')]
        [switch]$MoveFiles,

        [Alias('MOVE')]
        [switch]$MoveFilesAndDirectories,

        [switch]$CopyAll,

        [ValidateSet('D', 'A', 'T', 'S', 'O', 'U', 'X')]
        [string[]]$CopyFlags = @('D', 'A', 'T'),

        [ValidateSet('D', 'A', 'T', 'E', 'X')]
        [string[]]$DirectoryCopyFlags = @('D', 'A'),

        [switch]$RestartableMode,

        [switch]$BackupMode,

        [switch]$RestartableBackupMode,

        # Retry, Logging and Job
        [ValidateRange(0, 1000000)]
        [int]$RetryCount = 1,

        [ValidateRange(0, 3600)]
        [int]$RetryWaitSeconds = 5,

        [switch]$MultiThreaded,

        [ValidateRange(1, 128)]
        [int]$ThreadCount = 8,

        [string]$LogPath,

        [switch]$AppendLog,

        [switch]$UnicodeLog,

        [switch]$Tee,

        [switch]$NoProgress,

        # Monitoring and Performance
        [ValidateRange(1, 1000000)]
        [int]$MonitorSourceChanges,

        [ValidateRange(1, 1440)]
        [int]$MonitorRunMinutes,

        [switch]$LowFreeSpaceMode,

        [switch]$RunHoursOnly,

        # Advanced
        [string[]]$AdditionalArgument,

        [switch]$PassThruResult
    )

    begin {
        Test-RobocopyCommand

        if ($Mirror -and ($MoveFiles -or $MoveFilesAndDirectories)) {
            throw "-Mirror cannot be combined with -MoveFiles or -MoveFilesAndDirectories."
        }

        if ($BackupMode -and $RestartableMode) {
            throw "-BackupMode cannot be combined with -RestartableMode. Use -RestartableBackupMode for /ZB behavior."
        }

        if (-not $MultiThreaded -and $PSBoundParameters.ContainsKey('ThreadCount')) {
            throw "-ThreadCount requires -MultiThreaded."
        }

        if ($PSBoundParameters.ContainsKey('LogPath') -and [string]::IsNullOrWhiteSpace($LogPath)) {
            throw "-LogPath cannot be empty when supplied."
        }

        if ($PSBoundParameters.ContainsKey('AppendLog') -and -not $PSBoundParameters.ContainsKey('LogPath')) {
            throw "-AppendLog requires -LogPath."
        }

        if ($PSBoundParameters.ContainsKey('UnicodeLog') -and -not $PSBoundParameters.ContainsKey('LogPath')) {
            throw "-UnicodeLog requires -LogPath."
        }

        if ($PSBoundParameters.ContainsKey('MonitorSourceChanges') -xor $PSBoundParameters.ContainsKey('MonitorRunMinutes')) {
            throw "-MonitorSourceChanges and -MonitorRunMinutes must be used together."
        }

        if ($CopyAll -and $PSBoundParameters.ContainsKey('CopyFlags')) {
            throw "-CopyAll cannot be combined with -CopyFlags. Use one or the other."
        }

        $normalizedSource = (Resolve-Path -LiteralPath $Source).Path.TrimEnd('\\')
        $normalizedDestination = [System.IO.Path]::GetFullPath($Destination).TrimEnd('\\')

        $arguments = New-RobocopyArgumentList -BoundParameters $PSBoundParameters -Source $normalizedSource -Destination $normalizedDestination

        $activity = "Robocopy from '$normalizedSource' to '$normalizedDestination'"
        $isDestructive = $Mirror -or $MoveFiles -or $MoveFilesAndDirectories
        $action = if ($isDestructive) { 'Copy and delete destination/source items as configured' } else { 'Copy files' }

        if (-not $PSCmdlet.ShouldProcess($activity, $action)) {
            return
        }

        Write-Verbose "Running: robocopy.exe $($arguments -join ' ')"
        $output = & robocopy.exe @arguments
        $exitCode = $LASTEXITCODE

        foreach ($line in $output) {
            $line
        }

        $result = Get-RobocopyResult -ExitCode $exitCode -Source $normalizedSource -Destination $normalizedDestination

        if ($result.IsError) {
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                ([System.InvalidOperationException]::new($result.Message)),
                'RobocopyFailed',
                [System.Management.Automation.ErrorCategory]::InvalidResult,
                $normalizedDestination
            )
            $PSCmdlet.WriteError($errorRecord)
        }

        if ($PassThruResult) {
            $result
        }
    }
}

Export-ModuleMember -Function Invoke-Robocopy
