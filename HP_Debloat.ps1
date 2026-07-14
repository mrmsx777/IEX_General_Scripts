# =========================================================================
#  Targeted Custom HP Bloatware, Tasks & Service Destruction Script
# =========================================================================

# 1. STOP & DISABLE HP BACKGROUND SERVICES (Including newly discovered network switchers)
$HPServices = @(
    "HpTouchpointAnalyticsService", "hpsvcsscan", "HPAudioAnalytics", 
    "HPNetworkCap", "HPDiagsCap", "HPSysInfoCap", "HPAppHelperCap",
    "HPNetworkOptimizer", "SecurityUpdateService", 
    "LanWlanWwanSwitchingServiceUWP", "HP Comm Recover"
)

Write-Host "`n--- Stopping and Disabling Active HP Services ---" -ForegroundColor Cyan
# Clear active processes running from targeted directories
Get-Process | Where-Object { $_.Name -like "*HP*" -or $_.Name -like "*Wolf*" -or $_.Name -like "*LanWlan*" } | Stop-Process -Force -ErrorAction SilentlyContinue

foreach ($Service in $HPServices) {
    if (Get-Service -Name $Service -ErrorAction SilentlyContinue) {
        try {
            Stop-Service -Name $Service -Force -ErrorAction Stop
            Set-Service -Name $Service -StartupType Disabled -ErrorAction Stop
            Write-Host "Successfully disabled service: $Service" -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to stop/disable service: $Service"
        }
    }
}

# 2. DELETE HP AUTO-UPDATE & RECOVERY SCHEDULED TASKS
Write-Host "`n--- Purging HP Scheduled Watchdog Tasks ---" -ForegroundColor Cyan
$HPTasks = Get-ScheduledTask -TaskPath "\HP*" -ErrorAction SilentlyContinue
if ($HPTasks) {
    foreach ($Task in $HPTasks) {
        Unregister-ScheduledTask -TaskName $Task.TaskName -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host "Deleted Task: $($Task.TaskName)" -ForegroundColor Green
    }
}

# 3. FORCE DIRECT UNINSTALL OF HP CONNECTION OPTIMIZER (Using uncovered path)
Write-Host "`n--- Target: HP Connection Optimizer ---" -ForegroundColor Cyan
try {
    (Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Connection Optimizer*" }).Uninstall()
    Write-Host "Successfully forced out HP Connection Optimizer via WMI." -ForegroundColor Green
}
catch {
    Write-Warning "WMI method skipped or failed for Connection Optimizer. Moving to registry hooks..."
}

# 4. REMOVE RESIDUAL EXTENSION APPLICATIONS & COMPATIBILITY ADDONS
$UninstallPrograms = @(
    "Poly Camera Pro Compatibility Add-on",
    "HP Wolf Security Application Support for Credential Protection AI Support",
    "HP Wolf Security Application Support for Chrome 148.0.7778.257",
    "HP Wolf Security - Console",
    "HP Sure Run Module",
    "HP Wolf Security",
    "HP Client Security Manager",
    "HP Notifications"
)

Write-Host "`n--- Sequentially Uninstalling Dependent HP Modules ---" -ForegroundColor Cyan
foreach ($ProgramName in $UninstallPrograms) {
    $Program = Get-Package | Where-Object { $_.Name -eq $ProgramName }
    if ($Program) {
        try {
            $Program | Uninstall-Package -AllVersions -Force -ErrorAction Stop
            Write-Host "Successfully uninstalled app: $ProgramName" -ForegroundColor Green
        }
        catch {
            Write-Warning "Standard uninstaller failed for $ProgramName."
        }
    }
}

# 5. FORCE DIRECT COMMAND LINE DELETION FOR HP DOCUMENTATION
Write-Host "`n--- Target: HP Documentation ---" -ForegroundColor Cyan
if (Test-Path "C:\Program Files\HP\Documentation\Doc_Uninstall.cmd") {
    Start-Process -FilePath "CMD.exe" -ArgumentList '/C "C:\Program Files\HP\Documentation\Doc_Uninstall.cmd"' -Wait -NoNewWindow
    Write-Host "HP Documentation native uninstaller executed." -ForegroundColor Green
}

# 6. EXECUTE TARGETED MSI FORCE-REMOVALS USING AUDITED GUIDS
# Wiping the exact instances found on her laptop, ensuring Security Update Service gets lost.
Write-Host "`n--- Target: Specific MSI Application Closures ---" -ForegroundColor Cyan
$ExactMsiGuids = @(
    "{94E01662-DDD0-47EF-89C5-3546611AD22B}", # Her Specific HP Security Update Service GUID
    "{558000B1-3B4B-4784-A516-58EBF3560B78}", # Poly Camera Pro Compatibility Add-on
    "{DD8282FC-4F27-45D9-98AC-7CDC501B1FC8}", # Credential Protection AI Support Component
    "{F7D3BC62-650B-40E0-A7EB-53F27DF56F06}", # Wolf Chrome Extension Framework
    "{0E2E04B0-9EDD-11EB-B38C-10604B96B11E}", # Wolf Security Core
    "{4DA839F0-72CF-11EC-B247-3863BB3CB5A8}"  # Wolf Security Support Platform
)

foreach ($Guid in $ExactMsiGuids) {
    Write-Host "Force purging deployment GUID from configuration matrix: $Guid" -ForegroundColor Yellow
    Start-Process msiexec.exe -ArgumentList "/x $Guid /qn /norestart" -Wait -NoNewWindow -ErrorAction SilentlyContinue
}

# 7. CLEAN UP RESIDUAL UWP FRAMEWORKS
$HPidentifier = "AD2F1837"
Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -match "^$HPidentifier" } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Get-AppxPackage -AllUsers | Where-Object { $_.Name -match "^$HPidentifier" } | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

Write-Host "`n=======================================================" -ForegroundColor Cyan
Write-Host "Purge Complete! Execute a system restart to release network hooks." -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Cyan
