# PowerShell-Youtube-dl
https://github.com/mpb10/PowerShell-Youtube-dl

A PowerShell script used to operate the youtube-dl command line program.


**Author: mpb10**

**November 16th, 2017**

**v1.2.6**
#

 - [INSTALLATION](#installation)
 - [USAGE](#usage)
 - [ADVANCED USAGE](#advanced-usage)
 - [CHANGE LOG](#change-log)
 - [ADDITIONAL NOTES](#additional-notes)
 
#

# INSTALLATION

**Script download link:** https://github.com/mpb10/PowerShell-Youtube-dl/archive/master.zip

Note: These scripts require Windows PowerShell to function. PowerShell comes pre-installed with Windows 10 but otherwise can be downloaded here: https://www.microsoft.com/en-us/download/details.aspx?id=50395

Make sure your ExecutionPolicy is properly set by opening a PowerShell window with administrator privileges and typing `Set-ExecutionPolicy RemoteSigned`.

#

**To Install:** 

Download the project .zip file, extract it to a folder, and run the `Youtube-dl_Installer` shortcut. The script will be installed to the folder `C:\Users\%USERNAME%\Youtube-dl`. A desktop shortcut and a Start Menu shortcut will be created. Run either of these to use the script. 

To update the script, delete the following folders, download the new version and install it:

	C:\Users\%USERNAME%\Youtube-dl\bin
	C:\Users\%USERNAME%\Youtube-dl\scripts
Make sure you don't delete any of the .txt files!

#

To uninstall this script and its files, run the `Youtube-dl_Uninstall` shortcut located in `C:\Users\%USERNAME%`. This will remove the script, the youtube-dl and ffmpeg programs, the start menu folder, and the desktop shortcut. This uninstaller will leave behind files that have a file extension of `.txt` or `.ini`. If you wish to uninstall all Youtube-dl files, including text files, copy the script `C:\Users\%USERNAME%\Youtube-dl\scripts\Youtube-dl_Installer.ps1` to the desktop and run it with the `-Uninstall` and `-Everything` parameters via a PowerShell console.


# USAGE

Run either the desktop shortcut or the Start Menu shortcut. Choose to download either video or audio, and then right click and paste the URL into the prompt. The URL you provide it can be either the URL of a video or the URL of a playlist.

Video files are downloaded to `C:\Users\%USERNAME%\Videos\Youtube-dl` and audio files are downloaded to `C:\Users\%USERNAME%\Music\Youtube-dl`. Playlists will be downloaded into their own subfolders.

Upon being ran for the first time, the script will generate the `downloadarchive.txt`, `audioplaylist.txt`, and `videoplaylist.txt` files. The `downloadarchive.txt` file keeps a record of videos that have been downloaded from playlists. Any videos that the user downloads from a playlist will be added to this file and will be skipped if the playlist is downloaded again, provided that the "UseArchive" variable is set to `True` in the settings menu.


# ADVANCED USAGE

**MAIN MENU:**

`1   - Download video`	

This option prompts the user for the URL of a video. This URL can be a single video or a playlist and doesn't necessarily have to be from Youtube.com since Youtube-dl supports a wide range of websites. If a playlist URL is provided, the entire playlist will be downloaded. The `1   - Download video` option can be run from the command line using the `-Video -URL (UserProvidedURL)` parameter options.

Additonally, the `1   - Download video` option can be used with the video conversion settings found in the `4   - Settings` option menu which will be covered later.

#

`2   - Download audio`	

This option prompts the user for the URL of a video who's audio will be extracted and converted to an MP3 file. This URL can be a single video or a playlist and doesn't necessarily have to be from Youtube.com since Youtube-dl supports a wide range of websites. If a playlist URL is provided, the entire playlist will be downloaded. The script will also attempt to insert the correct artist and title metadata into the MP3 file, provided that there is a hypen character `-` seperating the artist and song name. The `2   - Download audio` option can be run from the command line using the `-Audio -URL (UserProvidedURL)` parameter options. 

The video conversion settings found in `4   - Settings` will have no effect on audio downloaded using the `2   - Download audio` option.

#

`3   - Download predefined playlists`	

This option downloads the video and audio of URL's listed in the `audioplaylist.txt` and `videoplaylist.txt` files which are located in `C:\Users\%USERNAME%\Youtube-dl`. List any playlist URL's or individual video URL's one line at a time in these files. The script will skip the downloading of any video listed in the `downloadarchive.txt` file unless the `Use archive file?` option, found in `4   - Settings`, is set to false. Videos listed in the `videoplaylist.txt` file will download to the `C:\Users\%USERNAME%\Videos\Youtube-dl` folder and put each playlist in its own folder. The same goes for the `audioplaylist.txt` file which downloads to the `C:\Users\%USERNAME%\Music\Youtube-dl` folder.

The video conversion settings found in `4   - Settings` will only affect the videos listed in the `videoplaylist.txt` file.

#

`4   - Settings`	

This option brings the user to the settings menu. The primary purpose of the settings menu is to allow the user to set ffmpeg conversion options. These ffmpeg options have no effect when running the script from the command line. Below is a description of each setting:

	'Use archive file?'
		ID:		1
		Default:	True
		Description:	This setting toggles whether the archive file is used when downloading a video.
				Video and audio downloaded from playlists will automatically record each individual 
				video's URL in the 'downloadarchive.txt' file. The script will skip the downloading 
				of any video listed in the 'downloadarchive.txt' file unless this option is set to 
				false. This is useful when downloading from playlists that continually have videos 
				added to them.

	'Download entire playlist?'
		ID:		2
		Default:	False
		Description:	This setting determines whether to download the entire playlist when the video or
				audio being downloaded is part of a playlist. Setting this to true will download
				the entire playlist if a single video of that playlist is downloaded. This is useful
				for one-time downloading of playlists that you don't want to list in the playlist
				text files.

	'Convert output?'
		ID:		3
		Default:	False
		Description:	This setting toggles whether the video will be converted when it is downloaded. Changing
				this setting to 'True' will display additional ffmepg conversion settings.
				NOTE: Settings 10 through 18 will have no effect on the downloaded video if this is
				set to 'False'.
				
	'Use default quality?'
		ID:		10
		Default:	True
		Description:	Setting this option to 'True' will have the video be converted using the default
				ffmpeg quality settings. Generally, the user will want to set this to false and modify
				the ffmpeg settings themselves. Setting this setting to 'False' will display additional
				ffmpeg settings.
				
	'Output file extension'
		ID:		11
		Default:	webm
		Description:	This setting determines what file format the video will be converted to. Available
				file formats are mp3, mp4, webm, mkv, and avi.
				
	'Video bitrate'
		ID:		12
		Default:	800k
		Description:	This setting determines the video bitrate quality. This number is entered as kilobytes.
				The video bitrate of 800k is low-to-medium quality and is good for posting to forums
				because of its smaller file size. Experiment with this setting to get a quality that
				suits you and your needs.
				
	'Audio bitrate'
		ID:		13
		Default:	128k
		Description:	This setting determines the audio bitrate quality. This number is entered as kilobytes.
				The audio bitrate quality of 128k is generally good enough for most videos. Users seeking
				very high audio quality would want an audio bitrate of 256k or 320k.
				
	'Resolution'
		ID:		14
		Default:	640x360
		Description:	This setting determines the resolution that the video will be converted to. The
				resolution of 640x360 is good for posting to forums because of its smaller file size.
				
	'Start time'
		ID:		15
		Default:	00:00:00
		Description:	This setting determines the start time of the video. Parts of the video before this
				timestamp will be trimmed off and discarded.
				
	'Stop time'
		ID:		16
		Default:	No stop time
		Description:	This setting determines the stop time of the video. Parts of the video after this
				timestamp will be trimmed off and discarded.
				
	'Strip audio?'
		ID:		17
		Default:	False
		Description:	This setting determines whether or not to keep the audio. If this is set to 'True',
				the audio will be stripped from the video and discarded. This is useful for posting
				to forums that do not allow videos that have audio.
				
	'Strip video?'
		ID:		18
		Default:	False
		Description:	This setting determines whether to strip the video from the file. If this setting is
				set to 'True', the video will be discarded and only the audio will be kept. This is
				basically using option '2' of the main menu, '2 - Download audio'.
	


#

**New in version 1.1.0**, users can list playlists in the `audioplaylist.txt` and `videoplaylist.txt` files located in `C:\Users\%USERNAME%\Youtube-dl`. List any playlist URL's one line at a time that you would like to download video from in the `videoplaylist.txt` file. The same goes for the `audioplaylist.txt` file. To download from these files, choose option `3` in the main menu or use the `-FromFiles` parameter switch if calling the script from the command line. When downloading from the `videoplaylist.txt` file, use the conversion options in the Settings menu to convert all of the videos to one single file type.

**New in version 1.2.0**, users can convert downloaded videos to other formats using  ffmpeg options which can be modified in option `4` of the main menu, "Settings". Only videos being downloaded will be converted, not audio downloads. This feature has not yet been implemented into the parameters that can be passed to the script.

#

For advanced users, the youtube-dl.ps1 script, which is found in the folder `C:\Users\%USERNAME%\Youtube-dl\scripts`, can be passed parameters so that this script can be used in conjunction with other scripts or forms of automation. Make sure to add the `C:\Users\%USERNAME%\Youtube-dl\bin` folder to your PATH.

**youtube-dl.ps1's parameters are as followed:**

	-Video
		Download a video.
    
	-Audio
		Download only the audio of a video.
    
	-FromFiles
		Download playlist URL's listed in the "audioplaylist.txt" and "videoplaylist.txt" files located 
		in "C:\Users\%USERNAME%\Youtube-dl". The -URL parameter will be ignored if -FromFiles is used.
    
	-URL <URL>
		The URL of the video to be downloaded from.
    
	-OutputPath <path>
		(Optional) The location to which the file will be downloaded to.


# CHANGE LOG

	1.2.6	November 16th, 2017
		Added option to download the entire playlist that a video resides in.

	1.2.5	November 15th, 2017
		Simplified and cleaned up some code.
		Updated the readme file.

	1.2.4	July 12th, 2017
		Added ability to choose whether to use the youtube-dl download archive when downloading playlists.

	1.2.3	July 11th, 2017
		Edited Youtube-dl_Installer.ps1 to uninstall the script using the -Uninstall parameter.
		Added a shortcut for uninstalling the script and its files.

	1.2.2	July 3rd, 2017
		Cleaned up code.

	1.2.1	June 22nd, 2017
		Uploaded the project to Github.
		Condensed installer to one PowerShell script.
		Edited documentation.
		
	1.2.0	March 30th, 2017
		Implemented ffmpeg video conversion.
		
	1.1.0	March 27th, 2017
		Implemented videoplaylist.txt and audioplaylist.txt downloading.


# ADDITIONAL NOTES

Please support the development of youtube-dl and ffmpeg. The programs youtube-dl and ffmpeg can be found at the following links:

https://youtube-dl.org/

https://www.ffmpeg.org/


THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
