# Title: Qlik Sense 3.1 Automated Installer
# Author: Clint Carr
# Date: 8 November 2016
# Note: Requires .NET Framework 4.5.2 or higher to use

param(
    [Parameter(Mandatory=$True, HelpMessage="Enter the full path to the configuration file.")] [string]$ConfigFilePath=".\install-qs-cfg.xml"
)

If(-not(Test-Path $ConfigFilePath)){
    Write-Error "Could not find script configuration file at $($ConfigFilePath)." -ErrorAction Stop
}
 
[xml]$ConfigXML = Get-Content $ConfigFilePath

$serial = $ConfigXML.config.serial
$control = $ConfigXML.config.control
$name = $ConfigXML.config.name
$organization = $ConfigXML.config.organization
$serviceAccount = $ConfigXML.config.serviceAccount
$PostgresAccountPass = $ConfigXML.config.PostgresAccountPass
$serviceAccountPass = $ConfigXML.config.serviceAccountPass
$hostname = $ConfigXML.config.hostname
$singleserver = $ConfigXML.config.singleserver

[Environment]::SetEnvironmentVariable("PGPASSWORD", "$PostgresAccountPass", "Machine")
#if ((Get-WmiObject win32_computersystem).Domain -eq 'WORKGROUP')
#{
#$hostname = (Get-WmiObject win32_computersystem).DNSHostName
#}

#else
#{
#$hostname = (Get-WmiObject win32_computersystem).DNSHostName+"."+(Get-WmiObject win32_computersystem).Domain
#}
$date = Get-Date -format "yyyyMMddHHmm"

New-Item -ItemType directory -Path C:\installation\qlik-cli -force
"$date Created path: c:\installation\qlik-cli" | Out-File -filepath C:\installation\qsInstallLog.txt -append
$source = "https://da3hntz84uekx.cloudfront.net/QlikSense/3.1.1/1/_MSI/Qlik_Sense_setup.exe"
$destination = "c:\installation\Qlik_Sense_setup.exe"
Invoke-WebRequest $source -OutFile $destination
"$date Downloaded Qlik_Sense_setup.exe" | Out-File -filepath C:\installation\qsInstallLog.txt -append

$source = "https://github.com/ahaydon/Qlik-Cli/archive/master.zip"
$destination = "c:\installation\qlik-cli\qlik-cli.zip"
Invoke-WebRequest $source -OutFile $destination
"$date Downloaded qlik-cli.zip" | Out-File -filepath C:\installation\qsInstallLog.txt -append

if ($PSVersionTable.PSVersion.Major -ge 5)
{
  Expand-Archive C:\installation\qlik-cli\qlik-cli.zip -dest C:\installation\qlik-cli
}
else
{
  $shell = New-Object -ComObject shell.application
  $zip = $shell.NameSpace("C:\installation\qlik-cli\qlik-cli.zip")
  foreach ($item in $zip.items()) {
    $shell.Namespace("c:\installation\qlik-cli").CopyHere($item)
}
}

"$date Unzipped qlik-cli" | Out-File -filepath C:\installation\qsInstallLog.txt -append

New-Item -ItemType directory -Path C:\Windows\System32\WindowsPowerShell\v1.0\Modules\Qlik-Cli -force
Copy-Item C:\Installation\qlik-cli\Qlik-Cli-master\Qlik-Cli.psm1 C:\Windows\System32\WindowsPowerShell\v1.0\Modules\Qlik-Cli\
Import-Module Qlik-Cli.psm1
"$date Imported qlik-cli to PowerShell Modules" | Out-File -filepath C:\installation\qsInstallLog.txt -append

Write-Host "Adding service account user to local administrators group"
([ADSI]"WinNT://$hostname/administrators,group").psbase.Invoke("Add",([ADSI]"WinNT://$hostname/$serviceAccount").path)
"$date Added $hostname\$serviceAccount to local administrators group" | Out-File -filepath C:\installation\qsInstallLog.txt -append

Write-Host "Installing Qlik Sense Enterprise"
Invoke-Command -ScriptBlock {Start-Process -FilePath "c:\installation\Qlik_Sense_setup.exe" -ArgumentList "-s dbpassword=$PostgresAccountPass hostname=$hostname userwithdomain=$hostname\$serviceAccount password=$serviceAccountPass" -Wait -PassThru}
"$date Installed Qlik Sense 3.1.1" | Out-File -filepath C:\installation\qsInstallLog.txt -append

if ($singleserver -eq 1)
{
  Write-Host "Opening TCP: 443, 4244"
  New-NetFirewallRule -DisplayName "Qlik Sense" -Direction Inbound -LocalPort 443, 4244 -Protocol TCP -Action Allow
  "$date Opened TCP 443, 4244" | Out-File -filepath C:\installation\qsInstallLog.txt -appen
}
else
{
  Write-Host "Opening TCP: 443, 4244, 4899, 4241, 4242, 4900"
  New-NetFirewallRule -DisplayName "Qlik Sense" -Direction Inbound -LocalPort 443, 4244, 4899, 4241, 4242, 4900 -Protocol TCP -Action Allow
  "$date Opened TCP 443, 4244, 4899, 4241, 4242, 4900" | Out-File -filepath C:\installation\qsInstallLog.txt -append
}


write-host "Connecting to Qlik Sense Proxy"
$statusCode = 0
while ($StatusCode -ne 200) {
  write-host "StatusCode is " $StatusCode
  start-Sleep -s 5
  try { $statusCode = (invoke-webrequest  https://$hostname/qps/user -usebasicParsing).statusCode }
Catch { 
    write-host "Server down, waiting 5 seconds"
    start-Sleep -s 5
    }
}

Write-Host "Connecting to Qlik Sense Repository Service"
Connect-Qlik $hostname -UseDefaultCredentials
"$date Connected to $hostname" | Out-File -filepath C:\installation\qsInstallLog.txt -append

Write-Host "Setting license"
Set-QlikLicense -serial $serial -control $control -name $name -organization $organization
"$date Written license: $serial" | Out-File -filepath C:\installation\qsInstallLog.txt -append

[Environment]::SetEnvironmentVariable("PGPASSWORD", "$null", "Machine")
