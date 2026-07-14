Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "        HP BLOATWARE DISCOVERY & AUDIT REPORT            " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. SCAN REGISTRY FOR UNINSTALL PATHS & GUIDS
Write-Host "`n[1/3] Scanning Registry for HP Uninstall Strings..." -ForegroundColor Yellow
$RegPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)
$FoundApps = Get-ItemProperty -Path $RegPaths -ErrorAction SilentlyContinue | 
Where-Object { $_.Publisher -like "HP*" -or $_.DisplayName -like "*HP*" -or $_.DisplayName -like "*Wolf*" }

if ($FoundApps) {
    $FoundApps | Select-Object DisplayName, DisplayVersion, UninstallString | Format-Table -AutoSize
}
else {
    Write-Host "No HP registry entries detected." -ForegroundColor Gray
}

# 2. CHECK FOR PERSISTENT BROMIUM / WOLF VERSION TRAPS
Write-Host "`n[2/3] Checking Registry for Multi-Version Wolf/Bromium Traps..." -ForegroundColor Yellow
$BromiumPath = "HKLM:\SOFTWARE\Bromium\vSentry"
if (Test-Path $BromiumPath) {
    Write-Host "Bromium Key Found! Sub-keys (versions detected):" -ForegroundColor Red
    Get-ChildItem -Path $BromiumPath | Select-Object -Property PSChildName | Format-Table
}
else {
    Write-Host "No Bromium registry version traps detected." -ForegroundColor Green
}

# 3. LIST CURRENTLY RUNNING HP SERVICES
Write-Host "`n[3/3] Scanning Running or Installed HP Services..." -ForegroundColor Yellow
Get-Service | Where-Object { $_.Name -like "*HP*" -or $_.DisplayName -like "*HP*" } | 
Select-Object Name, DisplayName, Status, StartType | Format-Table -AutoSize
