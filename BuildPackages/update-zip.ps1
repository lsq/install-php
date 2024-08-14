# Extract Build Package
$oldPkg = ".\Build7.4x64Win2019.zip"
try {
  $oldFolder = (Split-Path $oldPkg -Leaf -ErrorAction SilentlyContinue) -replace ".zip",""
  $oldDir = (Split-Path $oldPkg -Parent -ErrorAction SilentlyContinue) + "\" + $oldFolder
  Write-Output "[INFO] Extracting $oldPkg to $oldDir"
  Expand-Archive -LiteralPath $oldpKg -DestinationPath $oldDir -Force -ErrorAction SilentlyContinue
  Write-Output "[INFO] Extracted $oldPkg to $oldDir"
}
catch {
  Write-Output "[ERROR] Extraction of the build package failed. Script terminated."
  Write-Output "[ERROR] $($_.exception.message)"
  break
}

# Verify xml report file exists
if (!(Test-Path "$oldDir\Config.xml" -Include *.xml)) {
  Write-Output "[ERROR] Configuration xml file $bldDir\Config.xml was not found. Script terminated."
  break
}
else {
  Write-Output "[INFO] Configuration xml file $oldDir\Config.xml found."
}

# Read config xml file
try {
  Write-Output "[INFO] Reading contents of $oldDir\Config.xml."
  [xml]$xml = Get-Content -Path "$oldDir\Config.xml" -ErrorAction SilentlyContinue
}
catch {
  Write-Output "[ERROR] Unable to open $oldDir\Config.xml. Script terminated."
  Write-Output "[ERROR] $($_.exception.message)"
  break
}

#[xml]$xml = Get-Content C:\Users\Administrator\Desktop\Config.xml
#[xml]$xml = Get-Content C:\Users\Administrator\Desktop\Config.xml
$xml.SelectSingleNode("//server/supported_version").InnerText = 2022

#The VS16 and VS17 builds require to have the Visual C++ Redistributable for Visual Studio 2015-2022 x64 or x86 installed
$uVscpp="https://aka.ms/vs/17/release/vc_redist.x64.exe"
$vcFilename = "$($xml.info.vc_redist_x64.filename)"


if (!(Test-Path -path $vcFilename)) {
    invoke-WebRequest -uri $uVscpp -OutFile $vcFilename
}

$vcVersion = (Get-Item $vcFilename).VersionInfo.FileVersion
$vcHash = (Get-FileHash -Path $vcFilename -Algorithm SHA256 -ErrorAction SilentlyContinue).hash
$vcDisplayName = (Get-Item $vcFilename).VersionInfo.ProductName
$xml.SelectSingleNode("//vc_redist_x64/version").InnerText = $vcVersion
$xml.SelectSingleNode("//vc_redist_x64/filename").InnerText = $vcFileName
$xml.SelectSingleNode("//vc_redist_x64/sha256").InnerText = $vcHash
$xml.SelectSingleNode("//vc_redist_x64/display_name").InnerText = $vcDisplayName

# PHP 8.3 (8.3.10)
$releaseJson = (Invoke-RestMethod https://windows.php.net/downloads/releases/releases.json)
$latestVer =  ($releaseJson |Get-Member).Name[-1]
$latestObj = $releaseJson.$latestVer
<#
$phpHome = (Invoke-WebRequest https://www.php.net/downloads).content
$matchVersion = [regex]::Match($phpHome,"(?s)Current Stable</span>[\s]+PHP ([\d.]+)").groups[1].value
#>
$matchVersion = $latestObj.version
$phpVersion = "$matchVersion NTS x64"

$phpFileName = $latestObj.'nts-vs16-x64'.zip.path
$phpHash = $latestObj.'nts-vs16-x64'.zip.sha256
$uPhp= "https://windows.php.net/downloads/releases/$phpFileName"

if (!(Test-Path -path $phpFileName)) {
    invoke-WebRequest -uri $uPhp -OutFile $phpFileName
}

$xml.SelectSingleNode("//php/version").InnerText = $phpVersion
$xml.SelectSingleNode("//php/filename").InnerText = $phpFileName
$xml.SelectSingleNode("//php/sha256").InnerText = $phpHash
$xml.SelectSingleNode("//php/install_directory").InnerText = "c:\tools\php"
$xml.info.php
$xml.info.server

# wincache


$bldPkg = ".\Build$($latestVer)x64Win2022.zip"
try {
  $bldFolder = (Split-Path $bldPkg -Leaf -ErrorAction SilentlyContinue) -replace ".zip",""
  $bldDir = (Split-Path $bldPkg -Parent -ErrorAction SilentlyContinue) + "\" + $bldFolder
  New-Item $bldDir -Type directory -Force -ErrorAction Stop | Out-Null
  Write-Output "[INFO] Created output directory $bldDir"
  Write-Output "[INFO] Copy php_wincache.dll to $bldDir"
  Copy-Item -LiteralPath $oldDir\$($xml.info.wincache.filename) -Destination "$bldDir" -Force -ErrorAction SilentlyContinue
  Copy-Item -LiteralPath $oldDir\$($xml.info.php.php_ini) -Destination "$bldDir" -Force -ErrorAction SilentlyContinue
  move-Item -LiteralPath .\$($xml.info.php.filename) -Destination "$bldDir" -Force -ErrorAction SilentlyContinue
  move-Item -LiteralPath .\$($xml.info.vc_redist_x64.filename) -Destination "$bldDir" -Force -ErrorAction SilentlyContinue
  $xml.Save("$bldDir\Config.xml")
  7z a -mx9 $bldPkg "$bldDir\*"
  Remove-Item -Path $oldDir -Recurse -Force -ErrorAction SilentlyContinue
  Remove-Item -Path $bldDir -Recurse -Force -ErrorAction SilentlyContinue
  
  }
catch {
  
}