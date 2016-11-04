# Title: Qlik Sense 3.1 Automated Installer - im Node
# Author: Clint Carr
# Date: 24 October 2016
# Note: Requires .NET Framework 4.5.2 or higher to use

Param(
    [string][ValidateNotNull()]$serviceAccount,
    [string][ValidateNotNull()]$serviceAccount2,
    [string][ValidateNotNull()]$serviceAccountPass,
    [string][ValidateNotNull()]$PostgresAccountPass,
    [string][ValidateNotNull()]$hostname
)

[Environment]::SetEnvironmentVariable("PGPASSWORD", "$PostgresAccountPass", "Machine")

# In a domain DNS handles this
#$hostfile = "c:\Windows\System32\drivers\etc\hosts" 
#"192.168.184.153`t$centralnode" | Out-File $hostfile -encoding ASCII -append 

$date = Get-Date -format "yyyyMMddHHmm"

New-Item -ItemType directory -Path C:\installation\qlik-cli -force
"$date Created path: c:\installation\qlik-cli" | Out-File -filepath C:\installation\qsInstallLog.txt -append
$source = "https://da3hntz84uekx.cloudfront.net/QlikSense/3.1.1/1/_MSI/Qlik_Sense_setup.exe"
$destination = "c:\installation\Qlik_Sense_setup.exe"Invoke-WebRequest $source -OutFile $destination
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
([ADSI]"WinNT://$hostname/administrators,group").psbase.Invoke("Add",([ADSI]"WinNT://$serviceAccount2").path)
"$date Added $serviceAccount2 to local administrators group" | Out-File -filepath C:\installation\qsInstallLog.txt -append

Write-Host "Installing Qlik Sense Enterprise"
Invoke-Command -ScriptBlock {Start-Process -FilePath "c:\installation\Qlik_Sense_setup.exe" -ArgumentList "-s rimnode=1 rimnodetype=ProxyEngine dbpassword=$PostgresAccountPass hostname=$hostname userwithdomain=$serviceAccount password=$serviceAccountPass" -Wait -PassThru}
"$date Installed Qlik Sense 3.1.1" | Out-File -filepath C:\installation\qsInstallLog.txt -append

Write-Host "Opening TCP: 443, 4244, 4444, 4241, 4242"
New-NetFirewallRule -DisplayName "Qlik Sense" -Direction Inbound -LocalPort  443, 4244, 4444, 4241, 4242 -Protocol TCP -Action Allow
"$date Opened TCP 443, 4244, 4444, 4241, 4242" | Out-File -filepath C:\installation\qsInstallLog.txt -append

#Write-Host "Connecting to Qlik Sense Repository Service"
#Connect-Qlik $centralnode
#"$date Connected to $centralnode" | Out-File -filepath C:\installation\qsInstallLog.txt -append

#Register-QlikNode -hostname $hostname -name $hostname -nodePurpose "Production" -engineEnabled -proxyEnabled

[Environment]::SetEnvironmentVariable("PGPASSWORD", "$null", "Machine")
