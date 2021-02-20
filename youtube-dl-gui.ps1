<#
.SYNOPSIS 
	Downloads video and audio using the 'youtube-dl' application.
	
.DESCRIPTION 
	This script downloads audio and video from the internet using the programs 'youtube-dl' and 'ffmpeg'. See README.md for more information.

.EXAMPLE 
	C:\Users\%USERNAME%\Scripts\Youtube-dl\youtube-dl-gui.ps1
	Runs the script.
	
.NOTES 
	Requires Windows 7 or higher, PowerShell 5.0 or greater, and Microsoft Visual C++ 2010 Redistributable Package (x86).
	Author: mpb10
	Updated: February 18th, 2021
	Version: 2.1.0

.LINK 
	https://github.com/mpb10/PowerShell-Youtube-dl
#>

# ======================================================================================================= #
# ======================================================================================================= #
# SCRIPT SETTINGS
# ======================================================================================================= #

$YoutubeDlOptionsList = [ordered]@{
    DefaultVideo = ""
    Mp4 = ""
    Webm = ""
    Mp3 = ""
}

$DefaultVideoSaveLocation = [environment]::GetFolderPath('MyVideos')
$DefaultAudioSaveLocation = [environment]::GetFolderPath('MyMusic')
$DefaultScriptInstallLocation = [environment]::GetFolderPath('UserProfile') + "\scripts\powershell-youtube-dl"

$DefaultRepositoryBranch = 'version-2.1.0'

# ======================================================================================================= #
# ======================================================================================================= #
# SCRIPT FUNCTIONS
# ======================================================================================================= #


# ======================================================================================================= #
# ======================================================================================================= #
# MAIN FUNCTION
# ======================================================================================================= #

# Save whether the 'youtube-dl' PowerShell module was already imported or not.
$CheckModuleState = Get-Command -Module 'youtube-dl'

# Import the 'youtube-dl.psm1' PowerShell module.
if (Test-Path -Path "$PSScriptRoot\youtube-dl.psm1") {
	Import-Module -Force "$PSScriptRoot\youtube-dl.psm1"
} elseif (Test-Path -Path "$(Get-Location)\youtube-dl.psm1") {
	Import-Module -Force "$(Get-Location)\youtube-dl.psm1"
} elseif (Test-Path -Path "$DefaultScriptInstallLocation\bin\youtube-dl.psm1") {
	Import-Module -Force "$DefaultScriptInstallLocation\bin\youtube-dl.psm1"
} else {
	return Write-Log -ConsoleOnly -Severity 'Error' -Message "Failed to find and import the 'youtube-dl.psm1' PowerShell module."
}

# Install the script, executables, and shortcuts.
Install-Script -Path $DefaultScriptInstallLocation -Branch $DefaultRepositoryBranch -LocalShortcut -StartMenuShortcut

# If the 'youtube-dl' PowerShell module was not imported before running this script, then remove the module.
if ($null -eq $CheckModuleState) { Remove-Module 'youtube-dl' }

Write-Host "script complete"

Wait-Script
