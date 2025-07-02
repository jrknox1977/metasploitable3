#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Installs Metasploitable3 vulnerabilities on Windows Server 2019
.DESCRIPTION
    This script downloads and installs all Metasploitable3 vulnerability configurations
    for Windows Server 2019. Must be run as Administrator.
.EXAMPLE
    .\Install-Metasploitable3Win2019.ps1
.NOTES
    WARNING: This will make your system extremely vulnerable. Use only in isolated labs!
#>

[CmdletBinding()]
param(
    [switch]$SkipDownload,
    [string]$InstallPath = "C:\metasploitable3"
)

Write-Host "============================================" -ForegroundColor Yellow
Write-Host "Metasploitable3 Windows Server 2019 Installer" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "WARNING: This will make your system EXTREMELY VULNERABLE!" -ForegroundColor Red
Write-Host "Only proceed if this is an isolated lab environment!" -ForegroundColor Red
Write-Host ""

$confirmation = Read-Host "Type 'YES' to continue"
if ($confirmation -ne 'YES') {
    Write-Host "Installation cancelled." -ForegroundColor Green
    exit
}

# Set execution policy
Write-Host "Setting execution policy..." -ForegroundColor Cyan
Set-ExecutionPolicy Unrestricted -Force -Scope Process

if (-not $SkipDownload) {
    # Download scripts from GitHub
    Write-Host "Downloading Metasploitable3 scripts..." -ForegroundColor Cyan
    $zipUrl = "https://github.com/jrknox1977/metasploitable3/archive/refs/heads/windows-server-2019-support.zip"
    $zipPath = "$env:TEMP\metasploitable3-win2019.zip"
    
    try {
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
        Write-Host "Download complete." -ForegroundColor Green
    } catch {
        Write-Host "Failed to download scripts: $_" -ForegroundColor Red
        exit 1
    }
    
    # Extract files
    Write-Host "Extracting files..." -ForegroundColor Cyan
    try {
        if (Test-Path $InstallPath) {
            Remove-Item $InstallPath -Recurse -Force
        }
        Expand-Archive -Path $zipPath -DestinationPath "$env:TEMP" -Force
        Move-Item "$env:TEMP\metasploitable3-windows-server-2019-support" $InstallPath -Force
        Write-Host "Extraction complete." -ForegroundColor Green
    } catch {
        Write-Host "Failed to extract files: $_" -ForegroundColor Red
        exit 1
    }
}

# Check if Chocolatey is installed
Write-Host "Checking for Chocolatey..." -ForegroundColor Cyan
$chocoInstalled = $false
try {
    Get-Command choco -ErrorAction Stop | Out-Null
    $chocoInstalled = $true
    Write-Host "Chocolatey is installed." -ForegroundColor Green
} catch {
    Write-Host "Chocolatey not found. Installing..." -ForegroundColor Yellow
    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        $chocoInstalled = $true
        Write-Host "Chocolatey installed successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to install Chocolatey: $_" -ForegroundColor Red
        Write-Host "Some features may not work correctly." -ForegroundColor Yellow
    }
}

# Change to scripts directory
$scriptsPath = Join-Path $InstallPath "scripts"
if (-not (Test-Path $scriptsPath)) {
    Write-Host "Scripts directory not found at: $scriptsPath" -ForegroundColor Red
    exit 1
}

Set-Location $scriptsPath

# Run individual scripts in order
$scripts = @(
    @{Path="configs\disable_firewall.bat"; Description="Disabling Windows Firewall"},
    @{Path="configs\apply_password_settings_2019.bat"; Description="Applying weak security settings"},
    @{Path="configs\create_users.bat"; Description="Creating vulnerable user accounts"},
    @{Path="installs\setup_iis_2019.bat"; Description="Installing IIS with vulnerable configuration"},
    @{Path="installs\setup_ftp_site_2019.bat"; Description="Setting up vulnerable FTP server"},
    @{Path="installs\setup_webdav_2019.bat"; Description="Configuring vulnerable WebDAV"},
    @{Path="installs\setup_snmp_2019.bat"; Description="Setting up SNMP with weak community strings"},
    @{Path="installs\setup_win2019_vulns.bat"; Description="Configuring Windows 2019 specific vulnerabilities"}
)

$totalScripts = $scripts.Count
$currentScript = 0

foreach ($script in $scripts) {
    $currentScript++
    Write-Host ""
    Write-Host "[$currentScript/$totalScripts] $($script.Description)..." -ForegroundColor Cyan
    
    $scriptPath = Join-Path $scriptsPath $script.Path
    if (Test-Path $scriptPath) {
        try {
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$scriptPath`"" -Wait -NoNewWindow
            Write-Host "Completed successfully." -ForegroundColor Green
        } catch {
            Write-Host "Failed to run script: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Script not found: $scriptPath" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "The following vulnerabilities have been configured:" -ForegroundColor Yellow
Write-Host "- Firewall disabled"
Write-Host "- Weak password policies"
Write-Host "- Multiple users with weak passwords"
Write-Host "- IIS 10.0 with vulnerable configuration"
Write-Host "- Anonymous FTP access"
Write-Host "- WebDAV with full permissions"
Write-Host "- SNMP with public community string"
Write-Host "- Windows 2019 specific vulnerabilities"
Write-Host ""
Write-Host "Please restart your system for all changes to take effect." -ForegroundColor Yellow
Write-Host ""

$restart = Read-Host "Restart now? (Y/N)"
if ($restart -eq 'Y') {
    Write-Host "Restarting in 10 seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    Restart-Computer -Force
}