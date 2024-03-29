# Disable blinking cursor if running in Windows Terminal
if (Test-Path env:WT_SESSION)
{
	Write-Host -NoNewline "`e[2 q"
}

# Set character encoding to UTF-8 for all commands that support the -Encoding
# parameter. As of PowerShell Core, UTF-8 is the default encoding.
if ($PSVersionTable.PSVersion.Major -le 5)
{
	$PSDefaultParameterValues['*:Encoding'] = 'utf8'
}

$PSDefaultParameterValues += @{
	'Invoke-WebRequest:UseBasicParsing' = $True
}

# Set default editor to open text files with
$Editor = if (Test-Path env:EDITOR) { $env:EDITOR } else { 'notepad' }

# Make Powershell behave similarly to Bash
if ($host.Name -eq 'ConsoleHost') {
	Import-Module PSReadLine

	Set-PSReadLineOption -EditMode Emacs
	Set-PSReadlineOption -BellStyle Visual
	Set-PSReadlineOption -HistorySearchCursorMovesToEnd
	Set-PSReadlineOption -HistoryNoDuplicates
	Set-PSReadlineKeyHandler -Key Tab -Function Complete
}

function private:Source-OptionalFile ([string] $targetFile) {
	if (Test-Path $targetFile) {
		. $targetFile
	}
}

# Import posh-git module
Import-Module posh-git

# Add a trailing new line character to the prompt
$GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n'

# Print the branch name at the start of the prompt, before the current directory
$GitPromptSettings.DefaultPromptWriteStatusFirst = $True

# Show number of stash entries
$GitPromptSettings.EnableStashStatus = $True

# Import ZLocation module to easily jump around within directories
Import-Module ZLocation

# Docker
if (Get-Command docker -ErrorAction SilentlyContinue) {
	Import-Module DockerCompletion
}

# Kubernetes
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
	Set-Alias k -Value kubectl
	kubectl completion powershell | Out-String | Invoke-Expression
}

# Import posh-vcpkg if present
Import-Module "$env:VCPKG_ROOT\scripts\posh-vcpkg" -ErrorAction SilentlyContinue

if ($PSVersionTable.PSVersion.Major -le 5)
{
	Remove-Item Alias:curl -ErrorAction SilentlyContinue
	Remove-Item Alias:wget -ErrorAction SilentlyContinue
}

# Alias common parameters for Remove-Item
function Nuke-Item {
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
	param()
	Remove-Item -Recurse -Force @Args
}

# Create an alias to make it easier to open text files
function Edit-File {
	&"$Editor" @Args
}

# Create an alias to make it easier to open the Powershell configuration
function Edit-PowerShell {
	Edit-File @Args "$($Profile.CurrentUserAllHosts)"
}

# Open Neovim's config file
function Edit-Neovim {
	Edit-File @Args "$env:LOCALAPPDATA\nvim\init.vim"
}

# Edit hosts file
function Edit-Hosts {
	Edit-File @Args $env:SystemRoot\System32\drivers\etc\hosts
}

# Update all pip packages
function Update-PipLocalRepository {
	pip list --outdated --format freeze | ForEach-Object { pip.exe install -U $_.Substring(0, $_.IndexOf('=')) }
}

# Update all Neovim plugins
function Update-NeovimPlugins {
	nvim -c PlugUpgrade -c quitall && nvim -c PlugUpdate -c quitall
}

# Find files by name recursively
function Find-File {
	Get-ChildItem -Force -Recurse -ErrorAction SilentlyContinue @Args
}

# Quickly open all files with conflicts in the editor
function Resolve-MergeConflicts {
	$FilesWithConflicts = (git diff --name-only --diff-filter=U | Get-Unique)

	if ($FilesWithConflicts) {
		&"$Editor" @FilesWithConflicts
	} else {
		Write-Output 'There are currently no files with conflicts.'
	}
}

# Source ripgrep completion file
Source-OptionalFile "$HOME\scoop\apps\ripgrep\current\complete\_rg.ps1"

# Source rustup completions
Source-OptionalFile "$PSScriptRoot\_rustup.ps1"

# Get weather report
function Get-Weather {
	curl.exe 'wttr.in'
}

function Start-DeveloperPowerShell {
	& "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\Common7\Tools\Launch-VsDevShell.ps1"
}
