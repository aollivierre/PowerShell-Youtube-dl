
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

    Start-Sleep -Seconds $Seconds

    if ($NoUserInput -eq $false) {
		Write-Host "Press any key to continue ...`n" -ForegroundColor "Gray"
		return $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
	}
}

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
        [ParameterType]
        $FilePath = "$PSScriptRoot\powershell-youtube-dl.log",
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether to output to the console in addition to the log file.')]
        [switch]
        $Console = $false
    )

    $SeverityLevel = switch ($Severity) {
        'Info' { 'INFO:    '; break }
        'Warning' { 'WARNING: '; break }
        'Error' { 'ERROR:   '; break }
        default { 'WARNING: '; break }
    }

    if ($Console) {
        Tee-Object -Append -FilePath $FilePath -InputObject "$(Get-Date -Format 's') $SeverityLevel $Message"
    }
    else {
        Out-File -Append -FilePath $FilePath -InputObject "$(Get-Date -Format 's') $SeverityLevel $Message"
    }
}

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

    if (Test-Path -Path $Path -PathType 'Container') {
        return Write-Log -Console -Severity 'Error' -Message "Provided download path cannot be a directory."
    }
    else {
        $TempFile = "$(Split-Path -Path $Path -Parent)\download.tmp"
    }

    (New-Object System.Net.WebClient).DownloadFile("$URL", $TempFile)
    Move-Item -Path $TempFile -Destination $Path -Force
    Write-Log -Severity 'Info' -Message "Downloaded file to '$Path'."
}

function Get-YoutubeDl {
    param(
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Download youtube-dl.exe to this directory.')]
        [string]
        $Path = $MyInvocation.PSScriptRoot
    )

    if ((Test-Path -Path $Path -PathType 'Leaf') -eq $false) {
        return Write-Log -Console -Severity 'Error' -Message "Provided download path either does not exist or is not a directory."
    }
    else {
        $TempFile = "$Path\youtube-dl.exe"
    }

    Get-Download -Url 'http://yt-dl.org/downloads/latest/youtube-dl.exe' -Path $TempFile
}

function Get-Ffmpeg {
    param (
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether the OS is 32 bit (x86) or 64 bit (x64).')]
        [ValidateSet('x86','x64')]
        [string]
        $OsType,
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Download ffmpeg to this directory.')]
        [string]
        $Path = $MyInvocation.PSScriptRoot
    )

    if ((Test-Path -Path $Path -PathType 'Leaf') -eq $false) {
        return Write-Log -Console -Severity 'Error' -Message "Provided download path either does not exist or is not a directory."
    }
    else {
        $TempFile = "$Path\ffmpeg-download.zip"
    }

    $DownloadUrl = switch ($OsType) {
        'x86' { 'http://ffmpeg.zeranoe.com/builds/win32/static/ffmpeg-latest-win32-static.zip'; break }
        'x64' { 'http://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-latest-win64-static.zip'; break }
        Default { 'http://ffmpeg.zeranoe.com/builds/win32/static/ffmpeg-latest-win32-static.zip'; break }
    }

    Get-Download -Url $DownloadUrl -Path $TempFile
    Expand-Archive -Path $TempFile -DestinationPath $Path
    Copy-Item -Path "$Path\ffmpeg-*-win*-static\bin\*" -Destination $Path -Filter "*.exe" -Force
    Remove-Item -Path $TempFile, "$Path\ffmpeg-*-win*-static" -Recurse
}