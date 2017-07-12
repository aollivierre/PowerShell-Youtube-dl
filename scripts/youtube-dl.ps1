### Check if having extra spaces in youtube-dl command causes an error
### check line 648 resolution variable. Running the script a second time might cause an error because missing -s

<#PSScriptInfo 

.VERSION
	1.2.4 

.GUID  

.AUTHOR
	ForestFrog

.COMPANYNAME 

.COPYRIGHT 

.TAGS 

.LICENSEURI
	https://github.com/ForestFrog/PowerShell-Youtube-dl/blob/master/LICENSE

.PROJECTURI
	https://github.com/ForestFrog/PowerShell-Youtube-dl

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 
	https://rg3.github.io/youtube-dl/
	https://ffmpeg.org/

.RELEASENOTES
	1.2.4	12-Jul-2017 - Added ability to choose whether to use the youtube-dl download archive when downloading playlists.
	1.2.3	11-Jul-2017 - Edited Youtube-dl_Installer.ps1 to uninstall the script using the -Uninstall parameter. Added a shortcut for uninstalling the script and its files.
	1.2.2	03-Jul-2017 - Cleaned up code.
	1.2.1	22-Jun-2017 - Uploaded project to Github. Condensed installer to one PowerShell script. Edited documentation.
	1.2.0	30-May-2017 - Implemented ffmpeg video conversion.
	1.1.0	27-May-2017 - Implemented videoplaylist.txt and audioplaylist.txt downloading.
#>

<#
.SYNOPSIS 
	Download audio and video from the internet, mainly from youtube.com
.DESCRIPTION 
	This script downloads audio and video from the internet using the programs youtube-dl and ffmpeg. This script can be ran as a command using parameters or it can be ran without parameters to use its GUI. Files are downloaded to the user's "Videos" and "Music" folders by default. See README.md for more information.
.PARAMETER Video 
	Download the video of the provided URL. Output file formats will vary.
.PARAMETER Audio 
	Only download the audio of the provided URL. Output file format will be mp3.
.PARAMETER FromFiles 
	Download playlist URL's listed in videoplaylists.txt and audioplaylists.txt 
.PARAMETER URL 
	The video URL to download from.
.PARAMETER OutputPath 
	The directory where to save the output file.

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
	Requires Windows 7 or higher 
	Author: ForestFrog
	Updated: July 12th, 2017 

.LINK 
	https://github.com/ForestFrog/PowerShell-Youtube-dl
#>



Param(
	[Switch]$Video,
	[Switch]$Audio,
	[Switch]$FromFiles,
	[String]$URL,
	[String]$OutputPath
)



If ($PSBoundParameters.Count -gt 0) {
	$ParameterMode = $True
}
Else {
	$ParameterMode = $False
	
	$BackgroundColorBefore = $HOST.UI.RawUI.BackgroundColor
	$ForegroundColorBefore = $HOST.UI.RawUI.ForegroundColor

	$HOST.UI.RawUI.BackgroundColor = "Black"
	$HOST.UI.RawUI.ForegroundColor = "White"
}

Function PauseScript {
	If ($PSBoundParameters.Count -eq 0) {
		Write-Host "Press any key to continue ...`n" -ForegroundColor "Gray"
		$Wait = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
	}
}

$SettingsFolder = $ENV:USERPROFILE + "\Youtube-dl"

$BinFolder = $SettingsFolder + "\bin"
$ENV:Path += ";$BinFolder"

$ArchiveFile = $SettingsFolder + "\downloadarchive.txt"
If ((Test-Path "$ArchiveFile") -eq $False) {
	New-Item -Type file -Path "$ArchiveFile"
}

$VideoPlaylistFile = $SettingsFolder + "\videoplaylists.txt"
If ((Test-Path "$VideoPlaylistFile") -eq $False) {
	New-Item -Type file -Path "$VideoPlaylistFile"
}

$AudioPlaylistFile = $SettingsFolder + "\audioplaylists.txt"
If ((Test-Path "$AudioPlaylistFile") -eq $False) {
	New-Item -Type file -Path "$AudioPlaylistFile"
}

$YoutubeMusicFolder = $ENV:USERPROFILE + "\Music\Youtube-dl"
If ((Test-Path "$YoutubeMusicFolder") -eq $False) {
	New-Item -Type directory -Path "$YoutubeMusicFolder"
}

$YoutubeVideoFolder = $ENV:USERPROFILE + "\Videos\Youtube-dl"
If ((Test-Path "$YoutubeVideoFolder") -eq $False) {
	New-Item -Type directory -Path "$YoutubeVideoFolder"
}


If ($ParameterMode -eq $False) {
	$ffmpegConversion = ""

	$ConvertOutputDefault = $False
	$ConvertOutputValue = $False
	$ConvertOutput = New-Object Object
	$ConvertOutput | Add-Member -MemberType NoteProperty -Name ID -Value 1
	$ConvertOutput | Add-Member -MemberType NoteProperty -Name SettingName -Value "Convert output?"
	$ConvertOutput | Add-Member -MemberType NoteProperty -Name SettingValue -Value $ConvertOutputDefault

	$OriginalQualityDefault = $True
	$OriginalQualityValue = $True
	$OriginalQuality = New-Object Object
	$OriginalQuality | Add-Member -MemberType NoteProperty -Name ID -Value 2
	$OriginalQuality | Add-Member -MemberType NoteProperty -Name SettingName -Value "Keep original quality?"
	$OriginalQuality | Add-Member -MemberType NoteProperty -Name SettingValue -Value $OriginalQualityDefault

	$BlankLine = New-Object Object
	$BlankLine | Add-Member -MemberType NoteProperty -Name ID -Value ""
	$BlankLine | Add-Member -MemberType NoteProperty -Name SettingName -Value ""
	$BlankLine | Add-Member -MemberType NoteProperty -Name SettingValue -Value ""

	$OutputFileTypeDefault = "webm"
	$OutputFileTypeValue = "--recode-video webm"
	$OutputFileType = New-Object Object
	$OutputFileType | Add-Member -MemberType NoteProperty -Name ID -Value 3
	$OutputFileType | Add-Member -MemberType NoteProperty -Name SettingName -Value "Output file extension"
	$OutputFileType | Add-Member -MemberType NoteProperty -Name SettingValue -Value $OutputFileTypeDefault

	$VideoBitRateDefault = "800k"
	$VideoBitRateValue = " -b:v 800k"
	$VideoBitRate = New-Object Object
	$VideoBitRate | Add-Member -MemberType NoteProperty -Name ID -Value 4
	$VideoBitRate | Add-Member -MemberType NoteProperty -Name SettingName -Value "Video bitrate"
	$VideoBitRate | Add-Member -MemberType NoteProperty -Name SettingValue -Value $VideoBitRateDefault #In kilobytes

	$AudioBitRateDefault = "128k"
	$AudioBitRateValue = " -b:a 128k"
	$AudioBitRate = New-Object Object
	$AudioBitRate | Add-Member -MemberType NoteProperty -Name ID -Value 5
	$AudioBitRate | Add-Member -MemberType NoteProperty -Name SettingName -Value "Audio bitrate"
	$AudioBitRate | Add-Member -MemberType NoteProperty -Name SettingValue -Value $AudioBitRateDefault #In kilobytes

	$ResolutionDefault = "640x360"
	$ResolutionValue = " -s 640x360"
	$Resolution = New-Object Object
	$Resolution | Add-Member -MemberType NoteProperty -Name ID -Value 6
	$Resolution | Add-Member -MemberType NoteProperty -Name SettingName -Value "Resolution"
	$Resolution | Add-Member -MemberType NoteProperty -Name SettingValue -Value $ResolutionDefault #360p = 480:360, 480p = 640:480, 720p = 1280:720, 1080p = 1920:1080

	$StartTimeDefault = "00:00:00"
	$StartTimeValue = ""
	$StartTime = New-Object Object
	$StartTime | Add-Member -MemberType NoteProperty -Name ID -Value 7
	$StartTime | Add-Member -MemberType NoteProperty -Name SettingName -Value "Start time"
	$StartTime | Add-Member -MemberType NoteProperty -Name SettingValue -Value $StartTimeDefault #format as 00:00:00

	$StopTimeDefault = "No stop time"
	$StopTimeValue = ""
	$StopTime = New-Object Object
	$StopTime | Add-Member -MemberType NoteProperty -Name ID -Value 8
	$StopTime | Add-Member -MemberType NoteProperty -Name SettingName -Value "Stop time"
	$StopTime | Add-Member -MemberType NoteProperty -Name SettingValue -Value $StopTimeDefault #In seconds

	$StripAudioDefault = $False
	$StripAudioValue = ""
	$StripAudio = New-Object Object
	$StripAudio | Add-Member -MemberType NoteProperty -Name ID -Value 9
	$StripAudio | Add-Member -MemberType NoteProperty -Name SettingName -Value "Strip audio?"
	$StripAudio | Add-Member -MemberType NoteProperty -Name SettingValue -Value $StripAudioDefault

	$StripVideoDefault = $False
	$StripVideoValue = ""
	$StripVideo = New-Object Object
	$StripVideo | Add-Member -MemberType NoteProperty -Name ID -Value 10
	$StripVideo | Add-Member -MemberType NoteProperty -Name SettingName -Value "Strip video?"
	$StripVideo | Add-Member -MemberType NoteProperty -Name SettingValue -Value $StripVideoDefault
	
	$UseArchiveDefault = $True
	$UseArchiveValue = "--download-archive $ArchiveFile"
	$UseArchive = New-Object Object
	$UseArchive | Add-Member -MemberType NoteProperty -Name ID -Value 11
	$UseArchive | Add-Member -MemberType NoteProperty -Name SettingName -Value "Use archive file?"
	$UseArchive | Add-Member -MemberType NoteProperty -Name SettingValue -Value $UseArchiveDefault
	
	$Settings = $ConvertOutput,$OriginalQuality,$BlankLine,$OutputFileType,$VideoBitRate,$AudioBitRate,$Resolution,$StartTime,$StopTime,$StripAudio,$StripVideo,$BlankLine,$UseArchive
}


# In MainMenu, ask for audio or video, get url, then run either DownloadUrlAudio or DownloadUrlVideo.
Function MainMenu {
	$MenuOption = 99
	While ($MenuOption -ne 1 -and $MenuOption -ne 2 -and $MenuOption -ne 3 -and $MenuOption -ne 4 -and $MenuOption -ne 0) {
		Clear-Host
		Write-Host "================================================================" -BackgroundColor "Black"
		Write-Host "                Youtube-dl Download Script v1.2.4               " -ForegroundColor "Yellow" -BackgroundColor "Black"
		Write-Host "================================================================" -BackgroundColor "Black"
		Write-Host "`nPlease select an option:`n" -ForegroundColor "Yellow"
		Write-Host "  1   - Download video"
		Write-Host "  2   - Download audio"
		Write-Host "  3   - Download predefined playlists"
		Write-Host "  4   - Settings"
		Write-Host "`n  0   - Exit`n" -ForegroundColor "Gray"
		$MenuOption = Read-Host "Option"
		
		If ($MenuOption -eq 1) {			
			$url = ""
			While (! ($url -like "http*")) {
				Clear-Host
				Write-Host "Please enter the URL you would like to download from:`n" -ForegroundColor "Yellow"
				$url = Read-Host "URL"
				If ($url -like "http*") {
					DownloadUrlVideo $url
				}
				ElseIf ($url.Trim() -eq "") {
					# Cancel
				}
				Else {
					Write-Host "`n[ERROR]: Provided parameter is not a valid URL.`n" -ForegroundColor "Red" -BackgroundColor "Black"
					PauseScript
				}
			}
			EndMenu
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 2) {
			$url = ""
			While (! ($url -like "http*")) {
				Clear-Host
				Write-Host "Please enter the URL you would like to download from:`n" -ForegroundColor "Yellow"
				$url = Read-Host "URL"
				If ($url -like "http*") {
					DownloadUrlAudio $url
				}
				ElseIf ($url.Trim() -eq "") {
					# Cancel
				}
				Else {
					Write-Host "`n[ERROR]: Provided parameter is not a valid URL.`n" -ForegroundColor "Red" -BackgroundColor "Black"
					PauseScript
				}
			}
			EndMenu
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 3) {
			Clear-Host
			DownloadPlaylists
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 4) {
			SettingsMenu
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 0) {
			$HOST.UI.RawUI.BackgroundColor = $BackgroundColorBefore
			$HOST.UI.RawUI.ForegroundColor = $ForegroundColorBefore
			Clear-Host
			Exit
		}
		Else {
			Write-Host "`nPlease enter a valid option.`n" -ForegroundColor "Red" -BackgroundColor "Black"
			PauseScript
		}
	}
}



# Call using: DownloadUrlVideo $url
Function DownloadUrlVideo {
	Param($url)
	
	If ($ConvertOutputValue -eq $True -and $OriginalQualityValue -eq $True) {
		$Script:ffmpegConversion = $OutputFileTypeValue + " --prefer-ffmpeg"
	}
	ElseIf ($ConvertOutputValue -eq $True -and $OriginalQualityValue -eq $False) {
		$Script:ffmpegConversion = $OutputFileTypeValue + " --postprocessor-args """ + $VideoBitRateValue + $AudioBitRateValue `
		+ $ResolutionValue + $StartTimeValue + $StopTimeValue + $StripAudioValue + $StripVideoValue + """" + " --prefer-ffmpeg"
	}
	Else {
		$Script:ffmpegConversion = ""
	}
	
	If ($url -like "*youtube.com/playlist*") {
		$VideoPath = $YoutubeVideoFolder + "\%(playlist)s\%(title)s.%(ext)s"
		$YoutubedlCommand = "youtube-dl -o ""$VideoPath"" --ignore-errors $ffmpegConversion --yes-playlist $UseArchiveValue ""$url"""
		Write-Host "`n$YoutubedlCommand`n" -ForegroundColor "Gray"
		Invoke-Expression $YoutubedlCommand
	}
	Else {
		$VideoPath = $YoutubeVideoFolder + "\%(title)s.%(ext)s"
		$YoutubedlCommand = "youtube-dl -o ""$VideoPath"" --ignore-errors $ffmpegConversion --no-playlist ""$url"""
		Write-Host "`n$YoutubedlCommand`n" -ForegroundColor "Gray"
		Invoke-Expression $YoutubedlCommand
	}
}



# Call using: DownloadUrlAudio $url
Function DownloadUrlAudio {
	Param($url)
	
	If ($ConvertOutputValue -eq $True) {
		Write-Host "`n[NOTE]: The output file is currently set to be converted." -ForegroundColor "Red" -BackgroundColor "Black"
		Write-Host "        Only option ""1   - Download Video"" will convert output." -ForegroundColor "Red" -BackgroundColor "Black"
		PauseScript
	}
	
	If ($url -like "*youtube.com/playlist*") {
		$VideoPath = $YoutubeMusicFolder + "\%(playlist)s\%(title)s.%(ext)s"
		$YoutubedlCommand = "youtube-dl -o ""$VideoPath"" --ignore-errors -x --audio-format mp3 --audio-quality 0 --metadata-from-title ""(?P<artist>.+?) - (?P<title>.+)"" --add-metadata --prefer-ffmpeg --yes-playlist $UseArchiveValue ""$url"""
		Write-Host "`n$YoutubedlCommand`n" -ForegroundColor "Gray"
		Invoke-Expression $YoutubedlCommand
	}
	Else {
		$VideoPath = $YoutubeMusicFolder + "\%(title)s.%(ext)s"
		$YoutubedlCommand = "youtube-dl -o ""$VideoPath"" --ignore-errors -x --audio-format mp3 --audio-quality 0 --metadata-from-title ""(?P<artist>.+?) - (?P<title>.+)"" --add-metadata --prefer-ffmpeg --no-playlist ""$url"""
		Write-Host "`n$YoutubedlCommand`n" -ForegroundColor "Gray"
		Invoke-Expression $YoutubedlCommand
	}
}



Function DownloadPlaylists {
	Write-Host "Downloading playlist URL's listed in:`n   $VideoPlaylistFile`n   $AudioPlaylistFile"
	$VideoPlaylistFileLength = Get-ChildItem $VideoPlaylistFile | ForEach-Object {$_.Length}
	$AudioPlaylistFileLength = Get-ChildItem $AudioPlaylistFile | ForEach-Object {$_.Length}
	
	If ($VideoPlaylistFileLength -eq 0 -and $AudioPlaylistFileLength -eq 0) {
		Write-Host "`n[ERROR]: Both predefined playlist files are empty." -ForegroundColor "Red" -BackgroundColor "Black"
		Write-Host "         Please put playlist URL's inside them, one on each line." -ForegroundColor "Red" -BackgroundColor "Black"
		Write-Host "         Playlist files are located in: $SettingsFolder`n" -ForegroundColor "Red" -BackgroundColor "Black"
		PauseScript
		Return
	}
	Else {
		If ($ConvertOutputValue -eq $True -and $OriginalQualityValue -eq $True) {
			$Script:ffmpegConversion = $OutputFileTypeValue + " --prefer-ffmpeg"
		}
		ElseIf ($ConvertOutputValue -eq $True -and $OriginalQualityValue -eq $False) {
			$Script:ffmpegConversion = $OutputFileTypeValue + " --postprocessor-args """ + $VideoBitRateValue + $AudioBitRateValue `
			+ $ResolutionValue + $StartTimeValue + $StopTimeValue + $StripAudioValue + $StripVideoValue + """" + " --prefer-ffmpeg"
		}
		Else {
			$Script:ffmpegConversion = ""
		}
	}
	
	If ($VideoPlaylistFileLength -eq 0) {
		Write-Host "`n[NOTE]: Predefined video playlist file is empty." -ForegroundColor "Red" -BackgroundColor "Black"
		Write-Host "        Please put playlist URL's inside it, one on each line." -ForegroundColor "Red" -BackgroundColor "Black"
		Write-Host "        Playlist file is located at: $VideoPlaylistFile`n" -ForegroundColor "Red" -BackgroundColor "Black"
		PauseScript
	}
	Else {
		Get-Content $VideoPlaylistFile | ForEach-Object {
			Write-Host "`nDownloading playlist: $_" -ForegroundColor "Gray"
			$VideoPath = $YoutubeVideoFolder + "\%(playlist)s\%(title)s.%(ext)s"
			$YoutubedlCommand = "youtube-dl -o ""$VideoPath"" --ignore-errors $ffmpegConversion --yes-playlist $UseArchiveValue ""$_"""
			Write-Host "$YoutubedlCommand`n" -ForegroundColor "Gray"
			Invoke-Expression $YoutubedlCommand
		}
		Write-Host "`nFinished downloading predefined video playlists.`n" -ForegroundColor "Yellow"
	}
	
	If ($AudioPlaylistFileLength -eq 0) {
		Write-Host "`n[NOTE]: Predefined audio playlist file is empty." -ForegroundColor "Red" -BackgroundColor "Black"
		Write-Host "        Please put playlist URL's inside it, one on each line." -ForegroundColor "Red" -BackgroundColor "Black"
		Write-Host "        Playlist file is located at: $AudioPlaylistFile`n" -ForegroundColor "Red" -BackgroundColor "Black"
		PauseScript
	}
	Else {
		Get-Content $AudioPlaylistFile | ForEach-Object {
			Write-Host "`nDownloading playlist: $_" -ForegroundColor "Gray"
			$VideoPath = $YoutubeMusicFolder + "\%(playlist)s\%(title)s.%(ext)s"
			$YoutubedlCommand = "youtube-dl -o ""$VideoPath"" --ignore-errors -x --audio-format mp3 --audio-quality 0 --metadata-from-title ""(?P<artist>.+?) - (?P<title>.+)"" --add-metadata --prefer-ffmpeg --yes-playlist --download-archive $ArchiveFile ""$_"""
			Write-Host "$YoutubedlCommand`n" -ForegroundColor "Gray"
			Invoke-Expression $YoutubedlCommand
		}
		Write-Host "`nFinished downloading predefined audio playlists.`n" -ForegroundColor "Yellow"
	}
	EndMenu
}



function SettingsMenu {
	$MenuOption = 99
	While ($MenuOption -ne 1 -and $MenuOption -ne 2 -and $MenuOption -ne 3 -and $MenuOption -ne 4 -and $MenuOption -ne 5 -and `
	$MenuOption -ne 6 -and $MenuOption -ne 7 -and $MenuOption -ne 8 -and $MenuOption -ne 9 -and $MenuOption -ne 10 -and `
	$MenuOption -ne 11 -and $MenuOption -ne 0) {
		Clear-Host
		Write-Host "================================================================" -BackgroundColor "Black"
		Write-Host "                       Youtube-dl Settings                      " -ForegroundColor "Yellow" -BackgroundColor "Black"
		Write-Host "================================================================" -BackgroundColor "Black"
		If ($ConvertOutputValue -eq $False) {
			Write-Host ($Settings | Where-Object { ($_.ID) -eq 1 -or ($_.ID) -eq "" -or ($_.ID) -eq 11 | Format-Table ID,SettingName,SettingValue -AutoSize | Out-String)
		}
		ElseIf ($ConvertOutputValue -eq $True -and $OriginalQualityValue -eq $True) {
			Write-Host ($Settings | Where-Object { ($_.ID) -eq 1 -or ($_.ID) -eq 2 -or ($_.ID) -eq "" -or ($_.ID) -eq 3 -or ($_.ID) -eq 11 } | Format-Table ID,SettingName,SettingValue -AutoSize | Out-String)
		}
		ElseIf ($ConvertOutputValue -eq $True -and $OriginalQualityValue -eq $False) {
			Write-Host ($Settings | Format-Table ID,SettingName,SettingValue -AutoSize | Out-String)
		}
		Write-Host "  0   - Return to main menu.`n" -ForegroundColor "Gray"
		Write-Host "Please select a variable to edit:`n" -ForegroundColor "Yellow"
		$MenuOption = Read-Host "Option"
		
		If ($MenuOption -eq 1) {
			If ($ConvertOutputValue -eq $False) {
				$Script:ConvertOutputValue = $True
				$ConvertOutput.SettingValue = $True
			}
			Else {
				$Script:ConvertOutputValue = $False
				$ConvertOutput.SettingValue = $False
			}
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 2) {
			If ($OriginalQualityValue -eq $False) {
				$Script:OriginalQualityValue = $True
				$OriginalQuality.SettingValue = $True
			}
			Else {
				$Script:OriginalQualityValue = $False
				$OriginalQuality.SettingValue = $False
			}
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 3) {
			Write-Host "`nPlease enter the file extension to convert the downloaded video to:" -ForegroundColor "Yellow"
			Write-Host "Available options are: mp3 mp4 webm mkv avi`n" -ForegroundColor "Gray"
			$UserAnswer = Read-Host "File Extension"
			If ($UserAnswer -like "`.*") {
				$UserAnswer = $UserAnswer.Substring(1)
			}
			If ($UserAnswer -notlike "mp3" -and $UserAnswer -notlike "mp4" -and $UserAnswer -notlike "webm" -and $UserAnswer -notlike "mkv" -and $UserAnswer -notlike "avi") {
				Write-Host "`n[ERROR]: Please enter a valid file extension." -ForegroundColor "Red" -BackgroundColor "Black"
				Write-Host "         Defaulting file extension to: webm`n" -ForegroundColor "Red" -BackgroundColor "Black"
				PauseScript
				$UserAnswer = $OutputFileTypeDefault
			}
			$Script:OutputFileTypeValue = "--recode-video $UserAnswer"
			$OutputFileType.SettingValue = $UserAnswer
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 4) {
			Write-Host "`nPlease enter the video conversion bitrate in kilobytes:`n" -ForegroundColor "Yellow"
			$UserAnswer = Read-Host "Video Bitrate"
			If ($UserAnswer -like "*k") {
				$UserAnswer = $UserAnswer.Substring(0,$UserAnswer.Length - 1)
			}
			$Script:VideoBitRateValue = " -b:v $UserAnswer" + "k"
			$VideoBitRate.SettingValue = "$UserAnswer" + "k"
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 5) {
			Write-Host "`nPlease enter the audio conversion bitrate in kilobytes:`n" -ForegroundColor "Yellow"
			$UserAnswer = Read-Host "Audio Bitrate"
			If ($UserAnswer -like "*k") {
				$UserAnswer = $UserAnswer.Substring(0,$UserAnswer.Length - 1)
			}
			$Script:AudioBitRateValue = " -b:a $UserAnswer" + "k"
			$AudioBitRate.SettingValue = "$UserAnswer" + "k"
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 6) {
			Write-Host "`nPlease enter the video resolution:" -ForegroundColor "Yellow"
			Write-Host "Enter as WxH where W = width and H = height." -ForegroundColor "Gray"
			Write-Host "Leave blank for original resolution.`n" -ForegroundColor "Gray"
			$UserAnswer = Read-Host "Resolution"
			If ($UserAnswer -notlike "*x*" -and $UserAnswer -notlike "") {
				Write-Host "`n[ERROR]: Please enter a valid resolution." -ForegroundColor "Red" -BackgroundColor "Black"
				Write-Host "         Defaulting resolution to: 640x360`n" -ForegroundColor "Red" -BackgroundColor "Black"
				PauseScript
				$UserAnswer = $ResolutionDefault
			}
			If ($UserAnswer -eq "") {
				$Script:ResolutionValue = ""
				$Resolution.SettingValue = "Original Size"
			}
			Else {
				$Script:ResolutionValue = " -s $UserAnswer"
				$Resolution.SettingValue = $UserAnswer
			}
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 7) {
			Write-Host "`nPlease enter the start time:" -ForegroundColor "Yellow"
			Write-Host "Enter as hh:mm:ss where h = hours, m = minutes, and s = seconds." -ForegroundColor "Gray"
			Write-Host "Leave blank for no start time.`n" -ForegroundColor "Gray"
			$UserAnswer = Read-Host "Start Time"
			If ($UserAnswer -notlike "*:*:*" -and $UserAnswer -notlike "") {
				Write-Host "`n[ERROR]: Please enter a valid start time." -ForegroundColor "Red" -BackgroundColor "Black"
				Write-Host "         Defaulting start time to: 00:00:00`n" -ForegroundColor "Red" -BackgroundColor "Black"
				PauseScript
				$UserAnswer = $StartTimeDefault
			}
			If ($UserAnswer -eq $StartTimeDefault -or $UserAnswer -eq "") {
				$UserAnswer = $StartTimeDefault
				$Script:StartTimeValue = ""
				$StartTime.SettingValue = $UserAnswer
			}
			Else {
				$Script:StartTimeValue = " -ss $UserAnswer"
				$StartTime.SettingValue = $UserAnswer
			}
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 8) {
			Write-Host "`nPlease enter the stop time:" -ForegroundColor "Yellow"
			Write-Host "Enter as hh:mm:ss where h = hours, m = minutes, and s = seconds." -ForegroundColor "Gray"
			Write-Host "Leave blank for no stop time.`n" -ForegroundColor "Gray"
			$UserAnswer = Read-Host "Stop Time"
			If ($UserAnswer -notlike "*:*:*" -and $UserAnswer -notlike "") {
				Write-Host "`n[ERROR]: Please enter a valid stop time." -ForegroundColor "Red" -BackgroundColor "Black"
				Write-Host "         Defaulting to no stop time.`n" -ForegroundColor "Red" -BackgroundColor "Black"
				PauseScript
				$UserAnswer = $StopTimeDefault
			}
			If ($UserAnswer -eq $StopTimeDefault -or $UserAnswer -eq "") {
				$UserAnswer = $StopTimeDefault
				$Script:StopTimeValue = ""
				$StopTime.SettingValue = $UserAnswer
			}
			Else {
				$Script:StopTimeValue = " -to $UserAnswer"
				$StopTime.SettingValue = $UserAnswer
			}
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 9) {
			If (($StripAudio.SettingValue) -eq $False) {
				$Script:StripAudioValue = " -an"
				$StripAudio.SettingValue = $True
			}
			Else {
				$Script:StripAudioValue = ""
				$StripAudio.SettingValue = $False
			}
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 10) {
			If (($StripVideo.SettingValue) -eq $False) {
				$Script:StripVideoValue = " -vn"
				$StripVideo.SettingValue = $True
			}
			Else {
				$Script:StripVideoValue = ""
				$StripVideo.SettingValue = $False
			}
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 11) {
			If (($UseArchive.SettingValue) -eq $False) {
				$Script:UseArchiveValue = "--download-archive $ArchiveFile"
				$UseArchive.SettingValue = $True
			}
			Else {
				$Script:UseArchiveValue = ""
				$UseArchive.SettingValue = $False
			}
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 0) {
			Return
		}
		Else {
			Write-Host "`nPlease enter a valid option.`n" -ForegroundColor "Red" -BackgroundColor "Black"
			PauseScript
		}
	}
}


	
Function EndMenu {
	If ($ParameterMode -eq $False) {
		$MenuOption = 99
		While ($MenuOption -ne 1 -and $MenuOption -ne 2) {
			Write-Host "`n================================================================" -BackgroundColor "Black"
			Write-Host "                        Script Complete                         " -ForegroundColor "Yellow" -BackgroundColor "Black"
			Write-Host "================================================================" -BackgroundColor "Black"
			Write-Host "`nPlease select an option:`n" -ForegroundColor "Yellow"
			Write-Host "  1   - Run again"
			Write-Host "  2   - Exit`n"
			$MenuOption = Read-Host "Option"
			If ($MenuOption -eq 1) {
				$Script:YoutubedlCommand = ""
				$Script:ffmpegConversion = ""
				
				$Script:ConvertOutputValue = $False
				$Script:OriginalQualityValue = $True
				$Script:OutputFileTypeValue = "--recode-video webm"
				$Script:VideoBitRateValue = " -b:v 800k"
				$Script:AudioBitRateValue = " -b:a 128k"
				$Script:ResolutionValue = " -s 640x360"
				$Script:StartTimeValue = ""
				$Script:StopTimeValue = ""
				$Script:StripAudioValue = ""
				$Script:StripVideoValue = ""
				$Script:UseArchiveValue = "--download-archive $ArchiveFile"
				
				$ConvertOutput.SettingValue = $ConvertOutputDefault
				$OriginalQuality.SettingValue = $OriginalQualityDefault
				$OutputFileType.SettingValue = $OutputFileTypeDefault
				$VideoBitRate.SettingValue = $VideoBitRateDefault
				$AudioBitRate.SettingValue = $AudioBitRateDefault
				$Resolution.SettingValue = $ResolutionDefault
				$StartTime.SettingValue = $StartTimeDefault
				$StopTime.SettingValue = $StopTimeDefault
				$StripAudio.SettingValue = $StripAudioDefault
				$StripVideo.SettingValue = $StripVideoDefault
				$UseArchive.SettingValue = $UseArchiveDefault
				
				Return
			}
			ElseIf ($MenuOption -eq 2) {
				$HOST.UI.RawUI.BackgroundColor = $BackgroundColorBefore
				$HOST.UI.RawUI.ForegroundColor = $ForegroundColorBefore
				Clear-Host
				Exit
			}
			Else {
				Write-Host "`nPlease enter a valid option.`n" -ForegroundColor "Red" -BackgroundColor "Black"
				PauseScript
			}
		}
	}
}





# Begin running the script


If ($ParameterMode -eq $True) {
	
	If ($FromFiles -eq $True -and $Video -eq $False -and $Audio -eq $False) {	# Download from predefined playlist files
		
		# Setting output path location
		If ($OutputPath.Length -gt 0) {
			$YoutubeMusicFolder = $OutputPath
			$YoutubeVideoFolder = $OutputPath
			If ((Test-Path "$YoutubeVideoFolder") -eq $False) {
				New-Item -Type directory -Path "$YoutubeVideoFolder"
			}
		}
		DownloadPlaylists
		
		Write-Host "`nDownloads complete.`n" -ForegroundColor "Yellow"
	}
	ElseIf ($FromFiles -eq $True -and ($Video -eq $True -or $Audio -eq $True)) {
		Write-Host "`n[ERROR]: Parameter -FromFiles can't be used with -Video or -Audio.`n" -ForegroundColor "Red" -BackgroundColor "Black"
	}
	ElseIf ($Video -eq $True -and $Audio -eq $False) {	# Download video code block
		
		# Setting output path location
		If ($OutputPath.Length -gt 0) {
			$YoutubeVideoFolder = $OutputPath
			If ((Test-Path "$YoutubeVideoFolder") -eq $False) {
				New-Item -Type directory -Path "$YoutubeVideoFolder"
			}
		}
		DownloadUrlVideo $URL
		
		Write-Host "`nDownload complete.`nDownloaded to: $YoutubeVideoFolder`n" -ForegroundColor "Yellow"
	}
	ElseIf ($Audio -eq $True -and $Video -eq $False) {	# Download audio code block
		
		# Setting output path location
		If ($OutputPath.Length -gt 0) {
			$YoutubeMusicFolder = $OutputPath
			If ((Test-Path "$YoutubeMusicFolder") -eq $False) {
				New-Item -Type directory -Path "$YoutubeMusicFolder"
			}
		}
		DownloadUrlAudio $URL
		
		Write-Host "`nDownload complete.`nDownloaded to: $YoutubeMusicFolder`n" -ForegroundColor "Yellow"
	}
	ElseIf ($Video -eq $True -and $Audio -eq $True) {
		Write-Host "`n[ERROR]: Please select either -Video or -Audio. Not Both.`n" -ForegroundColor "Red" -BackgroundColor "Black"
	}
	
	Exit
}

If ($ParameterMode -eq $False) {
	MainMenu
}

Exit


