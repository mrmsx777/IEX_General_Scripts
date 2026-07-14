# =========================================================================
#  Unified HP Bloatware, Analytics & Services Removal Script
# =========================================================================

# 1. STOP & DISABLE HP BACKGROUND SERVICES & ANALYTICS (Your list + extras)
$HPServices = @(
    "HpTouchpointAnalyticsService", 
    "hpsvcsscan", 
    "HPAudioAnalytics", 
    "HPNetworkCap", 
    "HPDiagsCap", 
    "HPSysInfoCap", 
    "HPAppHelperCap",
    "HPNetworkOptimizer"
)

Write-Host "`n--- Processing HP Services and Analytics ---" -ForegroundColor Cyan
foreach ($Service in $HPServices) {
    if (Get-Service -Name $Service -ErrorAction SilentlyContinue) {
        try {
            Stop-Service -Name $Service -Force -ErrorAction Stop
            Set-Service -Name $Service -StartupType Disabled -ErrorAction Stop
            Write-Host "Successfully stopped and disabled service: $Service" -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to fully disable service: $Service"
        }
    }
    else {
        Write-Host "Service not present (already removed or skipped): $Service" -ForegroundColor DarkGray
    }
}

# 2. DEFINE PACKAGES AND PROGRAMS TO UNINSTALL
$UninstallPackages = @(
    "AD2F1837.HPJumpStarts", "AD2F1837.HPPCHardwareDiagnosticsWindows",
    "AD2F1837.HPPowerManager", "AD2F1837.HPPrivacySettings",
    "AD2F1837.HPSupportAssistant", "AD2F1837.HPSureShieldAI",
    "AD2F1837.HPSystemInformation", "AD2F1837.HPQuickDrop",
    "AD2F1837.HPWorkWell", "AD2F1837.myHP",
    "AD2F1837.HPDesktopSupportUtilities", "AD2F1837.HPQuickTouch",
    "AD2F1837.HPEasyClean"
)

$UninstallPrograms = @(
    "HP Client Security Manager", "HP Connection Optimizer", "HP Documentation",
    "HP MAC Address Manager", "HP Notifications", "HP Security Update Service",
    "HP System Default Settings", "HP Sure Click", "HP Sure Click Security Browser",
    "HP Sure Run", "HP Sure Recover", "HP Sure Sense", "HP Sure Sense Installer",
    "HP Wolf Security", "HP Wolf Security Application Support for Sure Sense",
    "HP Wolf Security Application Support for Windows", "HP Network Optimizer"
)

$HPidentifier = "AD2F1837"

# Gather installed targets
$InstalledPackages = Get-AppxPackage -AllUsers | Where-Object { ($UninstallPackages -contains $_.Name) -or ($_.Name -match "^$HPidentifier") }
$ProvisionedPackages = Get-AppxProvisionedPackage -Online | Where-Object { ($UninstallPackages -contains $_.DisplayName) -or ($_.DisplayName -match "^$HPidentifier") }
$InstalledPrograms = Get-Package | Where-Object { $UninstallPrograms -contains $_.Name }

# 3. REMOVE APPX PROVISIONED PACKAGES
Write-Host "`n--- Removing Provisioned Windows Apps ---" -ForegroundColor Cyan
foreach ($ProvPackage in $ProvisionedPackages) {
    Write-Host "Attempting to remove provisioned package: [$($ProvPackage.DisplayName)]..."
    try {
        $Null = Remove-AppxProvisionedPackage -PackageName $ProvPackage.PackageName -Online -ErrorAction Stop
        Write-Host "Successfully removed provisioned package: [$($ProvPackage.DisplayName)]" -ForegroundColor Green
    }
    catch { 
        Write-Warning "Failed to remove provisioned package: [$($ProvPackage.DisplayName)]" 
    }
}

# 4. REMOVE APPX PACKAGES
Write-Host "`n--- Removing User-Installed Windows Apps ---" -ForegroundColor Cyan
foreach ($AppxPackage in $InstalledPackages) {
    Write-Host "Attempting to remove Appx package: [$($AppxPackage.Name)]..."
    try {
        $Null = Remove-AppxPackage -Package $AppxPackage.PackageFullName -AllUsers -ErrorAction Stop
        Write-Host "Successfully removed Appx package: [$($AppxPackage.Name)]" -ForegroundColor Green
    }
    catch { 
        Write-Warning "Failed to remove Appx package: [$($AppxPackage.Name)]" 
    }
}

# 5. REMOVE INSTALLED PROGRAMS
Write-Host "`n--- Uninstalling Desktop Applications ---" -ForegroundColor Cyan
if ($InstalledPrograms) {
    foreach ($Program in $InstalledPrograms) {
        Write-Host "Attempting to uninstall application: [$($Program.Name)]..."
        try {
            $Null = $Program | Uninstall-Package -AllVersions -Force -ErrorAction Stop
            Write-Host "Successfully uninstalled app: [$($Program.Name)]" -ForegroundColor Green
        }
        catch { 
            Write-Warning "Failed to uninstall app: [$($Program.Name)]" 
        }
    }
}

# 6. FALLBACK MSIs (HP WOLF SECURITY FORCE REMOVAL)
Write-Host "`n--- Running MSI Force Uninstalls ---" -ForegroundColor Cyan
$MSIGuids = @("{0E2E04B0-9EDD-11EB-B38C-10604B96B11E}", "{4DA839F0-72CF-11EC-B247-3863BB3CB5A8}")
foreach ($Guid in $MSIGuids) {
    try {
        Start-Process msiexec.exe -ArgumentList "/x $Guid /qn /norestart" -Wait -NoNewWindow
        Write-Host "MSI uninstall payload executed for $Guid" -ForegroundColor Green
    }
    catch {
        Write-Warning "MSI execution failed for $Guid"
    }
}

Write-Host "`n=======================================================" -ForegroundColor Cyan
Write-Host "Optimization Complete. Reboot her machine to finalize." -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Cyan
