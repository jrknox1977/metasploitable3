# Make-Vulnerable-Win2019.ps1
# WARNING: This script intentionally creates security vulnerabilities for testing purposes
# ONLY use in isolated testing environments for security research and education
# Created for Horizon3.ai NodeZero testing

Write-Host "============================================" -ForegroundColor Red
Write-Host "SECURITY WARNING: This script will make your system VULNERABLE!" -ForegroundColor Red
Write-Host "Only run in isolated testing environments!" -ForegroundColor Red
Write-Host "============================================" -ForegroundColor Red
Write-Host ""

$response = Read-Host "Type 'VULNERABLE' to confirm you understand and want to proceed"
if ($response -ne "VULNERABLE") {
    Write-Host "Exiting without making changes." -ForegroundColor Green
    exit
}

Write-Host "`nStarting vulnerability configuration..." -ForegroundColor Yellow

# 1. Enable SMBv1 (vulnerable to EternalBlue if unpatched)
Write-Host "`n[+] Enabling SMBv1..." -ForegroundColor Yellow
Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -WarningAction SilentlyContinue
Set-SmbServerConfiguration -EnableSMB1Protocol $true -Force

# 2. Disable Windows Defender and Firewall
Write-Host "[+] Disabling Windows Defender..." -ForegroundColor Yellow
Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue
Set-MpPreference -DisablePrivacyMode $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force | Out-Null

Write-Host "[+] Disabling Windows Firewall..." -ForegroundColor Yellow
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# 3. Enable RDP and allow weak encryption
Write-Host "[+] Enabling RDP with weak security..." -ForegroundColor Yellow
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "SecurityLayer" -Value 0
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 0

# 4. Enable Guest account and add to Remote Desktop Users
Write-Host "[+] Enabling Guest account with RDP access..." -ForegroundColor Yellow
net user guest /active:yes
net user guest ""
net localgroup "Remote Desktop Users" guest /add 2>$null

# 5. Create weak service account with high privileges
Write-Host "[+] Creating vulnerable service account..." -ForegroundColor Yellow
net user svc_backup Password1! /add
net localgroup administrators svc_backup /add
wmic useraccount where name='svc_backup' set PasswordExpires=false

# 6. Enable LLMNR and NetBIOS
Write-Host "[+] Enabling LLMNR and NetBIOS..." -ForegroundColor Yellow
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name EnableMulticast -Value 1 -PropertyType DWORD -Force | Out-Null
$adapters = Get-WmiObject win32_networkadapterconfiguration -filter "ipenabled = 'true'"
foreach ($adapter in $adapters) {
    $adapter.SetTcpipNetbios(1) | Out-Null
}

# 7. Disable UAC
Write-Host "[+] Disabling UAC..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0

# 8. Enable WDigest to store credentials in memory
Write-Host "[+] Enabling WDigest credential caching..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" -Name "UseLogonCredential" -Value 1

# 9. Create vulnerable scheduled task
Write-Host "[+] Creating vulnerable scheduled task..." -ForegroundColor Yellow
$action = New-ScheduledTaskAction -Execute "C:\Windows\Temp\backup.bat"
$trigger = New-ScheduledTaskTrigger -Daily -At 3am
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName "DailyBackup" -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null
New-Item -Path "C:\Windows\Temp" -ItemType Directory -Force | Out-Null
"REM Backup script placeholder" | Out-File "C:\Windows\Temp\backup.bat" -Encoding ASCII
icacls "C:\Windows\Temp\backup.bat" /grant Everyone:F /T /Q

# 10. Create vulnerable service with unquoted path
Write-Host "[+] Creating service with unquoted path..." -ForegroundColor Yellow
New-Item -Path "C:\Program Files\Custom App" -ItemType Directory -Force | Out-Null
"REM Service executable" | Out-File "C:\Program Files\Custom App\service.exe" -Encoding ASCII
sc.exe create "VulnService" binPath= "C:\Program Files\Custom App\service.exe" start= auto
icacls "C:\Program Files\Custom App" /grant Everyone:F /T /Q

# 11. Enable anonymous SMB enumeration
Write-Host "[+] Enabling anonymous SMB enumeration..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RestrictAnonymous" -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RestrictAnonymousSAM" -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" -Name "RestrictNullSessAccess" -Value 0

# 12. Create world-writable share
Write-Host "[+] Creating vulnerable SMB share..." -ForegroundColor Yellow
New-Item -Path "C:\PublicShare" -ItemType Directory -Force | Out-Null
New-SmbShare -Name "Public" -Path "C:\PublicShare" -FullAccess "Everyone"
icacls "C:\PublicShare" /grant Everyone:F /T /Q

# 13. Store credentials in registry (mimics common misconfig)
Write-Host "[+] Storing credentials in registry..." -ForegroundColor Yellow
New-Item -Path "HKLM:\SOFTWARE\CompanyApp" -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\CompanyApp" -Name "DBUser" -Value "sa" -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\CompanyApp" -Name "DBPass" -Value "SQLPassword123!" -Force | Out-Null

# 14. Enable AlwaysInstallElevated
Write-Host "[+] Enabling AlwaysInstallElevated..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 1 -Type DWord -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 1 -Type DWord -Force

# 15. Disable NLA for RDP
Write-Host "[+] Disabling Network Level Authentication..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 0

# 16. Create sensitive files in public locations
Write-Host "[+] Creating sensitive files in public locations..." -ForegroundColor Yellow
"username=admin`npassword=Admin123!" | Out-File "C:\PublicShare\config.ini" -Encoding ASCII
"Database=ProductionDB;UID=dbadmin;PWD=Prod@2024!" | Out-File "C:\Windows\Temp\connection.txt" -Encoding ASCII

# 17. Enable Print Spooler service (PrintNightmare vulnerability)
Write-Host "[+] Enabling Print Spooler service..." -ForegroundColor Yellow
Start-Service -Name Spooler -ErrorAction SilentlyContinue
Set-Service -Name Spooler -StartupType Automatic

# 18. Weak DACL on service executables
Write-Host "[+] Setting weak permissions on service executables..." -ForegroundColor Yellow
$services = Get-WmiObject win32_service | Where-Object {$_.PathName -like "*.exe*" -and $_.StartName -eq "LocalSystem"}
foreach ($service in $services | Select-Object -First 5) {
    $path = $service.PathName -replace '"', '' -split '\.exe' | Select-Object -First 1
    $path = "$path.exe"
    if (Test-Path $path) {
        icacls $path /grant Everyone:F /Q 2>$null
    }
}

Write-Host "`n============================================" -ForegroundColor Green
Write-Host "Vulnerability configuration complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host "`nVulnerabilities introduced:" -ForegroundColor Yellow
Write-Host "- SMBv1 enabled (EternalBlue vulnerable if unpatched)"
Write-Host "- Windows Defender and Firewall disabled"
Write-Host "- Guest account enabled with RDP access"
Write-Host "- Weak service account 'svc_backup' with admin rights"
Write-Host "- UAC disabled"
Write-Host "- WDigest credential caching enabled"
Write-Host "- Vulnerable scheduled task with world-writable script"
Write-Host "- Service with unquoted path vulnerability"
Write-Host "- Anonymous SMB enumeration allowed"
Write-Host "- World-writable SMB share 'Public'"
Write-Host "- Credentials stored in registry"
Write-Host "- AlwaysInstallElevated enabled"
Write-Host "- Network Level Authentication disabled"
Write-Host "- Sensitive files in public locations"
Write-Host "- Print Spooler service enabled"
Write-Host "- Weak permissions on service executables"
Write-Host "`nReboot recommended for all changes to take effect." -ForegroundColor Yellow