# Set character encoding to UTF-8 for all commands that support the -Encoding
# parameter
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

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

# Import ZLocation module to easily jump around within directories
Import-Module ZLocation

# Aliases
Remove-Item alias:\cd -ErrorAction SilentlyContinue
Set-Alias -Name g -Value git -Description 'Typing git over and over is tedious'

# cd by itself goes back to $HOME, otherwise uses z
function cd {
	if ($Args.Count -eq 0) {
		Set-Location $HOME
	} else {
		Invoke-ZLocation @Args
	}
}

# Alias common parameters for Remove-Item
function Nuke-Item {
	Remove-Item -Recurse -Force @Args
}

# Create an alias to make it easier to open text files
function Edit-File {
	param(
		[Parameter(Mandatory=$True, Position=0)]
		[ValidateNotNullOrEmpty()]
		[String]
		$File,

		[ValidateNotNullOrEmpty()]
		[String]
		$Editor=$env:VISUAL,

		[String[]]
		$EditorArgs
	)

	Invoke-Expression "$Editor $EditorArgs $File"
}

# Create an alias to make it easier to open the Powershell configuration
function PS-Config {
	param(
		[String[]]
		$EditorArgs
	)

	Edit-File "$($Profile.CurrentUserAllHosts)" -EditorArgs "$EditorArgs"
}

# Stop the Emacs server
function Stop-Emacs-Server {
	while (Get-Process emacs -ErrorAction SilentlyContinue) {
		emacsclient.exe --eval '(kill-emacs)'
		Start-Sleep -Milliseconds 1024
	}
}

# Start the Emacs server
function Start-Emacs-Server {
	param(
		[Parameter(Position=0)]
		[ValidateNotNullOrEmpty()]
		[String]
		$WorkingDirectory="$HOME"
	)

	if (Get-Process emacs -ErrorAction SilentlyContinue) {
		echo 'Emacs is already running.'
		return
	}
	Remove-Item -Recurse -Force "$HOME\.emacs.d\server\*"
	runemacs.exe --daemon --chdir "$WorkingDirectory"
}

# Restart the Emacs server
function Restart-Emacs-Server {
	Stop-Emacs-Server
	Start-Emacs-Server
}

# Update all pip packages
function Pip-Update-All {
	pip list --outdated --format freeze | ForEach-Object { pip install -U $_.Substring(0, $_.IndexOf('=')) }
}

# Find files by name recursively
function Find-File {
	Get-ChildItem -Recurse -ErrorAction SilentlyContinue -Include @Args
}

# Source ripgrep completion file
$private:ripgrepCompletionFile = "$env:ProgramData\chocolatey\lib\ripgrep\tools\_rg.ps1"
if (Test-Path "$ripgrepCompletionFile") {
	. "$ripgrepCompletionFile"
}
