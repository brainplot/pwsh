# Helper script to install all my PowerShell modules

Install-Module PowerShellGet -Scope CurrentUser -Force -AllowClobber

PowerShellGet\Install-Module posh-git -Scope CurrentUser -AllowPrerelease -Force
PowerShellGet\Install-Module ZLocation -Scope CurrentUser -AllowPrerelease -Force
PowerShellGet\Install-Module cd-extras -Scope CurrentUser -AllowPrerelease -Force
