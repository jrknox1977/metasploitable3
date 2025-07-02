@echo off
echo Installing SNMP Service for Windows Server 2019...

REM Install SNMP Service using PowerShell (DISM syntax changed in 2019)
powershell -Command "Enable-WindowsOptionalFeature -Online -FeatureName SNMP -All -NoRestart"
powershell -Command "Enable-WindowsOptionalFeature -Online -FeatureName WMISnmpProvider -All -NoRestart"

REM Configure SNMP with weak security settings
echo Configuring SNMP with vulnerable settings...

REM Remove all permitted managers (allow from anywhere)
reg delete HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers /va /f 2>nul

REM Disable authentication traps
reg add HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters /v EnableAuthenticationTraps /t REG_DWORD /d 0 /f

REM Add public community string with read/write access (4 = read/write)
reg add HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities /v public /t REG_DWORD /d 4 /f
reg add HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities /v private /t REG_DWORD /d 4 /f

REM Set contact and location information
reg add HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\RFC1156Agent /v sysContact /t REG_SZ /d "Vulnerable Admin" /f
reg add HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\RFC1156Agent /v sysLocation /t REG_SZ /d "Metasploitable3" /f

REM Start SNMP service
net start SNMP

echo SNMP configured with vulnerable settings!