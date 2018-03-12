<#
.SYNOPSIS 
	Download video and audio from the internet, mainly from youtube.com
	
.DESCRIPTION 
	This script downloads audio and video from the internet using the programs youtube-dl and ffmpeg. This script can be ran as a command using parameters, or it can be ran without parameters to use its GUI. Files are downloaded to the user's "Videos" and "Music" folders by default. See README.md for more information.
	
.PARAMETER Video 
	Download the video of the provided URL. Output file formats will vary.
.PARAMETER Audio 
	Download only the audio of the provided URL. Output file format will be mp3.
.PARAMETER FromFiles 
	Download playlist URL's listed in videoplaylists.txt and audioplaylists.txt 
.PARAMETER Convert
	Convert the downloaded video to the default file format using the default settings.
.PARAMETER URL 
	The video URL to download from.
.PARAMETER OutputPath 
	The directory where to save the output file.
.PARAMETER Install
	Install the script to "C:\Users\%USERNAME%\Scripts\Youtube-dl" and create desktop and Start Menu shortcuts.
.PARAMETER UpdateExe
	Update youtube-dl.exe and the ffmpeg files to the most recent versions.
.PARAMETER UpdateScript
	Update the youtube-dl.ps1 script file to the most recent version.

.EXAMPLE 
	C:\Users\%USERNAME%\Scripts\Youtube-dl\scripts\youtube-dl.ps1
	Runs the script in GUI mode.
.EXAMPLE 
	C:\Users\%USERNAME%\Scripts\Youtube-dl\scripts\youtube-dl.ps1 -Video -URL "https://www.youtube.com/watch?v=oHg5SJYRHA0"
	Downloads the video at the specified URL.
.EXAMPLE 
	C:\Users\%USERNAME%\Scripts\Youtube-dl\scripts\youtube-dl.ps1 -Audio -URL "https://www.youtube.com/watch?v=oHg5SJYRHA0"
	Downloads only the audio of the specified video URL.
.EXAMPLE 
	C:\Users\%USERNAME%\Scripts\Youtube-dl\scripts\youtube-dl.ps1 -FromFiles
	Downloads video URL's listed in videoplaylists.txt and audioplaylists.txt files. These files are generated when the script is ran for the first time.
.EXAMPLE 
	C:\Users\%USERNAME%\Scripts\Youtube-dl\scripts\youtube-dl.ps1 -Audio -URL "https://www.youtube.com/watch?v=oHg5SJYRHA0" -OutputPath "C:\Users\%USERNAME%\Desktop"
	Downloads the audio of the specified video URL to the user provided location.
	
.NOTES 
	Requires Windows 7 or higher, PowerShell 5.0 or greater, and Python 2.6, 2.7, or 3.2+
	Author: mpb10
	Updated: March 9th, 2018
	Version: 2.0.2

.LINK 
	https://github.com/mpb10/PowerShell-Youtube-dl
#>


# ======================================================================================================= #
# ======================================================================================================= #

Param(
	[Switch]$Video,
	[Switch]$Audio,
	[Switch]$FromFiles,
	[Switch]$Convert,
	[String]$URL,
	[String]$OutputPath,
	[Switch]$Install,
	[Switch]$UpdateExe,
	[Switch]$UpdateScript
)


# ======================================================================================================= #
# ======================================================================================================= #
#
# SCRIPT SETTINGS
#
# ======================================================================================================= #

$VideoSaveLocation = "$ENV:USERPROFILE\Videos\Youtube-dl"
$AudioSaveLocation = "$ENV:USERPROFILE\Music\Youtube-dl"
$UseArchiveFile = $True
$EntirePlaylist = $False
$VerboseDownloading = $False

$ConvertFile = $False
$FileExtension = "webm"
$VideoBitrate = "-b:v 800k"
$AudioBitrate = "-b:a 128k"
$Resolution = "-s 640x360"
$StartTime = ""
$StopTime = ""
$StripAudio = ""
$StripVideo = ""


# ======================================================================================================= #
# ======================================================================================================= #
#
# FUNCTIONS
#
# ======================================================================================================= #

# Function for simulating the 'pause' command of the Windows command line.
Function PauseScript {
	If ($NumOfParams -eq 0) {
		Write-Host "`nPress any key to continue ...`n" -ForegroundColor "Gray"
		$Wait = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
	}
}



Function DownloadFile {
	Param(
		[String]$URLToDownload,
		[String]$SaveLocation
	)
	(New-Object System.Net.WebClient).DownloadFile("$URLToDownload", "$TempFolder\download.tmp")
	Move-Item -Path "$TempFolder\download.tmp" -Destination "$SaveLocation" -Force
}



Function DownloadYoutube-dl {
	DownloadFile "http://yt-dl.org/downloads/latest/youtube-dl.exe" "$BinFolder\youtube-dl.exe"
}



Function DownloadFfmpeg {
	If (([environment]::Is64BitOperatingSystem) -eq $True) {
		DownloadFile "http://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-3.4.2-win64-static.zip" "$BinFolder\ffmpeg_3.4.2.zip"
	}
	Else {
		DownloadFile "http://ffmpeg.zeranoe.com/builds/win32/static/ffmpeg-3.4.2-win32-static.zip" "$BinFolder\ffmpeg_3.4.2.zip"
	}

	Expand-Archive -Path "$BinFolder\ffmpeg_3.4.2.zip" -DestinationPath "$BinFolder"
	
	Copy-Item -Path "$BinFolder\ffmpeg-3.4.2-win64-static\bin\*" -Destination "$BinFolder" -Recurse -Filter "*.exe" -ErrorAction Silent
	Remove-Item -Path "$BinFolder\ffmpeg_3.4.2.zip"
	Remove-Item -Path "$BinFolder\ffmpeg-3.4.2-win64-static" -Recurse
}



Function ScriptInitialization {
	$Script:BinFolder = $RootFolder + "\bin"
	If ((Test-Path "$BinFolder") -eq $False) {
		New-Item -Type Directory -Path "$BinFolder"
	}
	$ENV:Path += ";$BinFolder"

	$Script:ScriptsFolder = $RootFolder + "\scripts"
	If ((Test-Path "$ScriptsFolder") -eq $False) {
		New-Item -Type Directory -Path "$ScriptsFolder"
	}

	$Script:TempFolder = $RootFolder + "\temp"
	If ((Test-Path "$TempFolder") -eq $False) {
		New-Item -Type Directory -Path "$TempFolder"
	}
	Else {
		Remove-Item -Path "$TempFolder\*" -Recurse -ErrorAction Silent
	}

	$Script:ConfigFolder = $RootFolder + "\config"
	If ((Test-Path "$ConfigFolder") -eq $False) {
		New-Item -Type Directory -Path "$ConfigFolder"
	}

	$Script:ArchiveFile = $ConfigFolder + "\downloadarchive.txt"
	If ((Test-Path "$ArchiveFile") -eq $False) {
		New-Item -Type file -Path "$ArchiveFile"
	}

	$Script:VideoPlaylistFile = $ConfigFolder + "\videoplaylists.txt"
	If ((Test-Path "$VideoPlaylistFile") -eq $False) {
		New-Item -Type file -Path "$VideoPlaylistFile"
	}

	$Script:AudioPlaylistFile = $ConfigFolder + "\audioplaylists.txt"
	If ((Test-Path "$AudioPlaylistFile") -eq $False) {
		New-Item -Type file -Path "$AudioPlaylistFile"
	}
}



Function InstallScript {
	If ($PSScriptRoot -eq "$ENV:USERPROFILE\Scripts\Youtube-dl\scripts") {
		Write-Host "`nPowerShell-Youtube-dl files are already installed."
		PauseScript
		Return
	}
	Else {
		$MenuOption = Read-Host "`nInstall PowerShell-Youtube-dl to ""$ENV:USERPROFILE\Scripts\Youtube-dl""? [y/n]"
		If ($MenuOption -like "y" -or $MenuOption -like "yes") {
			Write-Host "`nInstalling to: ""$ENV:USERPROFILE\Scripts\Youtube-dl"""

			$Script:RootFolder = $ENV:USERPROFILE + "\Scripts\Youtube-dl"

			ScriptInitialization

			$StartFolder = $ENV:APPDATA + "\Microsoft\Windows\Start Menu\Programs\Youtube-dl"
			$DesktopFolder = $ENV:USERPROFILE + "\Desktop"

			DownloadYoutube-dl
			DownloadFfmpeg

			Copy-Item "$PSScriptRoot\youtube-dl.ps1" -Destination "$ScriptsFolder"
			
			DownloadFile "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/install/files/Youtube-dl.lnk" "$RootFolder\Youtube-dl.lnk"
			
			Copy-Item "$RootFolder\Youtube-dl.lnk" -Destination "$DesktopFolder\Youtube-dl.lnk"
			Copy-Item "$RootFolder\Youtube-dl.lnk" -Destination "$StartFolder\Youtube-dl.lnk"
			
			DownloadFile "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/LICENSE" "$RootFolder\LICENSE.txt"
			DownloadFile "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/README.md" "$RootFolder\README.md"

			Write-Host "`nInstallation complete. Please restart the script." -ForegroundColor "Yellow"
			PauseScript
			Exit
		}
		Else {
			Return
		}
	}
}



Function UpdateExe {
	Write-Host "`nUpdating youtube-dl.exe and ffmpeg.exe files ..."
	DownloadYoutube-dl
	DownloadFfmpeg
	Write-Host "`nUpdate .exe files complete." -ForegroundColor "Yellow"
	PauseScript
}



Function UpdateScript {
	DownloadFile "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/install/files/version-file" "$TempFolder\version-file.txt"
	[Version]$NewestVersion = Get-Content "$TempFolder\version-file.txt" | Select -Index 0
	Remove-Item -Path "$TempFolder\*" -Recurse -ErrorAction Silent
	
	If ($NewestVersion -gt $CurrentVersion) {
		Write-Host "`nThe newest version of PowerShell-Youtube-dl is $NewestVersion"
		$MenuOption = Read-Host "`nUpdate the script to this version? [y/n]"
		If ($MenuOption -like "y" -or $MenuOption -like "yes") {
			DownloadFile "http://github.com/mpb10/PowerShell-Youtube-dl/raw/master/scripts/youtube-dl.ps1" "$ScriptsFolder\youtube-dl.ps1"
			Write-Host "`nUpdate script file complete. Please restart the script." -ForegroundColor "Yellow"
			PauseScript
			Exit
		}
		Else {
			Return
		}
	}
	ElseIf ($NewestVersion -eq $CurrentVersion) {
		Write-Host "`nThe running version of PowerShell-Youtube-dl is up to date."
		PauseScript
	}
	Else {
		Write-Host "[ERROR] Version mismatch. Re-installing the script is recommended." -ForegroundColor "Red" -BackgroundColor "Black"
		PauseScript
	}
}



Function SettingsInitialization {
	If ($UseArchiveFile -eq $True) {
		$Script:SetUseArchiveFile = "--download-archive ""$ArchiveFile"""
	}
	Else {
		$Script:SetUseArchiveFile = ""
	}
	
	If ($EntirePlaylist -eq $True) {
		$Script:SetEntirePlaylist = "--yes-playlist"
	}
	Else {
		$Script:SetEntirePlaylist = "--no-playlist"
	}
	
	If ($VerboseDownloading -eq $True) {
		$Script:SetVerboseDownloading = ""
	}
	Else {
		$Script:SetVerboseDownloading = "--quiet --no-warnings"
	}
	
	If ($StripVideo -eq $True) {
		$SetStripVideo = "-vn"
	}
	Else {
		$SetStripVideo = ""
	}
	
	If ($StripAudio -eq $True) {
		$SetStripAudio = "-an"
	}
	Else {
		$SetStripAudio = ""
	}
	
	If ($ConvertFile -eq $True -or $Convert -eq $True) {
		$Script:FfmpegCommand = "--recode-video $FileExtension --postprocessor-args ""$VideoBitrate $AudioBitrate $Resolution $StartTime $StopTime $SetStripVideo $SetStripAudio"" --prefer-ffmpeg"		
	}
	Else {
		$Script:FfmpegCommand = ""
	}
}



Function DownloadVideo {
	Param(
		[String]$URLToDownload
	)
	Write-Host "`nDownloading video from: $URLToDownload`n"
	If ($URLToDownload -like "*youtube.com/playlist*" -or $EntirePlaylist -eq $True) {
		$YoutubedlCommand = "youtube-dl -o ""$VideoSaveLocation\%(playlist)s\%(title)s.%(ext)s"" --ignore-errors --console-title --no-mtime $SetVerboseDownloading $FfmpegCommand --yes-playlist $SetUseArchiveFile ""$URLToDownload"""
		Invoke-Expression "$YoutubedlCommand"
	}
	Else {
		$YoutubedlCommand = "youtube-dl -o ""$VideoSaveLocation\%(title)s.%(ext)s"" --ignore-errors --console-title --no-mtime $SetVerboseDownloading $FfmpegCommand $SetEntirePlaylist ""$URLToDownload"""
		Invoke-Expression "$YoutubedlCommand"
	}
}



Function DownloadAudio {
	Param(
		[String]$URLToDownload
	)
	Write-Host "`nDownloading audio from: $URLToDownload`n"
	If ($URLToDownload -like "*youtube.com/playlist*" -or $EntirePlaylist -eq $True) {
		$YoutubedlCommand = "youtube-dl -o ""$AudioSaveLocation\%(playlist)s\%(title)s.%(ext)s"" --ignore-errors --console-title --no-mtime $SetVerboseDownloading -x --audio-format mp3 --audio-quality 0 --metadata-from-title ""(?P<artist>.+?) - (?P<title>.+)"" --add-metadata --prefer-ffmpeg --yes-playlist $SetUseArchiveFile ""$URLToDownload"""
		Invoke-Expression "$YoutubedlCommand"
	}
	Else {
		$YoutubedlCommand = "youtube-dl -o ""$AudioSaveLocation\%(title)s.%(ext)s"" --ignore-errors --console-title --no-mtime $SetVerboseDownloading -x --audio-format mp3 --audio-quality 0 --metadata-from-title ""(?P<artist>.+?) - (?P<title>.+)"" --add-metadata --prefer-ffmpeg $SetEntirePlaylist ""$URLToDownload"""
		Invoke-Expression "$YoutubedlCommand"
	}
}



Function DownloadPlaylists {
	Write-Host "`nDownloading playlist URLs listed in:`n   $VideoPlaylistFile`n   $AudioPlaylistFile"
	
	Get-Content "$VideoPlaylistFile" | ForEach-Object {
		Write-Verbose "`nDownloading playlist: $_`n"
		DownloadVideo "$_"
	}
	
	Get-Content "$AudioPlaylistFile" | ForEach-Object {
		Write-Verbose "`nDownloading playlist: $_`n"
		DownloadAudio "$_"
	}
}



Function CommandLineMode {
	If ($Install -eq $True) {
		Write-Host "`nInstalling Youtube-dl to: ""$ENV:USERPROFILE\Scripts\Youtube-dl"""
		InstallScript
		Exit
	}
	ElseIf ($UpdateExe -eq $True -and $UpdateScript -eq $True) {
		UpdateExe
		UpdateScript
		Exit
	}
	ElseIf ($UpdateExe -eq $True) {
		UpdateExe
		Exit
	}
	ElseIf ($UpdateScript -eq $True) {
		UpdateScript
		Exit
	}
	
	If (($OutputPath.Length -gt 0) -and ((Test-Path "$OutputPath") -eq $False)) {
		New-Item -Type directory -Path "$OutputPath"
		$Script:VideoSaveLocation = $OutputPath
		$Script:AudioSaveLocation = $OutputPath
	}
	ElseIf ($OutputPath.Length -gt 0) {
		$Script:VideoSaveLocation = $OutputPath
		$Script:AudioSaveLocation = $OutputPath
	}
	
	SettingsInitialization
	
	If ($FromFiles -eq $True -and ($Video -eq $True -or $Audio -eq $True)) {
		Write-Host "`n[ERROR]: The parameter -FromFiles can't be used with -Video or -Audio.`n" -ForegroundColor "Red" -BackgroundColor "Black"
	}
	ElseIf ($FromFiles -eq $True) {
		DownloadPlaylists
		Write-Host "`nDownloads complete. Downloaded to:`n   $VideoSaveLocation`n   $AudioSaveLocation`n" -ForegroundColor "Yellow"
	}
	ElseIf ($Video -eq $True -and $Audio -eq $True) {
		Write-Host "`n[ERROR]: Please select either -Video or -Audio. Not Both.`n" -ForegroundColor "Red" -BackgroundColor "Black"
	}
	ElseIf ($Video -eq $True) {
		DownloadVideo "$URL"
		Write-Host "`nDownload complete.`nDownloaded to: ""$VideoSaveLocation""`n" -ForegroundColor "Yellow"
	}
	ElseIf ($Audio -eq $True) {
		DownloadAudio "$URL"
		Write-Host "`nDownload complete.`nDownloaded to: ""$AudioSaveLocation`n""" -ForegroundColor "Yellow"
	}
	Else {
		Write-Host "`n[ERROR]: Invalid parameters provided." -ForegroundColor "Red" -BackgroundColor "Black"
	}
	
	Exit
}



Function MainMenu {
	$MenuOption = 99
	While ($MenuOption -ne 1 -and $MenuOption -ne 2 -and $MenuOption -ne 3 -and $MenuOption -ne 4 -and $MenuOption -ne 0) {
		$URL = ""
		Clear-Host
		Write-Host "================================================================"
		Write-Host "                  PowerShell-Youtube-dl v2.0.2                  " -ForegroundColor "Yellow"
		Write-Host "================================================================"
		Write-Host "`nPlease select an option:`n" -ForegroundColor "Yellow"
		Write-Host "  1   - Download video"
		Write-Host "  2   - Download audio"
		Write-Host "  3   - Download from playlist files"
		Write-Host "  4   - Settings"
		Write-Host "`n  0   - Exit`n" -ForegroundColor "Gray"
		$MenuOption = Read-Host "Option"
		
		Switch ($MenuOption) {
			1 {
				Write-Host "`nPlease enter the URL you would like to download from:`n" -ForegroundColor "Yellow"
				$URL = (Read-Host "URL").Trim()
				
				If ($URL.Length -gt 0) {
					Clear-Host
					SettingsInitialization
					DownloadVideo $URL
					Write-Host "`nFinished downloading video to: ""$VideoSaveLocation""" -ForegroundColor "Yellow"
					PauseScript
				}
				$MenuOption = 99
			}
			2 {
				Write-Host "`nPlease enter the URL you would like to download from:`n" -ForegroundColor "Yellow"
				$URL = (Read-Host "URL").Trim()
				
				If ($URL.Length -gt 0) {
					Clear-Host
					SettingsInitialization
					DownloadAudio $URL
					Write-Host "`nFinished downloading audio to: ""$AudioSaveLocation""" -ForegroundColor "Yellow"
					PauseScript
				}
				$MenuOption = 99
			}
			3 {
				Clear-Host
				SettingsInitialization
				DownloadPlaylists
				Write-Host "`nFinished downloading URLs from playlist files." -ForegroundColor "Yellow"
				PauseScript
				$MenuOption = 99
			}
			4 {
				Clear-Host
				SettingsMenu
				$MenuOption = 99
			}
			0 {
				Clear-Host
				Exit
			}
			Default {
				Write-Host "`nPlease enter a valid option." -ForegroundColor "Red"
				PauseScript
			}
		}
	}
}



Function SettingsMenu {
	$MenuOption = 99
	While ($MenuOption -ne 1 -and $MenuOption -ne 2 -and $MenuOption -ne 3 -and $MenuOption -ne 0) {
		Clear-Host
		Write-Host "================================================================"
		Write-Host "                         Settings Menu                          " -ForegroundColor "Yellow"
		Write-Host "================================================================"
		Write-Host "`nPlease select an option:`n" -ForegroundColor "Yellow"
		Write-Host "  1   - Update youtube-dl.exe and ffmpeg.exe"
		Write-Host "  2   - Update youtube-dl.ps1 script file"
		If ($PSScriptRoot -ne "$ENV:USERPROFILE\Scripts\Youtube-dl\scripts") {
			Write-Host "  3   - Install script to: ""$ENV:USERPROFILE\Scripts\Youtube-dl"""
		}
		Write-Host "`n  0   - Return to Main Menu`n" -ForegroundColor "Gray"
		$MenuOption = Read-Host "Option"
		
		Switch ($MenuOption) {
			1 {
				UpdateExe
				Exit
				$MenuOption = 99
			}
			2 {
				UpdateScript
				Exit
				$MenuOption = 99
			}
			3 {
				InstallScript
				$MenuOption = 99
			}
			0 {
				Return
			}
			Default {
				Write-Host "`nPlease enter a valid option." -ForegroundColor "Red"
				PauseScript
			}
		}
	}
}



# ======================================================================================================= #
# ======================================================================================================= #


If ($PSVersionTable.PSVersion.Major -lt 5) {
	Write-Host "[ERROR]: Your PowerShell installation is not version 5.0 or greater.`n        This script requires PowerShell version 5.0 or greater to function.`n        You can download PowerShell version 5.0 at:`n            https://www.microsoft.com/en-us/download/details.aspx?id=50395" -ForegroundColor "Red" -BackgroundColor "Black"
	PauseScript
	Exit
}

[Version]$CurrentVersion = '2.0.2'

[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

$NumOfParams = ($PSBoundParameters.Count)

If ($PSScriptRoot -eq "$ENV:USERPROFILE\Scripts\Youtube-dl\scripts") {
	$RootFolder = $ENV:USERPROFILE + "\Scripts\Youtube-dl"
}
Else {
	$RootFolder = "$PSScriptRoot\.."
}

ScriptInitialization

If ((Test-Path "$BinFolder\youtube-dl.exe") -eq $False) {
	Write-Host "`nyoutube-dl.exe not found. Downloading and installing to: ""$BinFolder"" ...`n" -ForegroundColor "Yellow"
	DownloadYoutube-dl
}

If ((Test-Path "$BinFolder\ffmpeg.exe") -eq $False -or (Test-Path "$BinFolder\ffplay.exe") -eq $False -or (Test-Path "$BinFolder\ffprobe.exe") -eq $False) {
	Write-Host "ffmpeg files not found. Downloading and installing to: ""$BinFolder"" ...`n" -ForegroundColor "Yellow"
	DownloadFfmpeg
}


# ======================================================================================================= #
# ======================================================================================================= #

If ($NumOfParams -gt 0) {
	CommandLineMode
}
Else {

	MainMenu
	
	PauseScript
	Exit
}











