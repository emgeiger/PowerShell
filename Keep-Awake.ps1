# Keep-Awake.ps1
# This script moves the mouse cursor by 1 pixel in alternating directions
# to prevent screen timeout and computer locking

Add-Type -AssemblyName System.Windows.Forms

# Function to move mouse cursor by a small amount
function Move-MouseCursor {
    param (
        [int]$xOffset,
        [int]$yOffset
    )
    
    $currentPosition = [System.Windows.Forms.Cursor]::Position
    $newX = $currentPosition.X + $xOffset
    $newY = $currentPosition.Y + $yOffset
    
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($newX, $newY)
}

Write-Host "Keep-Awake script is now running. Press Ctrl+C to stop."
Write-Host "Mouse will move by 1 pixel every 60 seconds to prevent screen locking."

try {
    $moveRight = $true
    $moveDown = $true
    
    while ($true) {
        # Move X direction
        if ($moveRight) {
            Move-MouseCursor -xOffset 1 -yOffset 0
            $moveRight = $false
        } else {
            Move-MouseCursor -xOffset -1 -yOffset 0
            $moveRight = $true
        }
        
        # Wait 30 seconds
        Start-Sleep -Seconds 30
        
        # Move Y direction
        if ($moveDown) {
            Move-MouseCursor -xOffset 0 -yOffset 1
            $moveDown = $false
        } else {
            Move-MouseCursor -xOffset 0 -yOffset -1
            $moveDown = $true
        }
        
        # Wait 30 seconds (60 seconds total between X movements)
        Start-Sleep -Seconds 30
    }
} catch {
    Write-Host "Script was interrupted. Exiting..."
} finally {
    Write-Host "Keep-Awake script has stopped."
}