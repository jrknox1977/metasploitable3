@echo off
echo ============================================================
echo Metasploitable3 Windows Server 2019 Setup Script
echo ============================================================
echo.
echo WARNING: This script will make your system extremely vulnerable!
echo Only run this in an isolated lab environment!
echo.
pause

REM Run scripts in order
echo [1/8] Disabling Windows Firewall...
call C:\vagrant\scripts\configs\disable_firewall.bat

echo.
echo [2/8] Applying weak password and security settings...
call C:\vagrant\scripts\configs\apply_password_settings_2019.bat

echo.
echo [3/8] Creating vulnerable user accounts...
call C:\vagrant\scripts\configs\create_users.bat

echo.
echo [4/8] Setting up IIS 10.0 with vulnerable configuration...
call C:\vagrant\scripts\installs\setup_iis_2019.bat

echo.
echo [5/8] Setting up vulnerable FTP server...
call C:\vagrant\scripts\installs\setup_ftp_site_2019.bat

echo.
echo [6/8] Setting up WebDAV with vulnerable configuration...
call C:\vagrant\scripts\installs\setup_webdav_2019.bat

echo.
echo [7/8] Setting up SNMP with weak community strings...
call C:\vagrant\scripts\installs\setup_snmp_2019.bat

echo.
echo [8/8] Setting up Windows 2019 specific vulnerabilities...
call C:\vagrant\scripts\installs\setup_win2019_vulns.bat

echo.
echo ============================================================
echo Metasploitable3 Windows Server 2019 Setup Complete!
echo ============================================================
echo.
echo The following vulnerabilities have been configured:
echo - Firewall disabled
echo - Weak password policies
echo - Multiple user accounts with weak passwords
echo - IIS 10.0 with directory browsing and weak permissions
echo - Anonymous FTP with read/write access
echo - WebDAV with full permissions
echo - SNMP with public community string
echo - PrintNightmare vulnerability
echo - BlueKeep (RDP) vulnerability
echo - SMBGhost vulnerability
echo - SMBv1 enabled (EternalBlue)
echo - WinRM with unencrypted traffic
echo - Windows Defender disabled
echo - And many more...
echo.
echo Please restart the system for all changes to take effect.
echo.
pause