# Title: Qlik Sense 3.1 Automated Installer
# Author: Clint Carr
# Date: 24 October 2016
# Note: Requires .NET Framework 4.5.2 or higher to use

#----------------------------------
# Variables
#----------------------------------
$serial = ''
$control = ''
$name = ''
$organization = ''
$serviceAccount = 'domain\user'
$serviceAccount2 = 'domain/user'
$serviceAccountPass = '' 
$PostgresAccountPass = ''
$hostname = 'FQDN'

New-Item -ItemType directory -Path C:\installation\qlik-cli -force

$source = "https://da3hntz84uekx.cloudfront.net/QlikSense/3.1.1/1/_MSI/Qlik_Sense_setup.exe"
$destination = "c:\installation\Qlik_Sense_setup.exe"
Invoke-WebRequest $source -OutFile $destination

$source = "https://github.com/ahaydon/Qlik-Cli/archive/master.zip"
$destination = "c:\installation\qlik-cli\qlik-cli.zip"
Invoke-WebRequest $source -OutFile $destination

$shell = New-Object -ComObject shell.application
$zip = $shell.NameSpace("C:\installation\qlik-cli\qlik-cli.zip")
foreach ($item in $zip.items()) {
  $shell.Namespace("c:\installation\qlik-cli").CopyHere($item)
}

New-Item -ItemType directory -Path C:\Windows\System32\WindowsPowerShell\v1.0\Modules\Qlik-Cli -force
Copy-Item C:\Installation\qlik-cli\Qlik-Cli-master\Qlik-Cli.psm1 C:\Windows\System32\WindowsPowerShell\v1.0\Modules\Qlik-Cli\
Import-Module Qlik-Cli.psm1

Write-Host "Adding service account user to local administrators group"
([ADSI]"WinNT://$hostname/administrators,group").psbase.Invoke("Add",([ADSI]"WinNT://$serviceAccount2").path)

Write-Host "Installing Qlik Sense Enterprise"
Invoke-Command -ScriptBlock {Start-Process -FilePath "c:\installation\Qlik_Sense_setup.exe" -ArgumentList "-s dbpassword=$PostgresAccountPass hostname=$hostname userwithdomain=$serviceAccount password=$serviceAccountPass" -Wait -PassThru}

write-host "Wait 60 seconds for Qlik Sense to intialise"
Start-Sleep -s 60

Write-Host "Connecting to Qlik Sense Repository Service"
Connect-Qlik $hostname -UseDefaultCredentials

Write-Host "Setting license"
Set-QlikLicense -serial $serial -control $control -name $name -organization $organization