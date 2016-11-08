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
Note: Does not create the service account, please create within Domain or Local system before running.

## Postgres
Note: If running non-interactively the installation may fail due to Postgres needing to write to a location that doesn't yet exist.  In order to resolve this consider creating an environment variable (PGPASSWORD) with the password of the Super User.  This is commented out in the code. (https://www.postgresql.org/docs/9.3/static/libpq-envars.html)

## Usage
0. Launch Powershell
1. Execute: Set-ExecutionPolicy Unrestricted
2. Execute the following code (line by line or enter into a local PS script and execute):
  New-Item -ItemType directory -Path C:\installation\ -force
  $source = 'https://github.com/clintcarr/qlik-sense-automated-install/archive/master.zip'
  $destination = 'c:\installation\master.zip'
  Invoke-WebRequest $source -OutFile $destination
  Expand-Archive c:\installation\master.zip -dest c:\installation\
3. using Powershell enter c:\installation\qlik-sense-automated-install-master\ 
4. Execute: install-qs.ps1 path to configuration file

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
