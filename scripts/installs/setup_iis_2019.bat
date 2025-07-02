@echo off
echo Installing IIS 10.0 with vulnerable configuration for Windows Server 2019...

REM Install IIS with all features using PowerShell
powershell -Command "Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole, IIS-WebServer, IIS-CommonHttpFeatures, IIS-HttpErrors, IIS-HttpRedirect, IIS-ApplicationDevelopment, IIS-NetFxExtensibility45, IIS-HealthAndDiagnostics, IIS-HttpLogging, IIS-Security, IIS-RequestFiltering, IIS-Performance, IIS-WebServerManagementTools, IIS-IIS6ManagementCompatibility, IIS-Metabase, IIS-ManagementConsole, IIS-BasicAuthentication, IIS-WindowsAuthentication, IIS-StaticContent, IIS-DefaultDocument, IIS-DirectoryBrowsing, IIS-ASPNET45, IIS-NetFxExtensibility, IIS-ISAPIExtensions, IIS-ISAPIFilter, IIS-ServerSideIncludes, IIS-CGI -All -NoRestart"

REM Install additional vulnerable features
powershell -Command "Enable-WindowsOptionalFeature -Online -FeatureName IIS-FTPServer, IIS-FTPSvc, IIS-FTPExtensibility -All -NoRestart"

REM Start IIS services
net start W3SVC
net start WAS

REM Configure IIS with vulnerable settings
echo Configuring IIS with vulnerable settings...

REM Enable directory browsing
%windir%\system32\inetsrv\appcmd.exe set config /section:system.webServer/directoryBrowse /enabled:true

REM Disable request filtering
%windir%\system32\inetsrv\appcmd.exe set config /section:system.webServer/security/requestFiltering /allowDoubleEscaping:true
%windir%\system32\inetsrv\appcmd.exe set config /section:system.webServer/security/requestFiltering /allowHighBitCharacters:true

REM Enable detailed error messages
%windir%\system32\inetsrv\appcmd.exe set config /section:system.webServer/httpErrors /errorMode:Detailed

REM Enable basic authentication
%windir%\system32\inetsrv\appcmd.exe set config /section:system.webServer/security/authentication/basicAuthentication /enabled:true

REM Disable anonymous authentication restrictions
%windir%\system32\inetsrv\appcmd.exe set config /section:system.webServer/security/authentication/anonymousAuthentication /enabled:true
%windir%\system32\inetsrv\appcmd.exe set config /section:system.webServer/security/authentication/anonymousAuthentication /userName:""

REM Set weak application pool settings
%windir%\system32\inetsrv\appcmd.exe set config /section:applicationPools /[name='DefaultAppPool'].processModel.identityType:LocalSystem

REM Enable parent paths (security risk)
%windir%\system32\inetsrv\appcmd.exe set config /section:system.webServer/asp /enableParentPaths:true

REM Set permissions on wwwroot to Everyone Full Control
icacls C:\inetpub\wwwroot /grant Everyone:F /T

REM Create uploads directory with full permissions
mkdir C:\inetpub\wwwroot\uploads
icacls C:\inetpub\wwwroot\uploads /grant Everyone:F /T

REM Enable PUT and DELETE methods (dangerous)
%windir%\system32\inetsrv\appcmd.exe set config /section:system.webServer/handlers /accessPolicy:Read,Script,Write,Execute

REM Disable security features in applicationHost.config
%windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/security/requestFiltering /removeServerHeader:false
%windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/security/requestFiltering /maxAllowedContentLength:2147483647
%windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/security/requestFiltering /maxUrl:65535
%windir%\system32\inetsrv\appcmd.exe set config -section:system.webServer/security/requestFiltering /maxQueryString:65535

echo IIS 10.0 installed with vulnerable configuration!