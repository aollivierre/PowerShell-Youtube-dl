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

$CheckModule = Get-Command -Module 'youtube-dl'
Import-Module -Force ".\youtube-dl.psm1"

Clear-Host

Install-Script -Path $DefaultScriptInstallLocation -Branch $DefaultRepositoryBranch -LocalShortcut -StartMenuShortcut

if ($null -eq $CheckModule) { Remove-Module 'youtube-dl' }

Write-Host "script complete"
