# Set character encoding to UTF-8 for all commands that support the -Encoding
# parameter. As of PowerShell Core, UTF-8 is the default encoding.
if ($PSVersionTable.PSVersion.Major -le 5)
{
	$PSDefaultParameterValues['*:Encoding'] = 'utf8'
}

# Set default editor to open text files with
$Editor = if ($env:EDITOR) { $env:EDITOR } else { 'nvim.exe' }

# Make Powershell behave similarly to Bash
if ($host.Name -eq 'ConsoleHost') {
	Import-Module PSReadLine

	Set-PSReadLineOption -EditMode Emacs
	Set-PSReadlineOption -BellStyle Visual
	Set-PSReadlineOption -HistorySearchCursorMovesToEnd

	Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardKillWord
}

# Import posh-git module
Import-Module posh-git

# Add a trailing new line character to the prompt
$GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n'

# Print the branch name at the start of the prompt, before the current directory
$GitPromptSettings.DefaultPromptWriteStatusFirst = $true

# Import ZLocation module to easily jump around within directories
Import-Module ZLocation

# Import cd-extras module to make cd behave more like a typical Unix shell
Import-Module cd-extras

# Import posh-vcpkg if present
$private:PoshVcpkgLocation = "$env:VCPKG_ROOT\scripts\posh-vcpkg"
if (Test-Path "$PoshVcpkgLocation") {
	Import-Module "$PoshVcpkgLocation"
}

# Aliases
Set-Alias -Name g -Value git.exe

Remove-Item Alias:curl

# Alias common parameters for Remove-Item
function Nuke-Item {
	Remove-Item -Recurse -Force @Args
}

# Create an alias to make it easier to open text files
function Edit-File {
	Invoke-Expression "$Editor $Args"
}

# Create an alias to make it easier to open the Powershell configuration
function PS-Config {
	Edit-File @Args "$($Profile.CurrentUserAllHosts)"
}

# Quickly jump to Neovim's config folder
function Cd-Nvim {
	cd "$env:LOCALAPPDATA\nvim"
}

# Update all pip packages
function Update-PipPackages {
	pip.exe list --outdated --format freeze | ForEach-Object { pip.exe install -U $_.Substring(0, $_.IndexOf('=')) }
}

# Find files by name recursively
function Find-File {
	Get-ChildItem -Force -Recurse -ErrorAction SilentlyContinue @Args
}

# Quickly open all files with conflicts in the editor
function Resolve-Conflicts {
	$FilesWithConflicts = (git.exe diff --name-only --diff-filter=U | Get-Unique)

	if ($FilesWithConflicts) {
		Invoke-Expression "$Editor $FilesWithConflicts"
	} else {
		Write-Output 'There are currently no files with conflicts.'
	}
}

# Source ripgrep completion file
$private:RipgrepCompletionFile = "$HOME\scoop\ripgrep\current\complete\_rg.ps1"
if (Test-Path "$RipgrepCompletionFile") {
	. "$RipgrepCompletionFile"
}

# Get weather report
function Get-Weather {
	curl.exe 'wttr.in'
}
