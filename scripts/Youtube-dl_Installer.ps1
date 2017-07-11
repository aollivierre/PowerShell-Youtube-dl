Param(
    [Switch]$Uninstall,
    [Switch]$Everything,
    [Switch]$NoGUI
)

Function PauseScript {
    If ($NoGUI -eq $False) {
	    Write-Host "`nPress any key to continue ...`n" -ForegroundColor "Gray"
	    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
    }
}

If ($Uninstall -eq $False -and $Everything -eq $False) {
    Write-Host "Beginning Youtube-dl script installation ..."

    Write-Verbose "Creating install folders ..."
    $SettingsFolder = $ENV:USERPROFILE + "\Youtube-dl"
    If ((Test-Path "$SettingsFolder") -eq $False) {
	    New-Item -Type Directory -Path "$SettingsFolder"
    }

    $ScriptsFolder = $ENV:USERPROFILE + "\Youtube-dl\scripts"
    If ((Test-Path "$ScriptsFolder") -eq $False) {
	    New-Item -Type Directory -Path "$ScriptsFolder"
    }

    $BinFolder = $ENV:USERPROFILE + "\Youtube-dl\bin"
    If ((Test-Path "$BinFolder") -eq $False) {
	    New-Item -Type Directory -Path "$BinFolder"
    }

    $StartFolder = $ENV:APPDATA + "\Microsoft\Windows\Start Menu\Programs\Youtube-dl"
    If ((Test-Path "$StartFolder") -eq $False) {
	    New-Item -Type Directory -Path "$StartFolder"
    }

    $DesktopFolder = $ENV:USERPROFILE + "\Desktop"

    Function GetYoutubedl {
	    Write-Verbose "Downloading and installing youtube-dl ..."
	    $URL = "https://yt-dl.org/downloads/latest/youtube-dl.exe"
	    $Output = $BinFolder + "\youtube-dl.exe"
	    If ((Test-Path "$Output") -eq $True) {
		    Remove-Item -Path "$Output"
	    }
	    (New-Object System.Net.WebClient).DownloadFile($Url, $Output)
    }

    Function GetFfmpeg {
	    Write-Verbose "Downloading and installing ffmpeg ..."
	    $ffmpegexe = $BinFolder + "\ffmpeg.exe"
	    $ffplayexe = $BinFolder + "\ffplay.exe"
	    $ffprobeexe = $BinFolder + "\ffprobe.exe"

	    If ((Test-Path "$ffmpegexe") -eq $True) {
		    Remove-Item -Path "$ffmpegexe"
	    }
	    If ((Test-Path "$ffplayexe") -eq $True) {
		    Remove-Item -Path "$ffplayexe"
	    }
	    If ((Test-Path "$ffprobeexe") -eq $True) {
		    Remove-Item -Path "$ffprobeexe"
	    }
        
        If (([environment]::Is64BitOperatingSystem) -eq $True) {
	        $URL = "http://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-3.3.2-win64-static.zip"
        }
        Else {
            $URL = "http://ffmpeg.zeranoe.com/builds/win32/static/ffmpeg-3.3.2-win32-static.zip"
        }
	    $Output = $SettingsFolder + "\ffmpeg_3.3.2.zip"
	    (New-Object System.Net.WebClient).DownloadFile($Url, $Output)

	    If ($PSVersionTable.PSVersion.Major -ge 5) {
		    Expand-Archive -Path "$Output" -DestinationPath "$SettingsFolder"
	    }
	    Else {
		    [System.IO.Compression.ZipFile]::ExtractToDirectory($Output, $SettingsFolder)
	    }

	    $ffmpegBinFolder = $SettingsFolder + "\ffmpeg-3.3.2-win64-static\bin\*"
	    $ffmpegExtractedFolder = $SettingsFolder + "\ffmpeg-3.3.2-win64-static"
	    Copy-Item -Path "$ffmpegBinFolder" -Destination "$BinFolder" -Recurse -Filter "*.exe"
	    Remove-Item -Path "$Output"
	    Remove-Item -Path "$ffmpegExtractedFolder" -Recurse 
    }

    Write-Verbose "Checking PowerShell version ..."
    If ($PSVersionTable.PSVersion.Major -lt 5) {
	    Write-Host "[NOTE]: Your PowerShell installation is not the most recent version.`n        It's recommended that you have PowerShell version 5 to use this script.`n        You can download PowerShell version 5 at:`n            https://www.microsoft.com/en-us/download/details.aspx?id=50395" -ForegroundColor "Red" -BackgroundColor "Black"
    }
    Else {
	    Write-Verbose "PowerShell is up to date."
    }

    GetYoutubedl

    GetFfmpeg

    Write-Verbose "Copying install files ..."
    Copy-Item "$PSScriptRoot\youtube-dl.ps1" -Destination "$ScriptsFolder"
    Copy-Item "$PSScriptRoot\Youtube-dl.lnk" -Destination "$ScriptsFolder"
    Copy-Item "$PSScriptRoot\Youtube-dl.lnk" -Destination "$DesktopFolder"
    Copy-Item "$PSScriptRoot\Youtube-dl.lnk" -Destination "$StartFolder"
    Copy-Item "$PSScriptRoot\Youtube-dl_Installer.ps1" -Destination "$ScriptsFolder"
    Copy-Item "$PSScriptRoot\Youtube-dl_Uninstall.lnk" -Destination "$ENV:USERPROFILE"
    Copy-Item "$PSScriptRoot\..\README.md" -Destination "$SettingsFolder"
    Copy-Item "$PSScriptRoot\..\LICENSE" -Destination "$SettingsFolder"

    Write-Host "`nInstallation complete." -ForegroundColor "Yellow"
    PauseScript
    Exit
}
ElseIf ($Uninstall -eq $True -or $Everything -eq $True) {
    $SettingsFolder = $ENV:USERPROFILE + "\Youtube-dl"
    $StartFolder = $ENV:APPDATA + "\Microsoft\Windows\Start Menu\Programs\Youtube-dl"
    $DesktopFolder = $ENV:USERPROFILE + "\Desktop"

    Write-Host "Beginning Youtube-dl script uninstall ..."
    If ($Uninstall -eq $True -and $Everything -eq $False) {
        Write-Verbose "Removing Youtube-dl folders and files, leaving behind .txt and .ini files ..."
        Remove-Item -Path "$SettingsFolder", "$StartFolder", "$DesktopFolder\Youtube-dl.lnk" -Recurse -Exclude "*.txt", "*.ini"
    }
    ElseIf ($Uninstall -eq $True -and $Everything -eq $True) {
        Write-Verbose "Removing all Youtube-dl folders and files ..."
        Remove-Item -Path "$SettingsFolder", "$StartFolder", "$DesktopFolder\Youtube-dl.lnk" -Recurse
    }
    Write-Host "`nUninstall complete." -ForegroundColor "Yellow"
    PauseScript
    Exit
}
