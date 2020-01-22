# Set character encoding to UTF-8 for all commands that support the -Encoding
# parameter. As of PowerShell Core, UTF-8 is the default encoding.
if ($PSVersionTable.PSVersion.Major -le 5)
{
	$PSDefaultParameterValues['*:Encoding'] = 'utf8'
}

# Set default editor to open text files with
$Editor = 'emacsclient.exe -n'

# Make Powershell behave similarly to Bash
if ($host.Name -eq 'ConsoleHost')
{
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
Set-Alias -Name g -Value git

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

$private:EmacsServerArtifacts = "$HOME\.emacs.d\server\*"

# Stop the Emacs server
function Stop-Emacs-Server {
	emacsclient.exe --eval '(kill-emacs)'
	Wait-Process emacs -Timeout 8 -ErrorAction Inquire
	Remove-Item -Recurse -Force "$EmacsServerArtifacts"
}

# Start the Emacs server
function Start-Emacs-Server {
	param(
		[Parameter(Position=0)]
		[ValidateNotNullOrEmpty()]
		[String]
		$WorkingDirectory="$HOME"
	)

	if (Get-Process emacs -ErrorAction Continue) {
		Write-Output 'Emacs is already running.'
		return
	}

	Remove-Item -Recurse -Force "$EmacsServerArtifacts"
	emacs.exe --daemon --chdir "$WorkingDirectory"
}

# Restart the Emacs server
function Restart-Emacs-Server {
	Stop-Emacs-Server
	Start-Emacs-Server @Args
}

# Update all pip packages
function Update-PipPackages {
	pip list --outdated --format freeze | ForEach-Object { pip install -U $_.Substring(0, $_.IndexOf('=')) }
}

# Find files by name recursively
function Find-File {
	Get-ChildItem -Force -Recurse -ErrorAction SilentlyContinue @Args
}

# Source ripgrep completion file
$private:RipgrepCompletionFile = "$env:ProgramData\chocolatey\lib\ripgrep\tools\_rg.ps1"
if (Test-Path "$RipgrepCompletionFile") {
	. "$RipgrepCompletionFile"
}
