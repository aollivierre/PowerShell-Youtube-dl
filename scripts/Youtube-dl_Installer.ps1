
Function PauseScript {
	Write-Host "Press any key to continue ..." -ForegroundColor "Gray"
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

Write-Host "Beginning Youtube-dl script installation ..."

Write-Host "Creating install folders ..."

$SettingsFolder = $ENV:USERPROFILE + "\Youtube-dl"
$FolderCheck = Test-Path $SettingsFolder
If ($FolderCheck -eq $False) {
	New-Item -Type Directory -Path "$SettingsFolder"
}

$ScriptsFolder = $ENV:USERPROFILE + "\Youtube-dl\scripts"
$FolderCheck = Test-Path $ScriptsFolder
If ($FolderCheck -eq $False) {
	New-Item -Type Directory -Path "$ScriptsFolder"
}

$BinFolder = $ENV:USERPROFILE + "\Youtube-dl\bin"
$FolderCheck = Test-Path $BinFolder
If ($FolderCheck -eq $False) {
	New-Item -Type Directory -Path "$BinFolder"
}

$StartFolder = $ENV:APPDATA + "\Microsoft\Windows\Start Menu\Programs\Youtube-dl"
$FolderCheck = Test-Path $StartFolder
If ($FolderCheck -eq $False) {
	New-Item -Type Directory -Path "$StartFolder"
}

$DesktopFolder = $ENV:USERPROFILE + "\Desktop"

Function GetYoutubedl {
	Write-Host "Downloading and installing youtube-dl ..."
	$URL = "https://yt-dl.org/downloads/latest/youtube-dl.exe"
	$Output = $BinFolder + "\youtube-dl.exe"
	$DownloadFileCheck = Test-Path $Output
	If ($DownloadFileCheck -eq $True) {
		Remove-Item $Output
	}
	(New-Object System.Net.WebClient).DownloadFile($Url, $Output)
}

Function GetFfmpeg {
	Write-Host "Downloading and installing ffmpeg ..."
	$ffmpegexe = $BinFolder + "\ffmpeg.exe"
	$ffplayexe = $BinFolder + "\ffplay.exe"
	$ffprobeexe = $BinFolder + "\ffprobe.exe"
	$ffmpegexeCheck = Test-Path $ffmpegexe
	$ffplayexeCheck = Test-Path $ffplayexe
	$ffprobeexeCheck = Test-Path $ffprobeexe
	If ($ffmpegexeCheck -eq $True) {
		Remove-Item $ffmpegexe
	}
	If ($ffplayexeCheck -eq $True) {
		Remove-Item $ffplayexe
	}
	If ($ffprobeexeCheck -eq $True) {
		Remove-Item $ffprobeexe
	}
	$URL = "http://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-3.3.1-win64-static.zip"
	$Output = $SettingsFolder + "\ffmpeg_3.3.1.zip"
	(New-Object System.Net.WebClient).DownloadFile($Url, $Output)
	If ($PSVersionTable.PSVersion.Major -ge 5) {
		Expand-Archive $Output -DestinationPath $SettingsFolder
	}
	Else {
		[System.IO.Compression.ZipFile]::ExtractToDirectory($Output, $SettingsFolder)
	}
	$ffmpegBinFolder = $SettingsFolder + "\ffmpeg-3.3.1-win64-static\bin\*"
	$ffmpegExtractedFolder = $SettingsFolder + "\ffmpeg-3.3.1-win64-static"
	Copy-Item $ffmpegBinFolder -Filter *.exe -Destination $BinFolder -Recurse
	Remove-Item $Output
	Remove-Item -Recurse $ffmpegExtractedFolder
}

Write-Host "Checking PowerShell version ..."

If ($PSVersionTable.PSVersion.Major -lt 5) {
	Write-Host "[NOTE]: Your PowerShell installation is not the most recent version." -ForegroundColor "Red" -BackgroundColor "Black"
	Write-Host "        You can download PowerShell version 5 at:" -ForegroundColor "Red" -BackgroundColor "Black"
	Write-Host "            https://www.microsoft.com/en-us/download/details.aspx?id=50395" -ForegroundColor "Gray" -BackgroundColor "Black"
}
Else {
	Write-Host "PowerShell is up to date."
}

GetYoutubedl

GetFfmpeg

Write-Host "Copying install files ..."

Copy-Item ".\scripts\youtube-dl.ps1" -Destination "$ScriptsFolder"
Copy-Item ".\scripts\Youtube-dl.lnk" -Destination "$ScriptsFolder"
Copy-Item ".\scripts\Youtube-dl.lnk" -Destination "$DesktopFolder"
Copy-Item ".\scripts\Youtube-dl.lnk" -Destination "$StartFolder"
#Copy-Item ".\scripts\update_youtube-dl.ps1" -Destination "$ScriptsFolder"
#Copy-Item ".\scripts\Update Youtube-dl.lnk" -Destination "$ScriptsFolder"
#Copy-Item ".\scripts\Update Youtube-dl.lnk" -Destination "$StartFolder"
Copy-Item ".\README.txt" -Destination "$SettingsFolder"

Write-Host "Installation complete.`n" -ForegroundColor "Yellow"

PauseScript

start notepad "$SettingsFolder\README.txt"

Exit


