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

$DefaultVideoSaveLocation = [environment]::GetFolderPath('MyVideos')
$DefaultAudioSaveLocation = [environment]::GetFolderPath('MyMusic')
$DefaultScriptInstallLocation = [environment]::GetFolderPath('UserProfile') + '\scripts\powershell-youtube-dl'
$DefaultPlaylistFileLocation = $DefaultScriptInstallLocation + '\etc\playlist-file.ini'
$DefaultDownloadArchiveFileLocation = $DefaultScriptInstallLocation + '\var\download-archive.ini'

$YoutubeDlOptionsList = @{
    DefaultVideo = "-o ""$DefaultVideoSaveLocation\%(title)s.%(ext)s"" --cache-dir ""$DefaultScriptInstallLocation\var\cache"" --console-title --ignore-errors --no-mtime --no-playlist"
	DefaultAudio = "-o ""$DefaultAudioSaveLocation\%(title)s.%(ext)s"" --cache-dir ""$DefaultScriptInstallLocation\var\cache"" --console-title --ignore-errors --no-mtime --no-playlist -x --audio-format mp3 --audio-quality 0 --metadata-from-title ""(?P<artist>.+?) - (?P<title>.+)"" --add-metadata --prefer-ffmpeg"
    DefaultVideoPlaylist = "-o ""$VideoSaveLocation\%(playlist)s\%(title)s.%(ext)s"" --cache-dir ""$DefaultScriptInstallLocation\var\cache"" --console-title --ignore-errors --no-mtime --yes-playlist"
    DefaultAudioPlaylist = "-o ""$VideoSaveLocation\%(playlist)s\%(title)s.%(ext)s"" --cache-dir ""$DefaultScriptInstallLocation\var\cache"" --console-title --ignore-errors --no-mtime --yes-playlist -x --audio-format mp3 --audio-quality 0 --metadata-from-title ""(?P<artist>.+?) - (?P<title>.+)"" --add-metadata --prefer-ffmpeg"
    DefaultVideoPlaylistFile = "-o ""$VideoSaveLocation\%(playlist)s\%(title)s.%(ext)s"" --cache-dir ""$DefaultScriptInstallLocation\var\cache"" --download-archive ""$DefaultDownloadArchiveFileLocation"" --console-title --ignore-errors --no-mtime --yes-playlist"
    DefaultAudioPlaylistFile = "-o ""$VideoSaveLocation\%(playlist)s\%(title)s.%(ext)s"" --cache-dir ""$DefaultScriptInstallLocation\var\cache"" --download-archive ""$DefaultDownloadArchiveFileLocation"" --console-title --ignore-errors --no-mtime --yes-playlist -x --audio-format mp3 --audio-quality 0 --metadata-from-title ""(?P<artist>.+?) - (?P<title>.+)"" --add-metadata --prefer-ffmpeg"
	Mp4 = ""
    Webm = ""
    Mp3 = ""
}

$DefaultRepositoryBranch = 'version-3.0.0'



# ======================================================================================================= #
# ======================================================================================================= #
# SCRIPT FUNCTIONS
# ======================================================================================================= #

# Display the main menu of the script.
Function Get-MainMenu {
	$MenuOption = $null
	While ($MenuOption -notin @(1, 2, 3, 0)) {
		Clear-Host
		Write-Host "================================================================================"
		Write-Host "                             PowerShell-Youtube-dl" -ForegroundColor "Yellow"
		Write-Host "================================================================================"
		Write-Host "`nPlease select an option:" -ForegroundColor "Yellow"
		Write-Host "  1 - Download video"
		Write-Host "  2 - Download audio"
		Write-Host "  3 - Update executables, uninstall script, etc."
		Write-Host "`n  0 - Exit`n" -ForegroundColor "Gray"
		$MenuOption = Read-Host "Option"
		
		Switch ($MenuOption.Trim()) {
			1 {
				Clear-Host
				Get-DownloadMenu -Type 'video' -Path $DefaultVideoSaveLocation -YoutubeDlOptions $YoutubeDlOptionsList.DefaultVideo
				$MenuOption = $null
			}
			2 {
				Clear-Host
				Get-DownloadMenu -Type 'audio' -Path $DefaultAudioSaveLocation -YoutubeDlOptions $YoutubeDlOptionsList.DefaultAudio
				$MenuOption = $null
			}
			3 {
				Clear-Host
				Wait-Script
				$MenuOption = $null
			}
			0 {
				Clear-Host
				break
			}
			Default {
				Write-Host "`nPlease enter a valid option.`n" -ForegroundColor "Red"
				Wait-Script
			}
		} # End Switch statement
	} # End While loop
} # End Get-MainMenu function



# Display the menu used to download a single video.
Function Get-DownloadMenu {
    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Whether to download video or audio.')]
		[ValidateSet('video','audio')]
        [string]
        $Type,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The URL of the video to download.')]
        [object]
        $Url = 'none',

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The directory to download the video/audio to.')]
        [string]
        $Path = (Get-Location),

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'youtube-dl options to use when downloading the video/audio.')]
        [string]
        $YoutubeDlOptions = $null
    )
	$MenuOption = $null
	$DownloadFunction = "Get-$Type"

	While ($MenuOption -notin @(1, 2, 3, 4, 0)) {
		Clear-Host
		Write-Host "================================================================================"
		Write-Host "                                 Download $Type" -ForegroundColor "Yellow"
		Write-Host "================================================================================"
		Write-Host "`nURL:                $($Url -join "`n                    ")"
		Write-Host "Output path:        $Path"
		Write-Host "youtube-dl options: $YoutubeDlOptions"
		Write-Host "`nPlease select an option:" -ForegroundColor "Yellow"
		Write-Host "  1 - Download $Type"
		Write-Host "  2 - Configure URL"
		Write-Host "  3 - Configure output path"
		Write-Host "  4 - Configure youtube-dl options"
		Write-Host "  5 - Get playlist URLs from file"
		Write-Host "`n  0 - Cancel`n" -ForegroundColor "Gray"
		$MenuOption = Read-Host 'Option'
		
		Switch ($MenuOption.Trim()) {
			1 {
				if ($Url -is [array]) {
					Write-Host ""
					foreach ($Item in $Url) {
						& $DownloadFunction -Url $Item -Path $Path -YoutubeDlOptions $YoutubeDlOptions

						if ($LastExitCode -eq 0) {
							Write-Log -ConsoleOnly -Severity 'Info' -Message "Downloaded $Type successfully."
							Write-Host ""
						} else {
							Write-Host ""
							$MenuOption = $null
							break
						} # End if ($LastExitCode -eq 0) statement
					} # End foreach 
					Wait-Script
				} else {
					Write-Host ""
					& $DownloadFunction -Url $Url -Path $Path -YoutubeDlOptions $YoutubeDlOptions

					if ($LastExitCode -eq 0) {
						Write-Log -ConsoleOnly -Severity 'Info' -Message "Downloaded $Type successfully."
						Write-Host ""
						Wait-Script
						break
					} else {
						Write-Host ""
						Wait-Script
						$MenuOption = $null
					} # End if ($LastExitCode -eq 0) statement
				} # End if ($Url -isnot [string] -and $Url -is [array]) statement
			}
			2 {
				Write-Host ""
				$Url = Read-Host 'URL'
				$MenuOption = $null
			}
			3 {
				Write-Host ""
				$Path = Read-Host 'Output path'
				$MenuOption = $null
			}
			4 {
				Write-Host "`nEnter the name of the youtube-dl options preset or the youtube-dl options themselves ([Enter] to display presets)."
				$DownloadOptions = Read-Host 'youtube-dl options'

				while ($DownloadOptions.Length -eq 0) {
					$YoutubeDlOptionsList | Format-Table
					$DownloadOptions = Read-Host 'youtube-dl options'	
				}

				if ($YoutubeDlOptionsList.ContainsKey($DownloadOptions)) {
					$YoutubeDlOptions = $YoutubeDlOptionsList[$DownloadOptions]
				} else {
					$YoutubeDlOptions = $DownloadOptions
				}
				$MenuOption = $null
			}
			5 {
				Write-Host ""
				$Url = Get-Playlist -Path $DefaultPlaylistFileLocation

				$YoutubeDlOptions = $YoutubeDlOptions -replace '--no-playlist', '--yes-playlist'
				if ($YoutubeDlOptions -notlike '*%(playlist)s\*') {
					$YoutubeDlOptions = $YoutubeDlOptions -replace "\%\(title\)s\.%\(ext\)s""", "%(playlist)s\%(title)s.%(ext)s"""
				}
				if ($YoutubeDlOptions -notlike '*--download-archive*') {
					$YoutubeDlOptions = $YoutubeDlOptions + " --download-archive ""$DefaultDownloadArchiveFileLocation"""
				}
				Write-Host ""
				Wait-Script
				$MenuOption = $null
			}
			0 {
				Clear-Host
				break
			}
			Default {
				Write-Host "`nPlease enter a valid option.`n" -ForegroundColor "Red"
				Wait-Script
			}
		} # End Switch statement
	} # End While loop
} # End Get-DownloadMenu function



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
Write-Log -ConsoleOnly -Severity 'Info' -Message "Script setup complete."
Write-Host ""
Wait-Script

# Display the main menu of the script.
Get-MainMenu

Write-Log -ConsoleOnly -Severity 'Info' -Message "Script complete."

# If the 'youtube-dl' PowerShell module was not imported before running this script, then remove the module.
if ($null -eq $CheckModuleState) { Remove-Module 'youtube-dl' }
