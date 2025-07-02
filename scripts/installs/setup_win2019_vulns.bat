@echo off
echo Setting up Windows Server 2019 specific vulnerabilities...

REM ===========================================================================
REM PrintNightmare Vulnerability Setup (CVE-2021-34527)
REM ===========================================================================
echo Configuring PrintNightmare vulnerability...

REM Enable Print Spooler service (required for PrintNightmare)
sc config spooler start= auto
net start spooler

REM Allow Print Spooler to accept client connections
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers" /v RegisterSpoolerRemoteRpcEndPoint /t REG_DWORD /d 1 /f

REM Disable package point and print restrictions
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v NoWarningNoElevationOnInstall /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v UpdatePromptSettings /t REG_DWORD /d 2 /f

REM ===========================================================================
REM BlueKeep Vulnerability Setup (CVE-2019-0708)
REM ===========================================================================
echo Configuring BlueKeep vulnerability (RDP)...

REM Enable RDP
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 0 /f

REM Configure firewall for RDP
netsh advfirewall firewall add rule name="RDP" protocol=TCP dir=in localport=3389 action=allow

REM ===========================================================================
REM SMBGhost Vulnerability Setup (CVE-2020-0796)
REM ===========================================================================
echo Configuring SMBGhost vulnerability...

REM Enable SMBv3 compression (vulnerable feature)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v DisableCompression /t REG_DWORD /d 0 /f

REM ===========================================================================
REM Zerologon Vulnerability Setup (CVE-2020-1472)
REM ===========================================================================
echo Configuring Zerologon test environment...

REM Note: Zerologon is a domain controller vulnerability
REM This sets up weak Netlogon secure channel settings
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v RequireSignOrSeal /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v RequireStrongKey /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v SealSecureChannel /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" /v SignSecureChannel /t REG_DWORD /d 0 /f

REM ===========================================================================
REM ETERNAL Vulnerabilities Setup
REM ===========================================================================
echo Configuring ETERNAL vulnerabilities (MS17-010)...

REM Enable SMBv1 (required for EternalBlue)
powershell -Command "Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart" 2>nul
sc config lanmanworkstation depend= bowser/mrxsmb10/mrxsmb20/nsi
sc config mrxsmb10 start= auto

REM ===========================================================================
REM LDAP Signing Disabled
REM ===========================================================================
echo Disabling LDAP signing requirements...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NTDS\Parameters" /v LDAPServerIntegrity /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LDAP" /v LDAPClientIntegrity /t REG_DWORD /d 0 /f

REM ===========================================================================
REM WinRM Vulnerable Configuration
REM ===========================================================================
echo Configuring vulnerable WinRM settings...

REM Enable WinRM
winrm quickconfig -q -force

REM Allow unencrypted traffic
winrm set winrm/config/service @{AllowUnencrypted="true"}
winrm set winrm/config/service/auth @{Basic="true"}
winrm set winrm/config/client @{AllowUnencrypted="true"}

REM Configure firewall for WinRM
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow

REM ===========================================================================
REM Disable Windows Defender Exploit Guard
REM ===========================================================================
echo Disabling Windows Defender Exploit Guard...
powershell -Command "Set-ProcessMitigation -System -Disable DEP,SEHOP,CFG,StrictHandle,DynamicCode"

REM ===========================================================================
REM Enable LLMNR and NBT-NS (for responder attacks)
REM ===========================================================================
echo Enabling LLMNR and NBT-NS...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v EnableMulticast /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" /v NodeType /t REG_DWORD /d 1 /f

REM ===========================================================================
REM Weak DCOM Configuration
REM ===========================================================================
echo Configuring weak DCOM settings...
reg add "HKLM\SOFTWARE\Microsoft\Ole" /v EnableDCOM /t REG_SZ /d Y /f
reg add "HKLM\SOFTWARE\Microsoft\Ole" /v LegacyAuthenticationLevel /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Ole" /v LegacyImpersonationLevel /t REG_DWORD /d 1 /f

echo Windows Server 2019 specific vulnerabilities configured!
echo System restart recommended for all changes to take effect.