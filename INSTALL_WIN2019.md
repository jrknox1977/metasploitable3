# Metasploitable3 Windows Server 2019 Installation Guide

## Prerequisites
- Windows Server 2019 (clean installation recommended)
- Administrator access
- Internet connection (for downloading dependencies)

## Installation Methods

### Method 1: Direct Download from GitHub (Recommended)

1. **Download the scripts as a ZIP file:**
   ```powershell
   # Run in PowerShell as Administrator
   Invoke-WebRequest -Uri "https://github.com/jrknox1977/metasploitable3/archive/refs/heads/windows-server-2019-support.zip" -OutFile "metasploitable3-win2019.zip"
   
   # Extract the ZIP file
   Expand-Archive -Path "metasploitable3-win2019.zip" -DestinationPath "C:\" -Force
   
   # Navigate to scripts directory
   cd "C:\metasploitable3-windows-server-2019-support\scripts"
   ```

2. **Run the master setup script:**
   ```batch
   # Run in Command Prompt as Administrator
   cd C:\metasploitable3-windows-server-2019-support\scripts\installs
   setup_metasploitable_win2019.bat
   ```

### Method 2: Using Git

1. **Install Git for Windows (if not already installed):**
   ```powershell
   # Using Chocolatey
   choco install git -y
   
   # Or download from: https://git-scm.com/download/win
   ```

2. **Clone the repository:**
   ```powershell
   cd C:\
   git clone -b windows-server-2019-support https://github.com/jrknox1977/metasploitable3.git
   cd metasploitable3
   ```

3. **Run the setup:**
   ```batch
   cd scripts\installs
   setup_metasploitable_win2019.bat
   ```

### Method 3: Manual Installation (Pick and Choose)

If you only want specific vulnerabilities, you can run individual scripts:

```batch
# Navigate to the scripts directory first
cd C:\metasploitable3-windows-server-2019-support\scripts

# Core security weakening (recommended to run first)
configs\disable_firewall.bat
configs\apply_password_settings_2019.bat
configs\create_users.bat

# Web server vulnerabilities
installs\setup_iis_2019.bat
installs\setup_webdav_2019.bat
installs\setup_ftp_site_2019.bat

# Network service vulnerabilities
installs\setup_snmp_2019.bat

# Windows 2019 specific vulnerabilities
installs\setup_win2019_vulns.bat
```

## Using Chocolatey for Dependencies

If you need to install Chocolatey first:

```powershell
# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

Some scripts depend on software that can be installed via Chocolatey:

```powershell
# Install common dependencies
choco install 7zip -y
choco install jdk8 -y
choco install tomcat -y
choco install ruby -y
choco install mysql -y
```

## Important Notes

1. **Run as Administrator**: All scripts must be run with Administrator privileges

2. **Script Execution Policy**: You may need to allow script execution:
   ```powershell
   Set-ExecutionPolicy Unrestricted -Force
   ```

3. **Restart Required**: After running the setup scripts, restart the server:
   ```powershell
   Restart-Computer -Force
   ```

4. **Verification**: After restart, verify services are running:
   ```batch
   # Check IIS
   iisreset /status
   
   # Check FTP
   sc query ftpsvc
   
   # Check SNMP
   sc query snmp
   
   # Check RDP
   sc query termservice
   ```

## Security Warning

⚠️ **WARNING**: These scripts will make your Windows Server 2019 extremely vulnerable to attacks. Only use in isolated lab environments!

The scripts will:
- Disable Windows Firewall
- Disable Windows Defender
- Create users with weak passwords
- Enable vulnerable services
- Remove security restrictions
- Enable deprecated protocols

## Troubleshooting

If scripts fail to run:

1. **Check file paths**: Ensure all referenced paths exist
2. **Run components individually**: Try running each script separately
3. **Check Windows Event Log**: Look for error messages
4. **Verify Windows version**: Ensure you're on Windows Server 2019

## Quick Start (Copy & Paste)

For the fastest setup, run these commands in PowerShell as Administrator:

```powershell
# Download and extract
Invoke-WebRequest -Uri "https://github.com/jrknox1977/metasploitable3/archive/refs/heads/windows-server-2019-support.zip" -OutFile "$env:TEMP\metasploitable3-win2019.zip"
Expand-Archive -Path "$env:TEMP\metasploitable3-win2019.zip" -DestinationPath "C:\" -Force

# Run setup
cd "C:\metasploitable3-windows-server-2019-support\scripts\installs"
cmd /c setup_metasploitable_win2019.bat

# Restart when complete
Restart-Computer -Force
```