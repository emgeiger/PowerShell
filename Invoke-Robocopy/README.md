# Invoke-Robocopy

PowerShell wrapper for Robocopy with section-mapped parameters and advanced validation.

## Features

- **Section-organized parameters** matching Robocopy's command structure
- **Advanced validation** with `ValidateScript`, `ValidateRange`, `ValidateSet`
- **Parameter sets** to prevent conflicting operations
- **SupportsShouldProcess** for `-WhatIf` and `-Confirm` safety
- **Correct exit code interpretation** (0-7 informational, 8+ errors)
- **Raw Robocopy output** preserved by default
- **Optional structured results** with `-PassThruResult`

## Installation

### Option 1: Install to User Module Path
```powershell
.\Install-InvokeRobocopyModule.ps1
Import-Module Invoke-Robocopy
```

### Option 2: Import Directly
```powershell
Import-Module .\Invoke-Robocopy.psd1
```

### Option 3: Use Launcher Scripts
```powershell
# Compatibility launcher (in repo root)
.\Start-Robocopy.ps1 -Source C:\Data -Destination D:\Backup

# Dedicated launcher
.\Invoke-Robocopy\Invoke-Robocopy.Launcher.ps1 -Source C:\Data -Destination D:\Backup
```

### Option 4: Build Executable Launcher
```powershell
# Requires ps2exe module
Install-Module ps2exe -Scope CurrentUser
.\Build-InvokeRobocopyLauncher.ps1
```

## Viewing Documentation

### Get full help with all sections
```powershell
Get-Help Invoke-Robocopy -Full
```

### View examples only
```powershell
Get-Help Invoke-Robocopy -Examples
```

### View specific parameter help
```powershell
Get-Help Invoke-Robocopy -Parameter Mirror
Get-Help Invoke-Robocopy -Parameter Source
```

### Get command syntax
```powershell
Get-Command Invoke-Robocopy -Syntax
```

### View help in separate window
```powershell
Get-Help Invoke-Robocopy -ShowWindow
```

### Online help link
```powershell
Get-Help Invoke-Robocopy -Online  # Opens browser to Robocopy documentation
```

## Quick Examples

### Basic recursive copy
```powershell
Invoke-Robocopy -Source C:\Data -Destination D:\Backup -Subdirectories -IncludeEmptySubdirectories
```

### Mirror with safety check
```powershell
Invoke-Robocopy -Source C:\Data -Destination D:\Backup -Mirror -WhatIf
```

### Multi-threaded copy with retry
```powershell
Invoke-Robocopy -Source C:\Source -Destination D:\Dest -MultiThreaded -ThreadCount 16 -RetryCount 3
```

### Copy with file filtering
```powershell
Invoke-Robocopy -Source C:\Logs -Destination D:\Backup -File '*.log','*.txt' -ExcludeDirectory 'temp'
```

### Copy with logging
```powershell
Invoke-Robocopy -Source C:\Data -Destination D:\Backup -LogPath C:\Logs\copy.log -Tee -NoProgress
```

### Copy all file attributes (Security, Owner, Auditing)
```powershell
Invoke-Robocopy -Source C:\Data -Destination D:\Backup -CopyAll -Subdirectories
### Copy with security attributes
```powershell
Invoke-Robocopy -Source C:\Data -Destination D:\Backup -Sec -Subdirectories
```

```

## Parameter Sections

### Source/Destination
- `Source` - Source directory (must exist)
- `Destination` - Destination directory

### File Selection
- `File` - File patterns to copy
- `ExcludeFile` - File patterns to exclude
- `ExcludeDirectory` - Directory patterns to exclude
- `MaxFileAgeDays` - Exclude files older than N days
- `MinFileAgeDays` - Exclude files newer than N days

### Copy
- `Subdirectories` - Copy subdirectories
- `IncludeEmptySubdirectories` - Include empty subdirectories
- `Mirror` - Mirror source to destination (DESTRUCTIVE)
- `MoveFiles` - Move files after copying
- `MoveFilesAndDirectories` - Move files and directories
- `Sec` - Copy with security attributes (D,A,T,S) - cannot combine with CopyFlags or CopyAll
- `CopyAll` - Copy all file attributes (D,A,T,S,O,U) - cannot combine with CopyFlags
- `CopyFlags` - File attributes to copy (custom selection)
- `DirectoryCopyFlags` - Directory attributes to copy
- `RestartableMode` - Restartable network copy mode
- `BackupMode` - Copy in backup mode
- `RestartableBackupMode` - Combined restartable/backup mode

### Retry/Logging/Job
- `RetryCount` - Number of retries
- `RetryWaitSeconds` - Wait between retries
- `MultiThreaded` - Enable multi-threading
- `ThreadCount` - Number of threads
- `LogPath` - Log file path
- `AppendLog` - Append to log instead of overwrite
- `UnicodeLog` - Use Unicode encoding for log
- `Tee` - Output to both console and log
- `NoProgress` - Suppress percentage progress

### Monitoring/Performance
- `MonitorSourceChanges` - Monitor for N changes
- `MonitorRunMinutes` - Run after N minutes
- `LowFreeSpaceMode` - Low free space mode
- `RunHoursOnly` - Restrict to specific hours

### Advanced
- `AdditionalArgument` - Pass-through for unmapped Robocopy switches
- `PassThruResult` - Return structured result object

## Robocopy Exit Codes

The wrapper interprets exit codes correctly:
- **0-7**: Informational/success states (not errors)
  - 0 = No changes
  - 1 = Files copied
  - 2 = Extra files detected
  - 4 = Mismatches detected
  - (combinations add up: 3=1+2, 5=1+4, etc.)
- **8+**: Actual errors (raised as PowerShell errors)

## Files

- `Invoke-Robocopy.psm1` - Main module with public function
- `Invoke-Robocopy.psd1` - Module manifest
- `Private/Robocopy.Helpers.ps1` - Private helper functions
- `Invoke-Robocopy.Launcher.ps1` - Dedicated launcher script
- `Build-InvokeRobocopyLauncher.ps1` - Build EXE from launcher
- `Install-InvokeRobocopyModule.ps1` - Install to user module path

## Requirements

- PowerShell 5.1 or later
- Windows (Robocopy is built into Windows 7+)
- Optional: `ps2exe` module for building executable launcher
