# PowerShell AIO Script: Automates System Repair, Updates, Disables Issues, and Error Logging

# Create Log Directory (if it doesn't exist)
$logPath = "C:\SystemLogs"
if (!(Test-Path -Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath
}

# Pre-checks: Disable Potential Problem Areas
function PreChecks {
    Write-Host "Running pre-checks to disable problematic modules/services..."
    try {
        # Example: Disable PSWindowsUpdate-specific settings or services
        Stop-Service -Name wuauserv -Force
        Write-Host "Windows Update service disabled temporarily."
        # Add more pre-checks here as needed for known errors/issues
    } catch {
        $errorMessage = $_.Exception.Message
        Write-Host "Error during pre-checks: $errorMessage" -ForegroundColor Red
        Out-File -FilePath "$logPath\ErrorLog.txt" -Append -InputObject "Error Code: P001 | $errorMessage"
    }
}

# Repair System Function
function Repair-System {
    Write-Host "Starting system repair..."
    try {
        # Run System File Checker
        sfc /scannow

        # Repair Windows Image
        DISM /Online /Cleanup-Image /RestoreHealth

        Write-Host "System repair completed successfully."
    } catch {
        $errorMessage = $_.Exception.Message
        Write-Host "Error during repair: $errorMessage" -ForegroundColor Red
        Out-File -FilePath "$logPath\ErrorLog.txt" -Append -InputObject "Error Code: R001 | $errorMessage"
    }
}

# Update System Function
function Update-System {
    Write-Host "Starting system updates..."
    try {
        # Install PSWindowsUpdate Module
        Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
        Import-Module PSWindowsUpdate

        # Install Updates
        Get-WindowsUpdate -Install -AcceptAll

        Write-Host "System updates installed successfully."
    } catch {
        $errorMessage = $_.Exception.Message
        Write-Host "Error during updates: $errorMessage" -ForegroundColor Red
        Out-File -FilePath "$logPath\ErrorLog.txt" -Append -InputObject "Error Code: U001 | $errorMessage"
    }
}

# Main Script Execution
Write-Host "Automated tasks are starting..."
PreChecks
Repair-System
Update-System
Write-Host "All tasks completed! Check logs at $logPath."

# Keep the PowerShell session open
Write-Host "Press any key to exit, or leave the session open for variable review."
Pause

# Error Codes:
# P001 - Pre-checks Failure
# R001 - System Repair Failure
# U001 - Update Failure
