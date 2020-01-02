# Make Powershell behave similarly to Bash
Import-Module PSReadLine
Set-PSReadLineOption -EditMode Emacs
Set-PSReadlineOption -BellStyle Visual # Silence please...

# Import posh-git module
Import-Module posh-git

# Add a trailing new line character to the prompt
$GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n'

# Print the branch name at the start of the prompt, before the current directory
$GitPromptSettings.DefaultPromptWriteStatusFirst = $true

# Import z module to easily jump around within directories
Import-Module z

# Set character encoding to UTF-8 for all commands that support the -Encoding
# parameter
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# Functions to shorten commands
function nuke([String[]] $Paths) {
    Remove-Item -Recurse -Force -Path $Paths
}

function nukev { nuke -Verbose $args }

# Create an alias to make it easier to open this file
function shconfig {
    param($editor=$env:VISUAL)
    Invoke-Expression "$editor $args $($Profile.CurrentUserAllHosts)"
}

# Check if ripgrep is installed before sourcing its completion database
if (Get-Command rg.exe -ErrorAction SilentlyContinue) { . "$PSScriptRoot\_rg.ps1" }

# Add Rust libaries to the list of path for dynamically linked binaries
$rustToolchains = "$env:RUSTUP_HOME\toolchains"
foreach ($toolchain in Get-ChildItem $rustToolchains) { $env:Path += ";$rustToolchains\$toolchain\bin" }

# Aliases
Set-Alias -Name g -Value git -Description 'Typing git over and over is tedious'
