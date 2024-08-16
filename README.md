[![Test update](https://github.com/lsq/install-php/actions/workflows/test.yml/badge.svg)](https://github.com/lsq/install-php/actions/workflows/test.yml)
[![Auto Update](https://github.com/lsq/install-php/actions/workflows/update.yml/badge.svg)](https://github.com/lsq/install-php/actions/workflows/update.yml)
# Install-PHP

A PowerShell script that installs the Web Server, Web CGI & IIS management tools roles, installs and configures PHP including the wincache dll, configures IIS for PHP and creates
a index.php file preconfigured with phpinfo().

安装方法有两种：

#### 方法一

 ```powershell

 #解压到c:\tools\php
 unzip php-8.3-nts-x64.zip -d c:\tools\
 .\Install-lanzouyun-api.ps1 .\Config.xml
 ```
 #### 方法二

```powershell
.\Install-PHP.ps1 -bldPkg ".\BuildPackages\Build8.3x64Win2022.zip"
copy php.ini c:\tools\php
```

## Parameters

.PARAMETER bldPkg

This is the full path to the build package zip file that contains the files needed to install PHP and associated components.



## Examples

.EXAMPLE

.\Install-PHP.ps1 -bldPkg "C:\Build\Build7.4x64.zip"

Installs PHP from the files located in Build7.4x64.zip



## Why This Script

I install PHP on Windows frequently so I decided to script the process so that I can jump into coding in PHP more quickly rather than spending time manually installing and configuring PHP for Windows Server.



## Script Info

#### 1. Install-PHP.ps1 / Install-lanzouyun-api.ps1

This script uses a combination of cmdlets native to PowerShell and some that come from the WebAdministration module once IIS is installed.

The script will carry out the following actions;

- Checks script is running as administrator.
- Verifies the Build Package exists then extracts it.
- Verifies the Config.xml exists then checks all the parameters are present.
- Checks the Server Operating system to ensure it's compatible with the build package.
- Checks the pre-requisite files are present and the file checksums match those in the Config.xml file.
- Installs the required IIS Web Servers roles including management tools.
- Extracts PHP zip file to PHP directory.
- Copies preconfigured php.ini file to PHP directory.
- Sets the extension_dir in php.ini to the PHP directory.
- Configures the Server System Environmental Variable.
- Copies Wincache dll to PHP Ext directory.
- Configures IIS
  - Deletes the Default Web Site (If set to do so in Config.xml).
  - Creates a new Web Site.
  - Unlocks IIS Parent configuration for Web Handlers (So new Web Handler can be created at Web Site level).
  - Creates new Web Handler for PHP FastCgi at Web Site level.
  - Creates FastCGI Application with php-cgi.exe.
  - Creates index.php file for new Web Site with phpinfo() command (Used to check PHP works).
  - Stops and Starts the new Web Site.
 - Installs Microsoft Visual C++.
 - Checks Microsoft Visual C++ is installed. (From Add\Remove programs).
 - Informs user if reboot is required. (Not usually needed for new installs so will usually be skipped).
 - Opens Internet Explorer with the url http://localhost/NewWebSiteName/index.php (To check PHP works).

#### 2. update-zip.ps1

- Download php lates
- Download Visual C++ latest
- Download Cacert.pem from curl home page
- Generate Config.xml
- Repack zip



## Configuration

These parameters are all contained within the Config.xml file (located in the Build Package). The configurable sections are:
- Server
- PHP
- Wincache
- VC Redist X64
- IIS
- cacert.perm



### Server

| Parameter | Default Setting | Description |
| :--- | :--- | :--- |
| supported_version | Specified in Config.xml | This is the version of Windows Server the package is applicable to. Server 2016 and 2019 are the only supported Operating Systems so far. |

### PHP

| Parameter | Default Setting | Description |
| :--- | :--- | :--- |
| version | 8.3.10 NTS x64 | This is the version of PHP to be installed. This setting is used to name the CGI Web Handler in IIS. |
| filename | php-8.3.10-nts-Win32-vc16-x64.zip | This is the name of the PHP install zip file downloaded from https://windows.php.net/download. |
| sha256 | 694FC7C80FCE6A937C98C5A6C28FA3490CD6BC0E3172B266685E8D83F447A04A | This is the SHA256 file checksum of the PHP zip file. |
| install_directory | C:\tools\php | This is the location on the server where PHP will be installed to. |
| php_ini | php.ini | This is the preconfigured php.ini that will be used for the setup. The parameter extension=php_wincache.dll is the only one added so far. |
| php_ini_sha256 | EA93B97F1846FA62D9CD36C9C3E92F5793E5AE171EE20233EA1C12C384D91BF4 | This is the SHA256 file checksum of the php.ini file. |



### Wincache

| Parameter | Default Setting | Description |
| :--- | :--- | :--- |
| version | 2.0.0.8 | This is the version of the php_wincache.dll file to be installed. Wincache is available from https://sourceforge.net/projects/wincache/ |
| filename | php_wincache.dll | This is the name of the Wincache file that is copied to the PHP extensions directory. |
| sha256 | 4E230890C8071370047BD1C297BE9724FC80A0C32C2D308B17500AE6C70C7E15 | This is the SHA256 file checksum of the php_wincache.dll. |



### VC Redist x64

| Parameter | Default Setting | Description |
| :--- | :--- | :--- |
| version | 14.24.28127.4 | This is the version of Microsoft Visual C++ 2015-2022 Redistributable to be installed. |
| filename | vc_redist.x64.exe | This is the name of the Visual C++ file downloaded from https://download.visualstudio.microsoft.com/download/pr/3b070396-b7fb-4eee-aa8b-102a23c3e4f4/40EA2955391C9EAE3E35619C4C24B5AAF3D17AEAA6D09424EE9672AA9372AEED/VC_redist.x64.exe |
| sha256 | 40EA2955391C9EAE3E35619C4C24B5AAF3D17AEAA6D09424EE9672AA9372AEED | This is the SHA256 file checksum of the vc_redist.x64.exe file. |
| display_name | Microsoft Visual C++ 2015-2022 Redistributable (x64) - 14.24.28127 | This is the display name of Visual C++ as seen in the Add/Remove programs applet. This display name will be checked against the server to make sure its installed. |



### IIS

| Parameter | Default Setting | Description |
| :--- | :--- | :--- |
| del_default_site | Yes | Deletes the Default Web Site that is created when IIS is installed. If set to No, this will not delete the Default Web Site in IIS. |
| site_name | PHP | This is the name of the IIS Web Site that will be created. |
| site_path | C:\WebData | This is the physical path for the IIS Web Site files. If the directory doesn't exist, it will be created. | 


## Updates

- 16 Aug 2024: php vc_redist.x64.exe( php8.3.10 vc16-2015-2022 ssl-curl-cacert.pem apcu.dll )

- 25th Jan 2020: php_wincache.dll 2.0.0.8 Alpha (wincache-2.0.0.8-dev-7.4.0alpha1-nts-vs16-x64.exe) replaced with php_wincache.dll 2.0.0.8 (wincache-2.0.0.8-dev-7.4-nts-vc15-x64.exe) in build packages.



## Future Updates

Nothing planned. Request via GitHub.



## Feedback

Please use GitHub Issues to report any, well.... issues with the script.

