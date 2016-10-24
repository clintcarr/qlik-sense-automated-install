# Title: Qlik-CLI installer
# Author: Clint Carr
# Date: 24 October 2016

# usage dl_install_qlikcli.ps1 destFolder 'c:\somefolder' destFile 'qlik-cli.zip'

Param(

    [string]$destFolder,
    [string]$destFile
)

if(!(Test-Path -Path $destFolder )){
    New-Item -ItemType directory -Path $destfolder
}

$source = "https://github.com/ahaydon/Qlik-Cli/archive/master.zip"
Invoke-WebRequest $source -OutFile $destFolder$destFile

$shell = New-Object -ComObject shell.application
$zip = $shell.NameSpace("$destFolder$destFile")
foreach ($item in $zip.items()) {
  $shell.Namespace("$destFolder").CopyHere($item)
}

New-Item -ItemType directory -Path C:\Windows\System32\WindowsPowerShell\v1.0\Modules\Qlik-Cli -force
Copy-Item $destFolder\Qlik-Cli-master\Qlik-Cli.psm1 C:\Windows\System32\WindowsPowerShell\v1.0\Modules\Qlik-Cli\
Import-Module Qlik-Cli.psm1
