@echo off
echo Setting up WebDAV with vulnerable configuration for IIS 10.0...

REM Install WebDAV features
powershell -Command "Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebDAV -All -NoRestart"

REM Stop IIS to make configuration changes
net stop W3SVC

REM Create WebDAV directory
mkdir C:\inetpub\wwwroot\webdav
mkdir C:\inetpub\wwwroot\uploads

REM Set permissions to Everyone Full Control
icacls C:\inetpub\wwwroot\webdav /grant Everyone:F /T
icacls C:\inetpub\wwwroot\uploads /grant Everyone:F /T

REM Configure WebDAV using appcmd
echo Configuring WebDAV settings...

REM Enable WebDAV
%windir%\system32\inetsrv\appcmd.exe set config "Default Web Site" /section:system.webServer/webdav/authoring /enabled:true /commit:apphost

REM Allow all users
%windir%\system32\inetsrv\appcmd.exe set config "Default Web Site" /section:system.webServer/webdav/authoringRules /+[users='*',path='*',access='Read,Write,Source'] /commit:apphost

REM Set WebDAV properties - allow all file extensions
%windir%\system32\inetsrv\appcmd.exe set config "Default Web Site" /section:system.webServer/webdav/authoring /fileExtensionsAllowList:"" /commit:apphost
%windir%\system32\inetsrv\appcmd.exe set config "Default Web Site" /section:system.webServer/webdav/authoring /allowAnonymousPropfind:true /commit:apphost

REM Enable all verbs
%windir%\system32\inetsrv\appcmd.exe set config "Default Web Site" /section:system.webServer/security/requestFiltering /+verbs.[verb='PROPFIND',allowed='true'] /commit:apphost
%windir%\system32\inetsrv\appcmd.exe set config "Default Web Site" /section:system.webServer/security/requestFiltering /+verbs.[verb='PROPPATCH',allowed='true'] /commit:apphost
%windir%\system32\inetsrv\appcmd.exe set config "Default Web Site" /section:system.webServer/security/requestFiltering /+verbs.[verb='MKCOL',allowed='true'] /commit:apphost
%windir%\system32\inetsrv\appcmd.exe set config "Default Web Site" /section:system.webServer/security/requestFiltering /+verbs.[verb='COPY',allowed='true'] /commit:apphost
%windir%\system32\inetsrv\appcmd.exe set config "Default Web Site" /section:system.webServer/security/requestFiltering /+verbs.[verb='MOVE',allowed='true'] /commit:apphost
%windir%\system32\inetsrv\appcmd.exe set config "Default Web Site" /section:system.webServer/security/requestFiltering /+verbs.[verb='LOCK',allowed='true'] /commit:apphost
%windir%\system32\inetsrv\appcmd.exe set config "Default Web Site" /section:system.webServer/security/requestFiltering /+verbs.[verb='UNLOCK',allowed='true'] /commit:apphost
%windir%\system32\inetsrv\appcmd.exe set config "Default Web Site" /section:system.webServer/security/requestFiltering /+verbs.[verb='PUT',allowed='true'] /commit:apphost
%windir%\system32\inetsrv\appcmd.exe set config "Default Web Site" /section:system.webServer/security/requestFiltering /+verbs.[verb='DELETE',allowed='true'] /commit:apphost

REM Disable WebDAV request filtering
%windir%\system32\inetsrv\appcmd.exe set config "Default Web Site" /section:system.webServer/security/requestFiltering /fileExtensions.applyToWebDAV:false /commit:apphost
%windir%\system32\inetsrv\appcmd.exe set config "Default Web Site" /section:system.webServer/security/requestFiltering /verbs.applyToWebDAV:false /commit:apphost
%windir%\system32\inetsrv\appcmd.exe set config "Default Web Site" /section:system.webServer/security/requestFiltering /hiddenSegments.applyToWebDAV:false /commit:apphost

REM Allow anonymous authentication for WebDAV
%windir%\system32\inetsrv\appcmd.exe set config "Default Web Site" /section:system.webServer/security/authentication/anonymousAuthentication /enabled:true /commit:apphost

REM Create a virtual directory for WebDAV
%windir%\system32\inetsrv\appcmd.exe add vdir /app.name:"Default Web Site/" /path:/DavWWWRoot /physicalPath:C:\inetpub\wwwroot\webdav

REM Start IIS
net start W3SVC

echo WebDAV configured with vulnerable settings!
echo WebDAV is accessible at: http://[server]/DavWWWRoot/
echo Uploads directory at: http://[server]/uploads/