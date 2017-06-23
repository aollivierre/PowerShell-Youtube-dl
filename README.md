# PowerShell-Youtube-dl
https://github.com/ForestFrog/PowerShell-Youtube-dl

A script used to operate the youtube-dl command line program.


**Scripts written by ForestFrog**

**June 22th, 2017**

**v1.2.1**
#

 - [INSTALLATION](#installation)
 - [USAGE](#usage)
 - [CHANGE LOG](#change-log)
 - [ADDITIONAL NOTES](#additional-notes)
 
#

# INSTALLATION

These scripts require Windows PowerShell to function. PowerShell can be downloaded
here: https://www.microsoft.com/en-us/download/details.aspx?id=50395

**Download PowerShell-Youtube-dl script:**

https://github.com/ForestFrog/PowerShell-Youtube-dl/archive/master.zip

Download the project .zip file, extract it to a folder, and run the `Youtube-dl_Installer.ps1` shortcut. The script will be installed to the folder `C:\Users\%USERNAME%\Youtube-dl`. A desktop shortcut and a Start Menu shortcut will be created. Run either of these to use the script. 

To update the script, delete the following files and folders, download the new version and install it:

	C:\Users\%USERNAME%\Youtube-dl\bin
	C:\Users\%USERNAME%\Youtube-dl\scripts
	C:\Users\%USERNAME%\Youtube-dl\README.md\
Make sure you don't delete any of the .txt files!

#

To uninstall these scripts and youtube-dl, delete the Youtube-dl folders located in `C:\Users\%USERNAME%\Youtube-dl` and `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Youtube-dl`, as well as the desktop shortcut.


# USAGE

Run either the desktop shortcut or the Start Menu shortcut. Choose to download either video or audio, and then right click and paste the URL into the prompt. The URL you provide it can either be the URL of a video or the URL of a playlist.

Video files are downloaded to `C:\Users\%USERNAME%\Videos\Youtube-dl` and audio files are downloaded to `C:\Users\%USERNAME%\Music\Youtube-dl`. Playlists will be downloaded into their own subfolders.

Upon being ran for the first time, the script will generate the `downloadarchive.txt`, `audioplaylist.txt`, and `videoplaylist.txt` files. The `downloadarchive.txt` file keeps a record of videos that have been downloaded from playlists. Any videos that the user downloads from a playlist will be added to this file and will be skipped if the playlist is downloaded again.

**New in version 1.1.0**, users can list playlists in the `audioplaylist.txt` and `videoplaylist.txt` files located in `C:\Users\%USERNAME%\Youtube-dl`. List any playlist URL's one line at a time that you would like to download video from in the `videoplaylist.txt` file. The same goes for the `audioplaylist.txt` file. To download from these files, choose option `3` in the main menu or use the -FromFiles parameter switch if calling the script from the command line. Currently, playlists downloaded form the video playlist will be automatically converted to .webm

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

	1.2.1	June 22nd, 2017
		Uploaded the project to Github.
		Condensed installer to one PowerShell script
		Edited documentation
		
	1.2.0	March 30th, 2017
		Implemented ffmpeg video conversion.
		
	1.1.0	March 27th, 2017
		Implemented videoplaylist.txt and audioplaylist.txt downloading.


# ADDITIONAL NOTES

Please support the development of youtube-dl and ffmpeg. They are fantastic programs. Youtube-dl and ffmpeg can be found at the following links:

https://youtube-dl.org/

https://www.ffmpeg.org/


THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
