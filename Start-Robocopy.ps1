[CmdletBinding(DefaultParameterSetName = 'Standard', SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
	[Parameter(Mandatory, Position = 0)]
	[Alias('Src')]
	[ValidateNotNullOrEmpty()]
	[ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
	[string]$Source,

	[Parameter(Mandatory, Position = 1)]
	[Alias('Dst')]
	[ValidateNotNullOrEmpty()]
	[string]$Destination,

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

	[ValidateSet('D', 'A', 'T', 'E', 'X')]
	[string[]]$DirectoryCopyFlags = @('D', 'A'),

	[switch]$RestartableMode,

	[switch]$BackupMode,

	[switch]$RestartableBackupMode,

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

	[ValidateRange(1, 1000000)]
	[int]$MonitorSourceChanges,

	[ValidateRange(1, 1440)]
	[int]$MonitorRunMinutes,

	[switch]$LowFreeSpaceMode,

	[switch]$RunHoursOnly,

	[string[]]$AdditionalArgument,

	[switch]$PassThruResult
)

$moduleManifestPath = Join-Path -Path $PSScriptRoot -ChildPath 'Invoke-Robocopy\Invoke-Robocopy.psd1'
Import-Module -Name $moduleManifestPath -Force

Invoke-Robocopy @PSBoundParameters
