
# Function for simulating the 'pause' command of the Windows command line.
function Wait-Script {
    param(
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'If present, do not wait for user input.')]
        [switch]
        $NoUserInput = $false,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Number of seconds to wait.')]
        [int]
        $Seconds = 1
    )

    # Wait for the specified number of seconds.
    Start-Sleep -Seconds $Seconds

    # If the '-NoUserInput' parameter is not specified, wait for the user to press a key before continuing.
    if ($NoUserInput -eq $false) {
		Write-Host "Press any key to continue ...`n" -ForegroundColor "Gray"
		return $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
	}
}

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
        $FilePath = "$PSScriptRoot\powershell-youtube-dl.log",
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether to output to the console in addition to the log file.')]
        [switch]
        $Console = $false
    )

    # Set the severity level formatting based on the user input.
    $SeverityLevel = switch ($Severity) {
        'Info' { 'INFO:    '; break }
        'Warning' { 'WARNING: '; break }
        'Error' { 'ERROR:   '; break }
        default { 'WARNING: '; break }
    }

    # If the '-Console' parameter is provided, tee the output to both the console and log file.
    # Otherwise, only save the output to the log file.
    if ($Console) {
        Tee-Object -Append -FilePath $FilePath -InputObject "$(Get-Date -Format 's') $SeverityLevel $Message"
    }
    else {
        Out-File -Append -FilePath $FilePath -InputObject "$(Get-Date -Format 's') $SeverityLevel $Message"
    }
}

# Function for creating shortcuts.
function New-Shortcut {
    param (
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The directory and name of the shortcut to create.')]
        [string]
        $Path = "$MyInvocation.PSScriptRoot\newshortcut.lnk",
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
        $RunningPath,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Path to the file used as the icon.')]
        [string]
        $IconPath
    )

    # Create the WScript.Shell object, assign it a file path, target path, and other optional settings.
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($Path)
    $Shortcut.TargetPath = $TargetPath
    $Shortcut.Arguments = $Arguments
    $Shortcut.WorkingDirectory = $RunningPath
    $Shortcut.IconLocation = $IconPath
    $Shortcut.Save()
}

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
            HelpMessage = 'Download the file to this location.')]
        [string]
        $Path = "$MyInvocation.PSScriptRoot\downloadfile"
    )

    # Check if the provided '-Path' parameter is a valid file path.
    if (Test-Path -Path $Path -PathType 'Container') {
        return Write-Log -Console -Severity 'Error' -Message "Provided download path cannot be a directory."
    }
    else {
        $TempFile = "$(Split-Path -Path $Path -Parent)\download.tmp"
    }

    # Download the file to a temporary file, then move that file to its permanent location.
    (New-Object System.Net.WebClient).DownloadFile("$Url", $TempFile)
    Move-Item -Path $TempFile -Destination $Path -Force
    if ($?) {
        Write-Log -Severity 'Info' -Message "Downloaded file to '$Path'."
    }
    else {
        if (Test-Path -Path $TempFile) {
            Remove-Item -Path $TempFile
        }
        Write-Log -Console -Severity 'Error' -Message "failed to download file to '$Path'"
    }
}

# Function for downloading the youtube-dl.exe executable file.
function Get-YoutubeDl {
    param(
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Download youtube-dl.exe to this directory.')]
        [string]
        $Path = $MyInvocation.PSScriptRoot
    )

    # Check if the provided '-Path' parameter is a valid directory.
    if ((Test-Path -Path $Path -PathType 'Container') -eq $false) {
        return Write-Log -Console -Severity 'Error' -Message 'Provided download path either does not exist or is not a directory.'
    }
    else {
        $TempFile = "$Path\youtube-dl.exe"
    }

    # Use the 'Get-Download' function to download the youtube-dl.exe executable file.
    Get-Download -Url 'http://yt-dl.org/downloads/latest/youtube-dl.exe' -Path $TempFile
}

# Function for downloading the ffmpeg executable files.
function Get-Ffmpeg {
    param (
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Download ffmpeg to this directory.')]
        [string]
        $Path = $MyInvocation.PSScriptRoot,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether the OS is 32 bit (x86) or 64 bit (x64).')]
        [ValidateSet('x64', 'x86')]
        [string]
        $OsType
    )

    # Check if the provided '-Path' parameter is a valid directory.
    if ((Test-Path -Path $Path -PathType 'Container') -eq $false) {
        return Write-Log -Console -Severity 'Error' -Message 'Provided download path either does not exist or is not a directory.'
    }
    else {
        $TempFile = "$Path\ffmpeg-download.zip"
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
        'x64' { 'http://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-latest-win64-static.zip'; break }
        'x86' { 'http://ffmpeg.zeranoe.com/builds/win32/static/ffmpeg-latest-win32-static.zip'; break }
        Default { 'http://ffmpeg.zeranoe.com/builds/win32/static/ffmpeg-latest-win32-static.zip'; break }
    }

    # Download the ffmpeg zip file and extract the ffmpeg executable files from it.
    Get-Download -Url $DownloadUrl -Path $TempFile
    Expand-Archive -Path $TempFile -Path $Path
    Copy-Item -Path "$Path\ffmpeg-*-win*-static\bin\*" -Destination $Path -Filter "*.exe" -Force
    Remove-Item -Path $TempFile, "$Path\ffmpeg-*-win*-static" -Recurse
}

# Function for downloading and installing the youtube-dl.ps1 script file and creating shortcuts to run it.
function Install-Script {
    param (
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Directory to which the script will be installed.')]
        [string]
        $Path = $MyInvocation.PSScriptRoot,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Directory to which the youtube-dl.exe and ffmpeg.exe executable files will be installed.')]
        [string]
        $ExecutablePath = $MyInvocation.PSScriptRoot,
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

    # Check if the provided '-Path' parameter is a valid directory.
    if ((Test-Path -Path $Path -PathType 'Container') -eq $false) {
        return Write-Log -Console -Severity 'Error' -Message 'Provided install path either does not exist or is not a directory.'
    }

    # Download the youtube-dl.ps1 script file, license, and readme.
    Write-Log -Console -Severity 'Info' -Message "Installing the youtube-dl.ps1 script file to '$Path'"
    $InstallFileList = @('youtube-dl.ps1', 'LICENSE.txt', 'README.md')
    ForEach-Object -InputObject $InstallFileList -Process {
        Get-Download -Url "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/$_" -Path "$Path\$_"
    }

    # Download the youtube-dl.exe and ffmpeg executable files.
    Write-Log -Console -Severity 'Info' -Message "Installing the youtube-dl.exe and ffmpeg.exe executable files to '$ExecutablePath'"
    Get-YoutubeDl -Path $ExecutablePath
    Get-Ffmpeg -Path $ExecutablePath

    # Add the directory containing the executable files to the system path variable.
    if ($ENV:PATH.LastIndexOf(';') -eq ($ENV:PATH.Length - 1)) {
        $ENV:PATH += $ExecutablePath
    }
    else {
        $ENV:PATH += ";$ExecutablePath"
    }
    Write-Log -Console -Severity 'Info' -Message "Appended the system PATH variable with: '$ExecutablePath'"

    # If the '-LocalShortcut' parameter is provided, create a shortcut in the same directory as the
    # youtube-dl.ps1 script that is used to run it.
    if ($LocalShortcut) {
        New-Shortcut -Path "$Path\Youtube-dl.lnk" -TargetPath (Get-Command powershell.exe | Select-Object -Property 'Source') -Arguments "-ExecutionPolicy Bypass -File ""$Path\youtube-dl.ps1""" -RunningPath $Path
        Write-Log -Console -Severity 'Info' -Message "Created a shortcut for running youtube-dl.ps1 at: '$Path\Youtube-dl.lnk'"
    }

    # If the '-DesktopShortcut' parameter is provided, create a shortcut on the desktop that is used
    # to run the youtube-dl.ps1 script.
    if ($DesktopShortcut -eq $true) {
        New-Shortcut -Path "${ENV:USERPROFILE}\Desktop\Youtube-dl.lnk" -TargetPath (Get-Command powershell.exe | Select-Object -Property 'Source') -Arguments "-ExecutionPolicy Bypass -File ""$Path\youtube-dl.ps1""" -RunningPath $Path
        Write-Log -Console -Severity 'Info' -Message "Created a shortcut for running youtube-dl.ps1 at: '${ENV:USERPROFILE}\Desktop\Youtube-dl.lnk'"
    }

    # If the '-StartMenuShortcut' parameter is provided, create a start menu folder containing a shortcut
    # used to run the youtube-dl.ps1 script.
    if ($StartMenuShortcut -eq $true) {
        if ((Test-Path -Path "${ENV:APPDATA}\Microsoft\Windows\Start Menu\Programs\Youtube-dl" -PathType 'Container') -eq $false) {
            New-Item -Type 'Directory' -Path "${ENV:APPDATA}\Microsoft\Windows\Start Menu\Programs\Youtube-dl" | Out-Null
        }

        New-Shortcut -Path "${ENV:APPDATA}\Microsoft\Windows\Start Menu\Programs\Youtube-dl\Youtube-dl.lnk" -TargetPath (Get-Command powershell.exe | Select-Object -Property 'Source') -Arguments "-ExecutionPolicy Bypass -File ""$Path\youtube-dl.ps1""" -RunningPath $Path
        Write-Log -Console -Severity 'Info' -Message "Created a start menu folder and shortcut for running youtube-dl.ps1 at: '${ENV:APPDATA}\Microsoft\Windows\Start Menu\Programs\Youtube-dl\Youtube-dl.lnk'"
    }
}