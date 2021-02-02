


# Function for simulating the 'pause' command of the Windows command line.
function Wait-Script {
    param(
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'If true, do not wait for user input.')]
        [switch]
        $NonInteractive = $false,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Number of seconds to wait.')]
        [int]
        $Seconds = 0
    )

    # Wait for a specified number of seconds.
    Start-Sleep -Seconds $Seconds

    # If the '-NonInteractive' parameter is false, wait for the user to press a key before continuing.
    if ($NonInteractive -eq $false) {
		Write-Host "Press any key to continue ...`n" -ForegroundColor "Gray"
	    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
	}
} # End Wait-Script function



# Function for writing messages to a log file.
function Write-Log {
    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'The message to output to the log.')]
        [string]
        $Message,
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'The severity level of the message to log.')]
        [ValidateSet('Info','Warning','Error')]
        [string]
        $Severity,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Location of the log file.')]
        [string]
        $FilePath = "$(Get-Location)\powershell-youtube-dl.log",
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether to output to the console in addition to the log file.')]
        [switch]
        $Console = $false,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether to output only to the console.')]
        [switch]
        $ConsoleOnly = $false
    )

    # Set the severity level formatting based on the user input.
    $SeverityLevel = switch ($Severity) {
        'Info' { 'INFO:   '; break }
        'Warning' { 'WARNING:'; break }
        'Error' { 'ERROR:  '; break }
        default { 'INFO:   '; break }
    }

    # If the '-Console' parameter is true, tee the output to both the console and log file.
    # If the '-ConsoleOnly' parameter is true, only write the output to the console.
    # Otherwise, only save the output to the log file.
    if ($Console) {
        Tee-Object -Append -FilePath $FilePath -InputObject "$(Get-Date -Format 's') $SeverityLevel $Message"
    }
    elseif ($ConsoleOnly) {
        Write-Host "$(Get-Date -Format 's') $SeverityLevel $Message"
    }
    else {
        Out-File -Append -FilePath $FilePath -InputObject "$(Get-Date -Format 's') $SeverityLevel $Message"
    }
} # End Write-Log function



# Function for creating shortcuts.
function New-Shortcut {
    param (
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The full path of the shortcut to create.')]
        [string]
        $Path = "$(Get-Location)\newshortcut.lnk",
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'The target path of the shortcut.')]
        [string]
        $TargetPath,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Arguments to pass to the target path when the shortcut is ran.')]
        [string]
        $Arguments,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The directory from which to run the target path.')]
        [string]
        $StartPath,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Path to the file used as the icon.')]
        [string]
        $IconPath
    )

    $TargetPath = Resolve-Path -Path $TargetPath

    # Create the WScript.Shell object, assign it a file path, target path, and other optional settings.
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($Path)
    if ($TargetPath.Length -gt 0) {
        $Shortcut.TargetPath = $TargetPath
    }
    if ($Arguments.Length -gt 0) {
        $Shortcut.Arguments = $Arguments
    }
    if ($StartPath.Length -gt 0) {
        $Shortcut.WorkingDirectory = $StartPath
    }
    if ($IconPath.Length -gt 0) {
        $Shortcut.IconLocation = $IconPath
    }
    $Shortcut.Save()
} # End New-Shortcut function



# Function for downloading files from the internet.
function Get-Download {
    param(
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Web URL of the file to download.')]
        [string]
        $Url,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The full path of where to download the file to.')]
        [string]
        $Path = "$(Get-Location)\downloadfile"
    )

    # Check if the provided '-Path' parameter is a valid file path.
    if (Test-Path -Path $Path -PathType 'Container') {
        return Write-Log -ConsoleOnly -Severity 'Error' -Message "Provided download path cannot be a directory."
    }
    else {
        $TempFile = "$(Split-Path -Path $Path -Parent)\download.tmp"
    }

    # Download the file to a temporary file.
    (New-Object System.Net.WebClient).DownloadFile("$Url", $TempFile)

    # Rename and move the downloaded temporary file to its permanent location.
    if (Test-Path -Path $TempFile) {
        Move-Item -Path $TempFile -Destination $Path -Force
        Write-Log -ConsoleOnly -Severity 'Info' -Message "Downloaded file to '$Path'."
    }
    else {
        return Write-Log -ConsoleOnly -Severity 'Error' -Message "Failed to download file to '$Path'"
    }

    # Remove the temporary file if it still exists.
    if (Test-Path -Path $TempFile) {
        Remove-Item -Path $TempFile
    }
} # End Get-Download function



# Function for downloading the youtube-dl.exe executable file.
function Get-YoutubeDl {
    param(
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Download youtube-dl.exe to this directory.')]
        [string]
        $Path = (Get-Location)
    )

    $Path = Resolve-Path -Path $Path

    # Check if the provided '-Path' parameter is a valid directory.
    if ((Test-Path -Path $Path -PathType 'Container') -eq $false) {
        return Write-Log -ConsoleOnly -Severity 'Error' -Message 'Provided download path either does not exist or is not a directory.'
    }
    else {
        $TempFile = "$Path\youtube-dl.exe"
    }

    # Use the 'Get-Download' function to download the youtube-dl.exe executable file.
    Get-Download -Url 'http://yt-dl.org/downloads/latest/youtube-dl.exe' -Path $TempFile
    if (Test-Path -Path "$Path\youtube-dl.exe") {
        Write-Log -ConsoleOnly -Severity 'Info' -Message "Downloaded the youtube-dl executable."
    }
    else {
        return Write-Log -ConsoleOnly -Severity 'Error' -Message "Failed to download the youtube-dl executable."
    }
} # End Get-YoutubeDl function



# Function for downloading the ffmpeg executable files.
function Get-Ffmpeg {
    param (
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Download ffmpeg to this directory.')]
        [string]
        $Path = (Get-Location),
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether the OS is 32 bit (x86) or 64 bit (x64).')]
        [ValidateSet('x64', 'x86')]
        [string]
        $OsType
    )

    $Path = Resolve-Path -Path $Path

    # Check if the provided '-Path' parameter is a valid directory.
    if (Test-Path -Path $Path -PathType 'Container') {
        $TempFile = "$Path\ffmpeg-download.zip"
    }
    else {
        return Write-Log -ConsoleOnly -Severity 'Error' -Message 'Provided download path either does not exist or is not a directory.'
    }

    # If the '-OsType' parameter wasn't provided, determine the OS type (whether its x86 or x64).
    if ($OsType.Length -eq 0) {
        if ([environment]::Is64BitOperatingSystem) {
            $OsType = 'x64'
        }
        else {
            $OsType = 'x86'
        }
    }

    # Based off the value of '-OsType' determine which ffmpeg download link to use.
    $DownloadUrl = switch ($OsType) {
        'x64' { 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip'; break }
        'x86' { 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip'; break }
        Default { 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip'; break }
    }

    # Download the ffmpeg zip file.
    Get-Download -Url $DownloadUrl -Path $TempFile
    if (-Not (Test-Path -Path $TempFile)) {
        return Write-Log -ConsoleOnly -Severity 'Error' -Message "Failed to download the ffmpeg executables."
    }

    # Extract the ffmpeg executable files from the downloaded zip file.
    Expand-Archive -Path $TempFile -DestinationPath $Path
    Copy-Item -Path "$Path\ffmpeg-*\bin\*" -Destination $Path -Filter "*.exe" -Force
    Remove-Item -Path $TempFile, "$Path\ffmpeg-*" -Recurse
    if ((Test-Path -Path "$Path\ffmpeg.exe") -and (Test-Path -Path "$Path\ffplay.exe") -and (Test-Path -Path "$Path\ffprobe.exe")) {
        Write-Log -ConsoleOnly -Severity 'Info' -Message "Downloaded and extracted the ffmpeg executables."
    }
    else {
        return Write-Log -ConsoleOnly -Severity 'Error' -Message "Failed to download and extract the ffmpeg executables."
    }
} # End Get-Ffmpeg function



# Function for downloading and installing the youtube-dl.ps1 script file and creating shortcuts to run it.
function Install-Script {
    param (
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Directory to which the script will be installed.')]
        [string]
        $Path = (Get-Location),
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Directory to which the youtube-dl.exe and ffmpeg.exe executable files will be installed.')]
        [string]
        $ExecutablePath = $Path,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether to create a local shortcut that is used to run the youtube-dl.ps1 script.')]
        [switch]
        $LocalShortcut = $false,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether to create a desktop shortcut for the script.')]
        [switch]
        $DesktopShortcut = $false,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether to create a start menu shortcut for the script.')]
        [switch]
        $StartMenuShortcut = $false
    )

    $Path = Resolve-Path -Path $Path
    $ExecutablePath = Resolve-Path $ExecutablePath

    # Check if the provided '-Path' parameter is a valid directory.
    if ((Test-Path -Path $Path -PathType 'Container') -eq $false) {
        return Write-Log -ConsoleOnly -Severity 'Error' -Message 'Provided install path either does not exist or is not a directory.'
    }

    # Download the youtube-dl.ps1 script file, license, and readme.
    Write-Log -ConsoleOnly -Severity 'Info' -Message "Installing the youtube-dl.ps1 script file to '$Path'"
    $InstallFileList = @('youtube-dl.ps1', 'LICENSE.txt', 'README.md')
    foreach ($Item in $InstallFileList) {
        Get-Download -Url "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/$Item" -Path "$Path\$Item"
    }

    # Download the youtube-dl.exe and ffmpeg executable files.
    Write-Log -ConsoleOnly -Severity 'Info' -Message "Installing the youtube-dl.exe and ffmpeg.exe executable files to '$ExecutablePath'"
    Get-YoutubeDl -Path $ExecutablePath
    Get-Ffmpeg -Path $ExecutablePath

    # Add the directory containing the executable files to the system path variable.
    if ($ENV:PATH.LastIndexOf(';') -eq ($ENV:PATH.Length - 1)) {
        $ENV:PATH += $ExecutablePath
    }
    else {
        $ENV:PATH += ";$ExecutablePath"
    }
    Write-Log -ConsoleOnly -Severity 'Info' -Message "Appended the system PATH variable with: '$ExecutablePath'"

    # If the '-LocalShortcut' parameter is provided, create a shortcut in the same directory as the
    # youtube-dl.ps1 script that is used to run it.
    if ($LocalShortcut) {
        New-Shortcut -Path "$Path\Youtube-dl.lnk" -TargetPath (Get-Command powershell.exe | Select-Object -Property 'Source') -Arguments "-ExecutionPolicy Bypass -File ""$Path\youtube-dl.ps1""" -StartPath $Path
        if (Test-Path -Path "$Path\Youtube-dl.lnk") {
            Write-Log -ConsoleOnly -Severity 'Info' -Message "Created a shortcut for running youtube-dl.ps1 at: '$Path\Youtube-dl.lnk'"
        }
        else {
            return Write-Log -ConsoleOnly -Severity 'Error' -Message "Failed to create a shortcut at: '$Path\Youtube-dl.lnk'"
        }
    }

    # If the '-DesktopShortcut' parameter is provided, create a shortcut on the desktop that is used
    # to run the youtube-dl.ps1 script.
    if ($DesktopShortcut -eq $true) {
        $DesktopPath = [environment]::GetFolderPath('Desktop')
        New-Shortcut -Path "$DesktopPath\Youtube-dl.lnk" -TargetPath (Get-Command powershell.exe | Select-Object -Property 'Source') -Arguments "-ExecutionPolicy Bypass -File ""$Path\youtube-dl.ps1""" -StartPath $Path
        if (Test-Path -Path "$DesktopPath\Youtube-dl.lnk") {
            Write-Log -ConsoleOnly -Severity 'Info' -Message "Created a shortcut for running youtube-dl.ps1 at: '$DesktopPath\Youtube-dl.lnk'"
        }
        else {
            return Write-Log -ConsoleOnly -Severity 'Error' -Message "Failed to create a shortcut at: '$DesktopPath\Youtube-dl.lnk'"
        }
    }

    # If the '-StartMenuShortcut' parameter is provided, create a start menu folder containing a shortcut
    # used to run the youtube-dl.ps1 script.
    if ($StartMenuShortcut -eq $true) {
        $AppDataPath = [Environment]::GetFolderPath('ApplicationData')
        if ((Test-Path -Path "$AppDataPath\Microsoft\Windows\Start Menu\Programs\Youtube-dl" -PathType 'Container') -eq $false) {
            New-Item -Type 'Directory' -Path "$AppDataPath\Microsoft\Windows\Start Menu\Programs\Youtube-dl" | Out-Null
        }

        New-Shortcut -Path "$AppDataPath\Microsoft\Windows\Start Menu\Programs\Youtube-dl\Youtube-dl.lnk" -TargetPath (Get-Command powershell.exe | Select-Object -Property 'Source') -Arguments "-ExecutionPolicy Bypass -File ""$Path\youtube-dl.ps1""" -StartPath $Path
        if (Test-Path -Path "$AppDataPath\Microsoft\Windows\Start Menu\Programs\Youtube-dl\Youtube-dl.lnk") {
            Write-Log -ConsoleOnly -Severity 'Info' -Message "Created a start menu folder and shortcut for running youtube-dl.ps1 at: '$AppDataPath\Microsoft\Windows\Start Menu\Programs\Youtube-dl\Youtube-dl.lnk'"
        }
        else {
            return Write-Log -ConsoleOnly -Severity 'Error' -Message "Failed to create a shortcut at: '$AppDataPath\Microsoft\Windows\Start Menu\Programs\Youtube-dl\Youtube-dl.lnk'"
        }
    }
} # End Install-Script function



function Get-Video {
    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'The URL of the video to download.')]
        [string]
        $Url,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Download the video to this directory.')]
        [string]
        $Path = (Get-Location),
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Additional youtube-dl options to pass to the download command.')]
        [string]
        $YoutubeDlOptions = "-o ""$Path\%(title)s.%(ext)s"" --console-title --ignore-errors --cache-dir ""$(Get-Location)"" --no-mtime --no-playlist"
    )

    $Path = Resolve-Path -Path $Path
    $Url = $Url.Trim()
    $YoutubeDlOptions = $YoutubeDlOptions.Trim()

    # Check if the provided '-Path' parameter is a valid directory.
    if ((Test-Path -Path $Path -PathType 'Container') -eq $false) {
        return Write-Log -ConsoleOnly -Severity 'Error' -Message 'Provided path either does not exist or is not a directory.'
    }

    Write-Log -ConsoleOnly -Severity 'Info' -Message "Downloading video from URL '$Url' to '$Path' using youtube-dl options of '$YoutubeDlOptions'." ### Might need to add more to $Path so that it includes the file name too.
    Invoke-Expression $DownloadCommand
} # End Get-Video function



function Get-Audio {
    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'The URL of the video to download audio from.')]
        [string]
        $Url,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Download the video''s audio to this directory.')]
        [string]
        $Path = (Get-Location),
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Additional youtube-dl options to pass to the download command.')]
        [string]
        $YoutubeDlOptions = "-o ""$Path\%(title)s.%(ext)s"" --console-title --ignore-errors --cache-dir ""$(Get-Location)"" --no-mtime --no-playlist"
    )

    $Path = Resolve-Path -Path $Path
    $Url = $Url.Trim()
    $YoutubeDlOptions = $YoutubeDlOptions.Trim()

    # Check if the provided '-Path' parameter is a valid directory.
    if ((Test-Path -Path $Path -PathType 'Container') -eq $false) {
        return Write-Log -ConsoleOnly -Severity 'Error' -Message 'Provided path either does not exist or is not a directory.'
    }

    Write-Log -ConsoleOnly -Severity 'Info' -Message "Downloading audio from URL of '$Url' to '$Path' using youtube-dl options of '$YoutubeDlOptions'." ### Might need to add more to $Path so that it includes the file name too.
    Invoke-Expression $DownloadCommand
} # End Get-Audio function



function Get-Playlist {
    param (
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Path to the file containing a list of playlist URLs to download.')]
        [string]
        $Path,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Array object containing a list of playlist URLs to download.')]
        [array]
        $UrlList = @()
    )

    $Path = Resolve-Path -Path $Path

    # If the '-Path' parameter was provided, check if it is a valid file.
    # Otherwise, check whether the value of the '-UrlList' parameter is an array.
    if ($Path.Length -gt 0 -and (Test-Path -Path $Path -PathType 'Leaf') -eq $false) {
        Write-Log -ConsoleOnly -Severity 'Error' -Message 'Provided path either does not exist or is not a file.'
        return @()
    }
    elseif ($UrlList -isnot [array]) {
        return Write-Log -ConsoleOnly -Severity 'Error' -Message 'Provided ''-UrlList'' parameter value is not an array.'
        return @()
    }

    # If the '-Path' parameter was provided, get an array of string objects from that file.
    if ($Path.Length -gt 0) {
        $UrlList = Get-Content -Path $Path | Where-Object { $_.Trim() -ne '' -and $_.Trim() -notmatch '^#.*' }
    }

    # Return an array of playlist URL string objects.
    Write-Log -ConsoleOnly -Severity 'Info' -Message "Returning $($UrlList.Count) playlist URLs."
    return $UrlList
} # End Get-Playlist function


