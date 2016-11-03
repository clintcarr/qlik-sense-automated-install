New-Item -ItemType directory -Path C:\installation\ -force

write-host "Enter password for Service Account: "
$Password = Read-Host -AsSecureString
New-LocalUser "Qservice" -Password $Password -FullName "Qlik Service Account"

$source = 'http://go.microsoft.com/fwlink/?LinkId=780600'
$destination = 'c:\installation\ndp462-kb3151800-x86-x64-AllOS-ENU.exe'
Invoke-WebRequest $source -OutFile $destination

Invoke-Command -ScriptBlock {Start-Process -FilePath "C:\installation\ndp462-kb3151800-x86-x64-AllOS-ENU.exe" -ArgumentList "/q" -Wait -PassThru}

shutdown -t 0 -r -f
