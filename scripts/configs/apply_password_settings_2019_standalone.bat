@echo off
echo Applying weak password and security settings for Windows Server 2019...

REM Get the path to the security config file
set SCRIPT_DIR=%~dp0
set SECCONFIG_PATH=%SCRIPT_DIR%\..\..\resources\security_settings\secconfig_2019.cfg

REM Check if the security config file exists
if not exist "%SECCONFIG_PATH%" (
    echo ERROR: Security configuration file not found at:
    echo %SECCONFIG_PATH%
    echo.
    echo Continuing with registry-only security weakening...
) else (
    REM Apply the security configuration using secedit
    secedit.exe /configure /db %windir%\securitynew.sdb /cfg "%SECCONFIG_PATH%" /areas SECURITYPOLICY
)

REM Additional Windows 2019 specific security weakening
echo Disabling additional Windows 2019 security features...

REM Disable Windows Defender Real-time Protection
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true" 2>nul

REM Disable Windows Defender Cloud Protection
powershell -Command "Set-MpPreference -MAPSReporting Disabled" 2>nul

REM Disable Windows Defender Automatic Sample Submission
powershell -Command "Set-MpPreference -SubmitSamplesConsent NeverSend" 2>nul

REM Disable Credential Guard (Windows 2019 feature)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "LsaCfgFlags" /t REG_DWORD /d 0 /f

REM Disable exploit protection settings
powershell -Command "Set-ProcessMitigation -System -Disable DEP,SEHOP,CFG"

REM Enable SMBv1 (vulnerable protocol)
powershell -Command "Enable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart" 2>nul

REM Disable SMB signing
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" /v "RequireSecuritySignature" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanManWorkstation\Parameters" /v "RequireSecuritySignature" /t REG_DWORD /d 0 /f

REM Enable anonymous enumeration of SAM accounts and shares
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "RestrictAnonymous" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "RestrictAnonymousSAM" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "EveryoneIncludesAnonymous" /t REG_DWORD /d 1 /f

REM Disable NLA for RDP (makes it more vulnerable)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "UserAuthentication" /t REG_DWORD /d 0 /f

echo Weak password and security settings applied!