# qlik-sense-automated-install
Installation of Qlik Sense via Powershell


## Pre-reqs
1. Service Account created (not an admin)
2. Unrestricted Execution Policy
3. Internet Access

## install-qs.ps1
This script installs Qlik Sense 3.1.1 with the following:

1. Qlik Sense 3.1.1 downloaded to local directory
2. Qlik-CLI downloaded to local directory
3. Qlik-CLI installed into PowerShell Modules
4. Service Account added to local administrators group
5. Qlik Sense 3.1.1 installed as a Central Node
6. Qlik Sense licensed

Utilises Qlik-CLI (https://github.com/ahaydon/Qlik-Cli) to perform license step.

## User Account
Note: If you set the config file to createuser = 1 a user will be created.  Local only

## Postgres
Note: If running non-interactively the installation may fail due to Postgres needing to write to a location that doesn't yet exist.  In order to resolve this consider creating an environment variable (PGPASSWORD) with the password of the Super User.  This is commented out in the code. (https://www.postgresql.org/docs/9.3/static/libpq-envars.html)

## Usage
0. Edit the config file C:\installation\qlik-sense-automated-install-master\install-qs-cfg.xml with your config
1. Launch Powershell
2. Execute: Set-ExecutionPolicy Unrestricted
3. Execute the following code (line by line or enter into a local PS script and execute):

  New-Item -ItemType directory -Path C:\installation\ -force
  
  $source = 'https://github.com/clintcarr/qlik-sense-automated-install/archive/master.zip'
  
  $destination = 'c:\installation\master.zip'
  
  Invoke-WebRequest $source -OutFile $destination
  
  Expand-Archive c:\installation\master.zip -dest c:\installation\
  
4. using Powershell enter c:\installation\qlik-sense-automated-install-master\ 
5. Execute: .\install-qs.ps1 path .\install-qs-cfg.xml

### Usage Example
install-qs.ps1 c:\installation\install-qs-cfg.xml

## install-qs-cfg.xml
XML Configuration file for installer

## dl_install_qlikcli.ps1
This script downloads and installs Qlik-CLI.



# Acknowledgements
Adam Haydon (https://github.com/ahaydon/Qlik-Cli)

Leigh Kennedy (Heartbeat of QPS code)

# License

This software is made available "AS IS" without warranty of any kind. Qlik support agreement does not cover support for this script.
