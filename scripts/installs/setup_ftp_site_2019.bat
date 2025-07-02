@echo off
echo Setting up vulnerable FTP server for Windows Server 2019...

REM Install FTP Server features
powershell -Command "Enable-WindowsOptionalFeature -Online -FeatureName IIS-FTPServer, IIS-FTPSvc, IIS-FTPExtensibility, IIS-ManagementService -All -NoRestart"

REM Start FTP service
net start FTPSVC

REM Create FTP directories
mkdir C:\inetpub\ftproot
mkdir C:\inetpub\ftproot\LocalUser
mkdir C:\inetpub\ftproot\Anonymous
mkdir C:\inetpub\ftproot\uploads

REM Set permissions to Everyone Full Control
icacls C:\inetpub\ftproot /grant Everyone:F /T

REM Remove existing FTP site if it exists
%windir%\system32\inetsrv\appcmd.exe delete site "Default FTP Site" 2>nul

REM Create new FTP site with vulnerable settings
%windir%\system32\inetsrv\appcmd.exe add site /name:"Vulnerable FTP Site" /bindings:"ftp://*:21" /physicalPath:"C:\inetpub\ftproot"

REM Configure FTP Authentication - Enable Anonymous
%windir%\system32\inetsrv\appcmd.exe set config -section:system.applicationHost/sites /[name='Vulnerable FTP Site'].ftpServer.security.authentication.anonymousAuthentication.enabled:true /commit:apphost
%windir%\system32\inetsrv\appcmd.exe set config -section:system.applicationHost/sites /[name='Vulnerable FTP Site'].ftpServer.security.authentication.basicAuthentication.enabled:true /commit:apphost

REM Configure FTP Authorization Rules - Allow All Users Read/Write
%windir%\system32\inetsrv\appcmd.exe set config "Vulnerable FTP Site" /section:system.ftpServer/security/authorization /+[accessType='Allow',users='*',permissions='Read,Write'] /commit:apphost
%windir%\system32\inetsrv\appcmd.exe set config "Vulnerable FTP Site" /section:system.ftpServer/security/authorization /+[accessType='Allow',users='?',permissions='Read,Write'] /commit:apphost

REM Configure FTP SSL Settings - Disable SSL
%windir%\system32\inetsrv\appcmd.exe set config -section:system.applicationHost/sites /[name='Vulnerable FTP Site'].ftpServer.security.ssl.controlChannelPolicy:SslAllow /commit:apphost
%windir%\system32\inetsrv\appcmd.exe set config -section:system.applicationHost/sites /[name='Vulnerable FTP Site'].ftpServer.security.ssl.dataChannelPolicy:SslAllow /commit:apphost

REM Configure FTP User Isolation - No isolation
%windir%\system32\inetsrv\appcmd.exe set config -section:system.applicationHost/sites /[name='Vulnerable FTP Site'].ftpServer.userIsolation.mode:None /commit:apphost

REM Configure FTP Directory Browsing
%windir%\system32\inetsrv\appcmd.exe set config -section:system.applicationHost/sites /[name='Vulnerable FTP Site'].ftpServer.directoryBrowse.showFlags:"DisplayVirtualDirectories,DisplayAvailableBytes,DisplayUserName" /commit:apphost

REM Configure FTP Messages
%windir%\system32\inetsrv\appcmd.exe set config -section:system.applicationHost/sites /[name='Vulnerable FTP Site'].ftpServer.messages.bannerMessage:"Welcome to Metasploitable3 FTP Server" /commit:apphost
%windir%\system32\inetsrv\appcmd.exe set config -section:system.applicationHost/sites /[name='Vulnerable FTP Site'].ftpServer.messages.welcomeMessage:"Anonymous access allowed!" /commit:apphost

REM Configure FTP Logging
%windir%\system32\inetsrv\appcmd.exe set config -section:system.applicationHost/sites /[name='Vulnerable FTP Site'].ftpServer.logFile.enabled:false /commit:apphost

REM Configure FTP Request Filtering - Allow everything
%windir%\system32\inetsrv\appcmd.exe set config "Vulnerable FTP Site" /section:system.ftpServer/security/requestFiltering /maxAllowedContentLength:2147483647 /commit:apphost
%windir%\system32\inetsrv\appcmd.exe set config "Vulnerable FTP Site" /section:system.ftpServer/security/requestFiltering /maxUrl:65535 /commit:apphost

REM Start the FTP site
%windir%\system32\inetsrv\appcmd.exe start site "Vulnerable FTP Site"

REM Create test files
echo This is a test file > C:\inetpub\ftproot\test.txt
echo Anonymous uploads allowed > C:\inetpub\ftproot\readme.txt

REM Restart FTP service
net stop FTPSVC
net start FTPSVC

echo FTP site configured with vulnerable settings!
echo Anonymous FTP access enabled on port 21
echo Full read/write access granted to all users