# Set character encoding to UTF-8 for all commands that support the -Encoding
# parameter. As of PowerShell Core, UTF-8 is the default encoding.
if ($PSVersionTable.PSVersion.Major -le 5)
{
	$PSDefaultParameterValues['*:Encoding'] = 'utf8'
}

# Set default editor to open text files with
$Editor = if ($env:EDITOR) { $env:EDITOR } else { 'notepad.exe' }

# Make Powershell behave similarly to Bash
if ($host.Name -eq 'ConsoleHost') {
	Import-Module PSReadLine

	Set-PSReadLineOption -EditMode Emacs
	Set-PSReadlineOption -BellStyle Visual
	Set-PSReadlineOption -HistorySearchCursorMovesToEnd
}

function private:Source-OptionalFile ([string] $targetFile) {
	try {
		. "$targetFile"
	} catch [CommandNotFoundException] {
		Write-Host $_.Exception.Message -ForegroundColor Yellow
	}
}

# Import posh-git module
Import-Module posh-git

# Add a trailing new line character to the prompt
$GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n'

# Print the branch name at the start of the prompt, before the current directory
$GitPromptSettings.DefaultPromptWriteStatusFirst = $true

# Import ZLocation module to easily jump around within directories
Import-Module ZLocation

# Import posh-vcpkg if present
Import-Module "$env:VCPKG_ROOT\scripts\posh-vcpkg" -ErrorAction SilentlyContinue

# Aliases
Set-Alias -Name g -Value git.exe
Set-Alias -Name which -Value where.exe

if ($env:VCPKG_ROOT) {
	Set-Alias -Name vcpkg "$env:VCPKG_ROOT\vcpkg.exe"
}

Remove-Item Alias:curl

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

# Update all pip packages
function Update-PipLocalRepository {
	pip.exe list --outdated --format freeze | ForEach-Object { pip.exe install -U $_.Substring(0, $_.IndexOf('=')) }
}

# Find files by name recursively
function Find-File {
	Get-ChildItem -Force -Recurse -ErrorAction SilentlyContinue @Args
}

# Quickly open all files with conflicts in the editor
function Resolve-MergeConflict {
	$FilesWithConflicts = (git.exe diff --name-only --diff-filter=U | Get-Unique)

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
