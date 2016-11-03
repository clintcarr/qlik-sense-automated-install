New-Item -ItemType directory -Path C:\installation\ -force

$source = 'http://go.microsoft.com/fwlink/?LinkId=780600'
$destination = 'c:\installation\ndp462-kb3151800-x86-x64-AllOS-ENU.exe'
Invoke-WebRequest $source -OutFile $destination

Invoke-Command -ScriptBlock {Start-Process -FilePath "C:\installation\ndp462-kb3151800-x86-x64-AllOS-ENU.exe" -ArgumentList "/q" -Wait -PassThru}

$source = 'https://github.com/clintcarr/qlik-sense-automated-install/archive/master.zip'
$destination = 'c:\installation\master.zip'
Invoke-WebRequest $source -OutFile $destination

Expand-Archive C:\installation\master.zip -dest C:\installation\

Write-Host "Changing RunOnce script." 
$RunOnceKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
set-itemproperty $RunOnceKey "NextRun" ('C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe -executionPolicy Unrestricted -File ' + "C:\Installation\qlik-sense-automated-install-master\install-qs-ps5.ps1")

