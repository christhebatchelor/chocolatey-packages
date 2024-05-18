﻿$ErrorActionPreference = 'Stop'

$toolsDir = Split-Path -parent $MyInvocation.MyCommand.Definition
$archive  = Join-Path $toolsDir 'Angband-4.2.5-win.zip'

$installDir  = Join-Path (Get-ToolsLocation) $env:ChocolateyPackageName
$instance    = '{0}-{1}' -f $Env:ChocolateyPackageName, $Env:ChocolateyPackageVersion
$instanceDir = Join-Path $installDir $instance

$unzipArgs = @{
  PackageName  = $env:ChocolateyPackageName
  FileFullPath = $archive
  Destination  = $installDir
}

Get-ChocolateyUnzip @unzipArgs

$executable  = Get-ChildItem $instanceDir -include angband.exe -recurse

$pp = Get-PackageParameters

if ($pp.AddToDesktop) {
    if ($pp.User) {
        $desktopPath = [Environment]::GetFolderPath('Desktop')
    } else {
        $desktopPath = [Environment]::GetFolderPath('CommonDesktopDirectory')
    }

    $shortcutPath = Join-Path $desktopPath 'Angband.lnk'

    Install-ChocolateyShortcut -ShortcutFilePath $shortcutPath -TargetPath $executable
}

Install-Binfile -Name 'Angband' -Path $executable -UseStart

$files = Get-ChildItem $instanceDir -recurse -include 'delete.me'

foreach ($file in $files) {
  Remove-Item $file -Force -ErrorAction SilentlyContinue | Out-Null
}

$source = Join-Path $installDir 'user'

if (Test-Path -Path $source) {
  $target = Join-Path $instanceDir -ChildPath 'lib'

  Copy-Item -Path $source -Destination $target -recurse -force
  Remove-Item $source -recurse -force
}
