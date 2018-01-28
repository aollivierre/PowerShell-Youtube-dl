<#
.SYNOPSIS 
	Download audio and video from the internet, mainly from youtube.com
	
.DESCRIPTION 
	This script downloads audio and video from the internet using the programs youtube-dl and ffmpeg. This script can be ran as a command using parameters, or it can be ran without parameters to use its GUI. Files are downloaded to the user's "Videos" and "Music" folders by default. See README.md for more information.
	
.PARAMETER Video 
	Download the video of the provided URL. Output file formats will vary.
.PARAMETER Audio 
	Only download the audio of the provided URL. Output file format will be mp3.
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

.EXAMPLE 
	C:\Users\%USERNAME%\Youtube-dl\scripts\youtube-dl.ps1
	Runs the script in GUI mode.
.EXAMPLE 
	C:\Users\%USERNAME%\Youtube-dl\scripts\youtube-dl.ps1 -Video -URL "https://www.youtube.com/watch?v=oHg5SJYRHA0"
	Downloads the video at the specified URL.
.EXAMPLE 
	C:\Users\%USERNAME%\Youtube-dl\scripts\youtube-dl.ps1 -Audio -URL "https://www.youtube.com/watch?v=oHg5SJYRHA0"
	Downloads only the audio of the specified video URL.
.EXAMPLE 
	C:\Users\%USERNAME%\Youtube-dl\scripts\youtube-dl.ps1 -FromFiles
	Downloads video URL's listed in videoplaylists.txt and audioplaylists.txt files. These files are generated when the script is ran for the first time.
.EXAMPLE 
	C:\Users\%USERNAME%\Youtube-dl\scripts\youtube-dl.ps1 -Audio -URL "https://www.youtube.com/watch?v=oHg5SJYRHA0" -OutputPath "C:\Users\%USERNAME%\Desktop"
	Only downloads the audio of the specified video URL to the desktop.
	
.NOTES 
	Requires Windows 7 or higher and PowerShell 5.0 or greater.
	Author: mpb10
	Updated: January 27th, 2018
	Version: 2.0.0

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
	[Switch]$Install
)


# ======================================================================================================= #
# ======================================================================================================= #
#
# SCRIPT SETTINGS
#
# ======================================================================================================= #

$GenerateTextFiles = $True

$MusicSaveLocation = "$ENV:USERPROFILE\Music\Youtube-dl"
$VideoSaveLocatoin = "$ENV:USERPROFILE\Videos\Youtube-dl"
$UseArchiveFile = $True
$DownloadEntirePlaylist = $False

$DefaultFileExtension = "webm"
$DefaultVideoBitrate = "-b:v 800k"
$DefaultAudioBitrate = "-a:v 128k"
$DefaultResolution = "-s 640x360"
$DefaultStartTime = ""
$DefaultStopTime = ""
$DefaultStripAudio = ""
$DefaultStripVideo = ""


# ======================================================================================================= #
# ======================================================================================================= #


# Function for simulating the 'pause' command of the Windows command line.
Function PauseScript {
	If ($PSBoundParameters.Count -eq 0) {
		Write-Host "`nPress any key to continue ...`n" -ForegroundColor "Gray"
		$Wait = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
	}
}


# ======================================================================================================= #
# ======================================================================================================= #


If ($PSVersionTable.PSVersion.Major -lt 5) {
	Write-Host "[NOTE]: Your PowerShell installation is not the most recent version.`n        It's recommended that you have PowerShell version 5 to use this script.`n        You can download PowerShell version 5 at:`n            https://www.microsoft.com/en-us/download/details.aspx?id=50395" -ForegroundColor "Red" -BackgroundColor "Black"
	PauseScript
}
Else {
	Write-Verbose "PowerShell is up to date."
}


# ======================================================================================================= #
# ======================================================================================================= #
	
If ($PSScriptRoot -eq "$ENV:USERPOFILE\Scripts\Youtube-dl\scripts") {
	$RootFolder = $ENV:USERPROFILE + "\Scripts\Youtube-dl"
}
Else {
	$RootFolder = $PSScriptRoot
}

$ArchiveFile = $RootFolder + "\downloadarchive.txt"
If ((Test-Path "$ArchiveFile") -eq $False) {
	New-Item -Type file -Path "$ArchiveFile"
}

$VideoPlaylistFile = $RootFolder + "\videoplaylists.txt"
If ((Test-Path "$VideoPlaylistFile") -eq $False) {
	New-Item -Type file -Path "$VideoPlaylistFile"
}

$AudioPlaylistFile = $RootFolder + "\audioplaylists.txt"
If ((Test-Path "$AudioPlaylistFile") -eq $False) {
	New-Item -Type file -Path "$AudioPlaylistFile"
}

$BinFolder = $RootFolder + "\bin"
$ENV:Path += ";$BinFolder"


# ======================================================================================================= #
# ======================================================================================================= #


If ((Test-Path "$BinFolder\youtube-dl.exe") -eq $False) {
	Write-Host "youtube-dl.exe not found. Downloading and installing to: ""$BinFolder"" ...`n" -ForegroundColor "Yellow"
	DownloadYoutube-dl
}

If ((Test-Path "$BinFolder\ffmpeg.exe") -eq $False -and (Test-Path "$BinFolder\ffplay.exe") -eq $False -and (Test-Path "$BinFolder\ffprobe.exe") -eq $False) {
	Write-Host "ffmpeg files not found. Downloading and installing to: ""$BinFolder"" ...`n" -ForegroundColor "Yellow"
	DownloadFfmpeg
}


# ======================================================================================================= #
# ======================================================================================================= #


If ($PSBoundParameters.Count -gt 0) {
	CommandLineMode
}
Else {
	$BackgroundColorBefore = $HOST.UI.RawUI.BackgroundColor
	$ForegroundColorBefore = $HOST.UI.RawUI.ForegroundColor

	$HOST.UI.RawUI.BackgroundColor = "Black"
	$HOST.UI.RawUI.ForegroundColor = "White"
}


Write-Host "`nTest.`n"
PauseScript







# ======================================================================================================= #
# ======================================================================================================= #
#
# FUNCTIONS
#
# ======================================================================================================= #


Function DownloadYoutube-dl {
	$DownloadURL = "https://yt-dl.org/downloads/latest/youtube-dl.exe"
	$DownloadedFile = $BinFolder + "\youtube-dl.exe"
	(New-Object System.Net.WebClient).DownloadFile($DownloadURL, $DownloadedFile)
}



Function DownloadFfmpeg {
	If (([environment]::Is64BitOperatingSystem) -eq $True) {
		$DownloadURL = "http://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-3.4.1-win64-static.zip"
	}
	Else {
		$DownloadURL = "http://ffmpeg.zeranoe.com/builds/win32/static/ffmpeg-3.4.1-win32-static.zip"
	}
	$DownloadedFile = $RootFolder + "\ffmpeg_3.4.1.zip"
	(New-Object System.Net.WebClient).DownloadFile($DownloadURL, $DownloadedFile)

	If ($PSVersionTable.PSVersion.Major -ge 5) {
		Expand-Archive -Path "$DownloadedFile" -DestinationPath "$RootFolder"
	}
	Else {
		[System.IO.Compression.ZipFile]::ExtractToDirectory($DownloadedFile, $RootFolder)
	}

	$ffmpegBinFolder = $RootFolder + "\ffmpeg-3.4.1-win64-static\bin\*"
	$ffmpegExtractedFolder = $RootFolder + "\ffmpeg-3.4.1-win64-static"
	Copy-Item -Path "$ffmpegBinFolder" -Destination "$BinFolder" -Recurse -Filter "*.exe"
	Remove-Item -Path "$DownloadedFile"
	Remove-Item -Path "$ffmpegExtractedFolder" -Recurse 
}



Function InstallScript {
	$Script:RootFolder = $ENV:USERPROFILE + "\Scripts\Youtube-dl"
	New-Item -Type Directory -Path "$RootFolder"
	
	$Script:ArchiveFile = $RootFolder + "\downloadarchive.txt"
	New-Item -Type file -Path "$ArchiveFile"

	$Script:VideoPlaylistFile = $RootFolder + "\videoplaylists.txt"
	New-Item -Type file -Path "$VideoPlaylistFile"

	$Script:AudioPlaylistFile = $RootFolder + "\audioplaylists.txt"
	New-Item -Type file -Path "$AudioPlaylistFile"
	
	$Script:BinFolder = $RootFolder + "\bin"
	New-Item -Type Directory -Path "$BinFolder"
	$ENV:Path += ";$BinFolder"
	
	$ScriptsFolder = $RootFolder + "\scripts"
	New-Item -Type Directory -Path "$ScriptsFolder"
	
	$StartFolder = $ENV:APPDATA + "\Microsoft\Windows\Start Menu\Programs\Youtube-dl"
	New-Item -Type Directory -Path "$StartFolder"

    $DesktopFolder = $ENV:USERPROFILE + "\Desktop"
	
	DownloadYoutube-dl
	
	DownloadFfmpeg
	
	Copy-Item "$PSScriptRoot\youtube-dl.ps1" -Destination "$ScriptsFolder"
	Copy-Item "$PSScriptRoot\..\install\files\Youtube-dl.lnk" -Destination "$RootFolder"
	Copy-Item "$PSScriptRoot\..\install\files\Youtube-dl.lnk" -Destination "$DesktopFolder"
    Copy-Item "$PSScriptRoot\..\install\files\Youtube-dl.lnk" -Destination "$StartFolder"
	Copy-Item "$PSScriptRoot\..\LICENSE" -Destination "$RootFolder"
	Copy-Item "$PSScriptRoot\..\README.md" -Destination "$RootFolder"

    Write-Host "`nInstallation complete. Please Restart the script.`n" -ForegroundColor "Yellow"
    PauseScript
}



Function CommandLineMode {
	If ($Install -eq $True) {
		Write-Host "`nInstalling Youtube-dl to: ""$ENV:USERPOFILE\Scripts\Youtube-dl""`n"
		InstallScript
		Exit
	}
	
	If (($OutputPath.Length -gt 0) -and ((Test-Path "$OutputPath") -eq $False)) {
		New-Item -Type directory -Path "$OutputPath"
		$VideoSaveLocation = $OutputPath
		$MusicSaveLocation = $OutputPath
	}
	ElseIf ($OutputPath.Length -gt 0) {
		$VideoSaveLocation = $OutputPath
		$MusicSaveLocation = $OutputPath
	}
	
	If ($FromFiles -eq $True -and $Video -eq $False -and $Audio -eq $False) {
		DownloadPlaylists
		Write-Host "`nDownloads complete.`nDownloaded to: ""$VideoSaveLocation"" and ""$MusicSaveLocation""`n" -ForegroundColor "Yellow"
	}
	ElseIf ($FromFiles -eq $True -and ($Video -eq $True -or $Audio -eq $True)) {
		Write-Host "`n[ERROR]: The parameter -FromFiles can't be used with -Video or -Audio.`n" -ForegroundColor "Red" -BackgroundColor "Black"
	}
	ElseIf ($Video -eq $True -and $Audio -eq $False) {
		DownloadVideo $URL
		Write-Host "`nDownload complete.`nDownloaded to: ""$VideoSaveLocation""`n" -ForegroundColor "Yellow"
	}
	ElseIf ($Audio -eq $True -and $Video -eq $False) {
		DownloadAudio $URL
		Write-Host "`nDownload complete.`nDownloaded to: ""$MusicSaveLocation`n""" -ForegroundColor "Yellow"
	}
	ElseIf ($Video -eq $True -and $Audio -eq $True) {
		Write-Host "`n[ERROR]: Please select either -Video or -Audio. Not Both.`n" -ForegroundColor "Red" -BackgroundColor "Black"
	}
	Else {
		Write-Host "`n[ERROR]: Invalid parameters provided." -ForegroundColor "Red" -BackgroundColor "Black"
	}
	
	Exit
}
















