<#PSScriptInfo 
 
.VERSION 1.2.1 
 
.GUID  
 
.AUTHOR ForestFrog
 
.COMPANYNAME 
 
.COPYRIGHT 
 
.TAGS 
 
.LICENSEURI https://github.com/ForestFrog/PowerShell-Youtube-dl/blob/master/LICENSE
 
.PROJECTURI https://github.com/ForestFrog/PowerShell-Youtube-dl
 
.ICONURI 
 
.EXTERNALMODULEDEPENDENCIES 
 
.REQUIREDSCRIPTS 
 
.EXTERNALSCRIPTDEPENDENCIES 
 
.RELEASENOTES 
	1.2.1	22-Jun-2017 - Uploaded the project to Github. Uploaded to Github. Condensed installer to one PowerShell script. Edited documentation.
	1.2.0	30-May-2017 - Implemented ffmpeg video conversion.
	1.1.0	27-May-2017 - Implemented videoplaylist.txt and audioplaylist.txt downloading.
 
#>

<# 
.SYNOPSIS 
    Download audio and video from the internet, mainly from youtube.com
.DESCRIPTION 
    This script downloads audio and video from the internet using the programs youtube-dl and ffmpeg. This script can be ran as a single command using parameters or it can be ran without parameters to use its GUI. Files are downloaded to the user's "Videos" and "Music" folders by default. See README.md for more information.
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
    Updated: June 20th, 2017 
    
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
	Write-Host "Press any key to continue ..." -ForegroundColor "Gray"
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}


$SettingsFolder = $ENV:USERPROFILE + "\Youtube-dl"
$SettingsFolderCheck = Test-Path $SettingsFolder
If ($SettingsFolderCheck -eq $False) {
	New-Item -Type directory -Path $SettingsFolder
}


$BinFolder = $ENV:USERPROFILE + "\Youtube-dl\bin"
$ENV:Path += ";$BinFolder"


$ArchiveFile = $SettingsFolder + "\downloadarchive.txt"
$ArchiveFileCheck = Test-Path $ArchiveFile
If ($ArchiveFileCheck -eq $False) {
	New-Item -Type file -Path $ArchiveFile
}

$VideoPlaylistFile = $SettingsFolder + "\videoplaylists.txt"
$VideoPlaylistFileCheck = Test-Path $VideoPlaylistFile
If ($VideoPlaylistFileCheck -eq $False) {
	New-Item -Type file -Path $VideoPlaylistFile
}

$AudioPlaylistFile = $SettingsFolder + "\audioplaylists.txt"
$AudioPlaylistFileCheck = Test-Path $AudioPlaylistFile
If ($AudioPlaylistFileCheck -eq $False) {
	New-Item -Type file -Path $AudioPlaylistFile
}

$YoutubeMusicFolder = $ENV:USERPROFILE + "\Music\Youtube-dl"
$YoutubeMusicFolderCheck = Test-Path $YoutubeMusicFolder
If ($YoutubeMusicFolderCheck -eq $False) {
	New-Item -Type directory -Path $YoutubeMusicFolder
}

$YoutubeVideoFolder = $ENV:USERPROFILE + "\Videos\Youtube-dl"
$YoutubeVideoFolderCheck = Test-Path $YoutubeVideoFolder
If ($YoutubeVideoFolderCheck -eq $False) {
	New-Item -Type directory -Path $YoutubeVideoFolder
}

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

$Settings = $ConvertOutput,$OriginalQuality,$BlankLine,$OutputFileType,$VideoBitRate,$AudioBitRate,$Resolution,$StartTime,$StopTime,$StripAudio,$StripVideo




# In MainMenu, ask for audio or video, get url, then run either DownloadUrlAudio or DownloadUrlVideo.
Function MainMenu {
	$MenuOption = 99
	While ($MenuOption -ne 1 -and $MenuOption -ne 2 -and $MenuOption -ne 3 -and $MenuOption -ne 4 -and $MenuOption -ne 0) {
		Clear-Host
		Write-Host "================================================================" -BackgroundColor "Black"
		Write-Host "                Youtube-dl Download Script v1.2.1               " -ForegroundColor "Yellow" -BackgroundColor "Black"
		Write-Host "================================================================" -BackgroundColor "Black"
		Write-Host ""
		Write-Host "Please select an option: " -ForegroundColor "Yellow"
		Write-Host ""
		Write-Host "  1   - Download video"
		Write-Host "  2   - Download audio"
		Write-Host "  3   - Download predefined playlists"
		Write-Host "  4   - Settings"
		Write-Host ""
		Write-Host "  0   - Exit" -ForegroundColor "Gray"
		Write-Host ""
		$MenuOption = Read-Host "Option"
		Write-Host ""
		
		If ($MenuOption -eq 1) {			
			$url = ""
			While (! ($url -like "http*")) {
				Clear-Host
				Write-Host "Please enter the URL you would like to download from:" -ForegroundColor "Yellow"
				Write-Host ""
				$url = Read-Host "URL"
				Write-Host ""
				If ($url -like "http*") {
					DownloadUrlVideo $url
				}
				Else {
					Write-Host "[ERROR]: Provided parameter is not a valid URL." -ForegroundColor "Red" -BackgroundColor "Black"
					Write-Host ""
					PauseScript
				}
			}
			
			Write-Host ""
			EndMenu
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 2) {
			$url = ""
			While (! ($url -like "http*")) {
				Clear-Host
				Write-Host "Please enter the URL you would like to download from:" -ForegroundColor "Yellow"
				Write-Host ""
				$url = Read-Host "URL"
				Write-Host ""
				If ($url -like "http*") {
					DownloadUrlAudio $url
				}
				Else {
					Write-Host "[ERROR]: Provided parameter is not a valid URL." -ForegroundColor "Red" -BackgroundColor "Black"
					Write-Host ""
					PauseScript
				}
			}
			
			Write-Host ""
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
			Write-Host "Please enter a valid option." -ForegroundColor "Red" -BackgroundColor "Black"
			Write-Host ""
			PauseScript
			Write-Host ""
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
		$ffmpegConversion = ""
	}
	
	If ($url -like "*youtube.com/playlist*") {
		$VideoPath = $YoutubeVideoFolder + "\%(playlist)s\%(title)s.%(ext)s"
		$YoutubedlCommand = "youtube-dl -o ""$VideoPath"" --ignore-errors $ffmpegConversion --yes-playlist ""$url"""
		Write-Host "$YoutubedlCommand`n" -ForegroundColor "Gray"
		Invoke-Expression $YoutubedlCommand
	}
	Else {
		$VideoPath = $YoutubeVideoFolder + "\%(title)s.%(ext)s"
		$YoutubedlCommand = "youtube-dl -o ""$VideoPath"" --ignore-errors $ffmpegConversion --no-playlist ""$url"""
		Write-Host "$YoutubedlCommand`n" -ForegroundColor "Gray"
		Invoke-Expression $YoutubedlCommand
	}
	
	Write-Host ""
}



# Call using: DownloadUrlAudio $url
Function DownloadUrlAudio {
	Param($url)
	
	If ($url -like "*youtube.com/playlist*") {
		$VideoPath = $YoutubeMusicFolder + "\%(playlist)s\%(title)s.%(ext)s"
		$YoutubedlCommand = "youtube-dl -o ""$VideoPath"" --ignore-errors -x --audio-format mp3 --audio-quality 0 --metadata-from-title ""(?P<artist>.+?) - (?P<title>.+)"" --add-metadata --prefer-ffmpeg --yes-playlist ""$url"""
		Write-Host "$YoutubedlCommand`n" -ForegroundColor "Gray"
		Invoke-Expression $YoutubedlCommand
	}
	Else {
		$VideoPath = $YoutubeMusicFolder + "\%(title)s.%(ext)s"
		$YoutubedlCommand = "youtube-dl -o ""$VideoPath"" --ignore-errors -x --audio-format mp3 --audio-quality 0 --metadata-from-title ""(?P<artist>.+?) - (?P<title>.+)"" --add-metadata --prefer-ffmpeg --no-playlist ""$url"""
		Write-Host "$YoutubedlCommand`n" -ForegroundColor "Gray"
		Invoke-Expression $YoutubedlCommand
	}
	
	Write-Host ""
}



Function DownloadPlaylists {
	Write-Host "Downloading playlist URL's listed in:"
	Write-Host "   $VideoPlaylistFile"
	Write-Host "   $AudioPlaylistFile"
	Write-Host ""
	$VideoPlaylistFileLength = Get-ChildItem $VideoPlaylistFile | ForEach-Object {$_.Length}
	$AudioPlaylistFileLength = Get-ChildItem $AudioPlaylistFile | ForEach-Object {$_.Length}
	
	If ($VideoPlaylistFileLength -eq 0 -and $AudioPlaylistFileLength -eq 0) {
		Write-Host "[ERROR]: Both predefined playlist files are empty." -ForegroundColor "Red" -BackgroundColor "Black"
		Write-Host "         Please put playlist URL's inside them, one on each line." -ForegroundColor "Red" -BackgroundColor "Black"
		Write-Host "         Playlist files are located in: $SettingsFolder" -ForegroundColor "Red" -BackgroundColor "Black"
		Write-Host ""
		If ($ParameterMode -eq $False) {
			PauseScript
		}
		Return
	}
	ElseIf ($VideoPlaylistFileLength -eq 0) {
		Write-Host "[ERROR]: Predefined video playlist file is empty." -ForegroundColor "Red" -BackgroundColor "Black"
		Write-Host "         Please put playlist URL's inside it, one on each line." -ForegroundColor "Red" -BackgroundColor "Black"
		Write-Host "         Playlist file is located at: $VideoPlaylistFile" -ForegroundColor "Red" -BackgroundColor "Black"
		Write-Host ""
		If ($ParameterMode -eq $False) {
			PauseScript
			Write-Host ""
		}
	}
	ElseIf ($AudioPlaylistFileLength -eq 0) {
		Write-Host "[ERROR]: Predefined audio playlist file is empty." -ForegroundColor "Red" -BackgroundColor "Black"
		Write-Host "         Please put playlist URL's inside it, one on each line." -ForegroundColor "Red" -BackgroundColor "Black"
		Write-Host "         Playlist file is located at: $AudioPlaylistFile" -ForegroundColor "Red" -BackgroundColor "Black"
		Write-Host ""
		If ($ParameterMode -eq $False) {
			PauseScript
			Write-Host ""
		}
	}
	
	If ($ConvertOutputValue -eq $True -and $OriginalQualityValue -eq $True) {
		$Script:ffmpegConversion = $OutputFileTypeValue + " --prefer-ffmpeg"
	}
	ElseIf ($ConvertOutputValue -eq $True -and $OriginalQualityValue -eq $False) {
		$Script:ffmpegConversion = $OutputFileTypeValue + " --postprocessor-args """ + $VideoBitRateValue + $AudioBitRateValue `
		+ $ResolutionValue + $StartTimeValue + $StopTimeValue + $StripAudioValue + $StripVideoValue + """" + " --prefer-ffmpeg"
	}
	Else {
		$ffmpegConversion = ""
	}
	
	Get-Content $VideoPlaylistFile | ForEach-Object {
		Write-Host "Downloading playlist: $_" -ForegroundColor "Gray"
		$VideoPath = $YoutubeVideoFolder + "\%(playlist)s\%(title)s.%(ext)s"
		$YoutubedlCommand = "youtube-dl -o ""$VideoPath"" --ignore-errors $ffmpegConversion --yes-playlist --download-archive $ArchiveFile ""$_"""
		Write-Host "$YoutubedlCommand`n" -ForegroundColor "Gray"
		Invoke-Expression $YoutubedlCommand
		Write-Host ""
	}
	Write-Host "Finished downloading predefined video playlists." -ForegroundColor "Yellow"
	Write-Host ""
	
	Get-Content $AudioPlaylistFile | ForEach-Object {
		Write-Host "Downloading playlist: $_" -ForegroundColor "Gray"
		$VideoPath = $YoutubeMusicFolder + "\%(playlist)s\%(title)s.%(ext)s"
		$YoutubedlCommand = "youtube-dl -o ""$VideoPath"" --ignore-errors -x --audio-format mp3 --audio-quality 0 --metadata-from-title ""(?P<artist>.+?) - (?P<title>.+)"" --add-metadata --prefer-ffmpeg --yes-playlist --download-archive $ArchiveFile ""$_"""
		Write-Host "$YoutubedlCommand`n" -ForegroundColor "Gray"
		Invoke-Expression $YoutubedlCommand
		Write-Host ""
	}
	Write-Host "Finished downloading predefined audio playlists." -ForegroundColor "Yellow"
	Write-Host ""
	
	EndMenu
}



function SettingsMenu {
	$MenuOption = 99
	While ($MenuOption -ne 1 -and $MenuOption -ne 2 -and $MenuOption -ne 3 -and $MenuOption -ne 4 -and $MenuOption -ne 5 -and `
	$MenuOption -ne 6 -and $MenuOption -ne 7 -and $MenuOption -ne 8 -and $MenuOption -ne 9 -and $MenuOption -ne 10 -and $MenuOption -ne 0) {
		Clear-Host
		Write-Host "================================================================" -BackgroundColor "Black"
		Write-Host "                        Youtube-dl Settings                         " -ForegroundColor "Yellow" -BackgroundColor "Black"
		Write-Host "================================================================" -BackgroundColor "Black"
		If ($ConvertOutputValue -eq $False) {
			Write-Host ($ConvertOutput | Format-Table ID,SettingName,SettingValue -AutoSize | Out-String)
		}
		ElseIf ($ConvertOutputValue -eq $True -and $OriginalQualityValue -eq $True) {
			Write-Host ($Settings | Where-Object { ($_.ID) -eq 1 -or ($_.ID) -eq 2 -or ($_.ID) -eq "" -or ($_.ID) -eq 3 } | Format-Table ID,SettingName,SettingValue -AutoSize | Out-String)
		}
		ElseIf ($ConvertOutputValue -eq $True -and $OriginalQualityValue -eq $False) {
			Write-Host ($Settings | Format-Table ID,SettingName,SettingValue -AutoSize | Out-String)
		}
		Write-Host "Please select a variable to edit: " -ForegroundColor "Yellow"
		Write-Host ""
		Write-Host "  0   - Return to main menu." -ForegroundColor "Gray"
		Write-Host ""
		$MenuOption = Read-Host "Option"
		Write-Host ""
		
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
			Write-Host "Please enter the file extension to convert the downloaded video to:" -ForegroundColor "Yellow"
			Write-Host "Available options are: mp3 mp4 webm mkv avi`n" -ForegroundColor "Gray"
			$UserAnswer = Read-Host "File Extension"
			Write-Host ""
			If ($UserAnswer -like "`.*") {
				$UserAnswer = $UserAnswer.Substring(1)
			}
			If ($UserAnswer -notlike "mp3" -and $UserAnswer -notlike "mp4" -and $UserAnswer -notlike "webm" -and $UserAnswer -notlike "mkv" -and $UserAnswer -notlike "avi") {
				Write-Host "[ERROR]: Please enter a valid file extension." -ForegroundColor "Red" -BackgroundColor "Black"
				Write-Host "         Defaulting file extension to: webm`n" -ForegroundColor "Red" -BackgroundColor "Black"
				PauseScript
				$UserAnswer = $OutputFileTypeDefault
			}
			$Script:OutputFileTypeValue = "--recode-video $UserAnswer"
			$OutputFileType.SettingValue = $UserAnswer
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 4) {
			Write-Host "Please enter the video conversion bitrate in kilobytes:`n" -ForegroundColor "Yellow"
			$UserAnswer = Read-Host "Video Bitrate"
			If ($UserAnswer -like "*k") {
				$UserAnswer = $UserAnswer.Substring(0,$UserAnswer.Length - 1)
			}
			$Script:VideoBitRateValue = " -b:v $UserAnswer" + "k"
			$VideoBitRate.SettingValue = "$UserAnswer" + "k"
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 5) {
			Write-Host "Please enter the audio conversion bitrate in kilobytes:`n" -ForegroundColor "Yellow"
			$UserAnswer = Read-Host "Audio Bitrate"
			If ($UserAnswer -like "*k") {
				$UserAnswer = $UserAnswer.Substring(0,$UserAnswer.Length - 1)
			}
			$Script:AudioBitRateValue = " -b:a $UserAnswer" + "k"
			$AudioBitRate.SettingValue = "$UserAnswer" + "k"
			$MenuOption = 99
		}
		ElseIf ($MenuOption -eq 6) {
			Write-Host "Please enter the video resolution:" -ForegroundColor "Yellow"
			Write-Host "Enter as WxH where W = width and H = height." -ForegroundColor "Gray"
			Write-Host "Leave blank for original resolution.`n" -ForegroundColor "Gray"
			$UserAnswer = Read-Host "Start Time"
			Write-Host ""
			If ($UserAnswer -notlike "*x*" -and $UserAnswer -notlike "") {
				Write-Host "[ERROR]: Please enter a valid resolution." -ForegroundColor "Red" -BackgroundColor "Black"
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
			Write-Host "Please enter the start time:" -ForegroundColor "Yellow"
			Write-Host "Enter as hh:mm:ss where h = hours, m = minutes, and s = seconds." -ForegroundColor "Gray"
			Write-Host "Leave blank for no start time.`n" -ForegroundColor "Gray"
			$UserAnswer = Read-Host "Start Time"
			Write-Host ""
			If ($UserAnswer -notlike "*:*:*" -and $UserAnswer -notlike "") {
				Write-Host "[ERROR]: Please enter a valid start time." -ForegroundColor "Red" -BackgroundColor "Black"
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
			Write-Host "Please enter the stop time:" -ForegroundColor "Yellow"
			Write-Host "Enter as hh:mm:ss where h = hours, m = minutes, and s = seconds." -ForegroundColor "Gray"
			Write-Host "Leave blank for no stop time.`n" -ForegroundColor "Gray"
			$UserAnswer = Read-Host "Stop Time"
			Write-Host ""
			If ($UserAnswer -notlike "*:*:*" -and $UserAnswer -notlike "") {
				Write-Host "[ERROR]: Please enter a valid stop time." -ForegroundColor "Red" -BackgroundColor "Black"
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
		ElseIf ($MenuOption -eq 0) {
			Return
		}
		Else {
			Write-Host "Please enter a valid option." -ForegroundColor "Red" -BackgroundColor "Black"
			Write-Host ""
			PauseScript
			Write-Host ""
		}
	}
}


	
Function EndMenu {
	If ($ParameterMode -eq $True) {
		Exit
	}
	Else {
		$MenuOption = 99
		While ($MenuOption -ne 1 -and $MenuOption -ne 2) {
			Write-Host "================================================================" -BackgroundColor "Black"
			Write-Host "                        Script Complete                         " -ForegroundColor "Yellow" -BackgroundColor "Black"
			Write-Host "================================================================" -BackgroundColor "Black"
			Write-Host ""
			Write-Host "Please select an option: " -ForegroundColor "Yellow"
			Write-Host ""
			Write-Host "  1   - Run again"
			Write-Host "  2   - Exit"
			Write-Host ""
			$MenuOption = Read-Host "Option"
			Write-Host ""
			If ($MenuOption -eq 1) {
			
				$Script:YoutubedlCommand = ""
				
				$Script:ffmpegConversion = ""
				
				$Script:ConvertOutputValue = $False
				$Script:OriginalQualityValue = $True
				$Script:OutputFileTypeValue = "--recode-video webm"
				$Script:VideoBitRateValue = " -b:v 800k"
				$Script:AudioBitRateValue = " -b:a 128k"
				$Script:ResolutionValue = "640x360"
				$Script:StartTimeValue = ""
				$Script:StopTimeValue = ""
				$Script:StripAudioValue = ""
				$Script:StripVideoValue = ""
				
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
				
				Return
			}
			ElseIf ($MenuOption -eq 2) {
				$HOST.UI.RawUI.BackgroundColor = $BackgroundColorBefore
				$HOST.UI.RawUI.ForegroundColor = $ForegroundColorBefore
				Clear-Host
				Exit
			}
			Else {
				Write-Host "Please enter a valid option." -ForegroundColor "Red" -BackgroundColor "Black"
				Write-Host ""
				PauseScript
				Write-Host ""
			}
		}
	}
}





# Begin running the script


If ($ParameterMode -eq $True) {
	
	If ($FromFiles -eq $True -and $Video -eq $False -and $Audio -eq $False) {	# Download from predefined playlist files
		
		# Setting output path location
		If ($OutputPath.Length -gt 0) {
			$YoutubeVideoFolder = $OutputPath
			$YoutubeVideoFolderCheck = Test-Path $YoutubeVideoFolder
			If ($YoutubeVideoFolderCheck -eq $False) {
				New-Item -Type directory -Path $YoutubeVideoFolder
			}
			
			$YoutubeMusicFolder = $OutputPath
			$YoutubeMusicFolderCheck = Test-Path $YoutubeMusicFolder
			If ($YoutubeMusicFolderCheck -eq $False) {
				New-Item -Type directory -Path $YoutubeMusicFolder
			}
		}
		Else{
			$YoutubeVideoFolder = $ENV:USERPROFILE + "\Videos\Youtube-dl"
			$YoutubeVideoFolderCheck = Test-Path $YoutubeVideoFolder
			If ($YoutubeVideoFolderCheck -eq $False) {
				New-Item -Type directory -Path $YoutubeVideoFolder
			}
			
			$YoutubeMusicFolder = $ENV:USERPROFILE + "\Music\Youtube-dl"
			$YoutubeMusicFolderCheck = Test-Path $YoutubeMusicFolder
			If ($YoutubeMusicFolderCheck -eq $False) {
				New-Item -Type directory -Path $YoutubeMusicFolder
			}
		}
		
		DownloadPlaylists
		
		Write-Host "Downloads complete." -ForegroundColor "Yellow"
		
	}
	ElseIf ($Video -eq $True -and $Audio -eq $False) {	# Download video code block
		
		# Setting output path location
		If ($OutputPath.Length -gt 0) {
			$YoutubeVideoFolder = $OutputPath
			$YoutubeVideoFolderCheck = Test-Path $YoutubeVideoFolder
			If ($YoutubeVideoFolderCheck -eq $False) {
				New-Item -Type directory -Path $YoutubeVideoFolder
			}
		}
		Else{
			$YoutubeVideoFolder = $ENV:USERPROFILE + "\Videos\Youtube-dl"
			$YoutubeVideoFolderCheck = Test-Path $YoutubeVideoFolder
			If ($YoutubeVideoFolderCheck -eq $False) {
				New-Item -Type directory -Path $YoutubeVideoFolder
			}
		}
		
		DownloadUrlVideo $URL
		
		Write-Host "Download complete.`nDownloaded to: $YoutubeVideoFolder" -ForegroundColor "Yellow"
		
	}
	ElseIf ($Audio -eq $True -and $Video -eq $False) {	# Download audio code block
		
		# Setting output path location
		If ($OutputPath.Length -gt 0) {
			$YoutubeMusicFolder = $OutputPath
			$YoutubeMusicFolderCheck = Test-Path $YoutubeMusicFolder
			If ($YoutubeMusicFolderCheck -eq $False) {
				New-Item -Type directory -Path $YoutubeMusicFolder
			}
		}
		Else{
			$YoutubeMusicFolder = $ENV:USERPROFILE + "\Music\Youtube-dl"
			$YoutubeMusicFolderCheck = Test-Path $YoutubeMusicFolder
			If ($YoutubeMusicFolderCheck -eq $False) {
				New-Item -Type directory -Path $YoutubeMusicFolder
			}
		}
		
		DownloadUrlAudio $URL
		
		Write-Host "Download complete.`nDownloaded to: $YoutubeMusicFolder" -ForegroundColor "Yellow"
		
	}
	ElseIf ($Video -eq $True -and $Audio -eq $True) {
		Write-Host "[ERROR]: Please select either -Video or -Audio. Not Both.`n" -ForegroundColor "Red" -BackgroundColor "Black"
	}
	
	Exit
}


MainMenu


