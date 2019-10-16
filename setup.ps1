# This script will perform the required setup to install the modules
# and it's meant to be run from an elevated prompt
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Confirm

PowerShellGet\Install-Module posh-git -AllowPrerelease
PowerShellGet\Install-Module z
