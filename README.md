# PowerShell-Youtube-dl
A script used to operate the youtube-dl command line program.

# Scripts written by ForestFrog
# June 22th, 2017
# v1.2.1
https://github.com/ForestFrog/PowerShell-Youtube-dl


# Installation

These scripts require Windows PowerShell to function. PowerShell can be downloaded
here: https://www.microsoft.com/en-us/download/details.aspx?id=50395

Run the `Youtube-dl_Installer.ps1` shortcut. A desktop shortcut and a Start Menu shortcut will be created. Run either of these to use the script.

A folder named `\Youtube-dl` will be created in the user's profile folder as well. This folder contains .exe files used by youtube-dl and ffmpeg. Additionally, the `downloadarchive.txt` file is stored here. The `downloadarchive.txt` file keeps a record of videos that have been downloaded from playlists. Any videos that the user downloads from a playlist will be added to this file and will be skipped if the playlist is downloaded again.

To uninstall these scripts and youtube-dl, delete the Youtube-dl folders located in `C:\Users\%USERNAME%\Youtube-dl` and `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Youtube-dl`, as well as the desktop shortcut.


# Usage

Run either the desktop shortcut or the Start Menu shortcut. Choose to download either video or audio, and then right click and paste the URL into the prompt. The URL you provide it can either be the URL of a video or the URL of a playlist.

Video files are downloaded to `C:\Users\%USERNAME%\Videos\Youtube-dl` and audio files are downloaded to `C:\Users\%USERNAME%\Music\Youtube-dl`. Playlists will be downloaded into their own subfolders.

New in version 1.1, users can list playlists in the "audioplaylist.txt" and "videoplaylist.txt" files located in `C:\Users\%USERNAME%\Youtube-dl`. List any playlist URL's one line at a time that you would like to download video from in the `videoplaylist.txt` file. The same goes for the `audioplaylist.txt` file. To download from these files, choose option `3` in the main menu or use the -FromFiles parameter switch if calling the script from the command line. Currently, playlists downloaded form the video playlist will be automatically converted to .webm

New in version 1.2, users can convert downloaded videos to other formats using  ffmpeg options which can be modified in option `4` of the main menu, "Settings". Only videos being downloaded will be converted, not audio downloads. This feature has not yet been implemented into the parameters that can be passed to the script.

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


# Additonal Notes

The youtube-dl_installation_files folder contains a folder named "bin". This folder contains the .exe files of youtube-dl and ffmpeg in case the current versions cannot be downloaded during the installation process. If your folder "C:\Users\%USERNAME%\Youtube-dl\bin\" does not have four .exe files in it, then download them from their respective sites or copy the .exe files from the  installation file's bin folder to "C:\Users\%USERNAME%\Youtube-dl\bin\". Youtube-dl and ffmpeg can be downloaded from the following links:

https://youtube-dl.org/
https://www.ffmpeg.org/


Additionally, I do not claim to own the code to youtube-dl or ffmpeg or claim to have written any of it. I simply wrote the powershell scripts that utilize these fantastic pieces of software. Please support the development of youtube-dl and ffmpeg if you find them useful. Thank you.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
