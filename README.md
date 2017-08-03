# octoprint.sh
Push to octoprint from Simplify3d, a no-dependencies bash script port of github.com/MoonshineSG/Simplify3D-to-OctoPrint 

Currently only tested / compatible with macOS

# Usage

Recommend symlinking somewhere in path for easy usage:

```sudo ln -s [repo_path]/octoprint.sh /usr/local/bin/octoprint```

To upload gcode to octoprint:

```/usr/local/bin/octoprint -s <OCTOPRINT_URL> -k <API_KEY> -g <GCODE_FILE_PATH>```

From Simplify3D, edit a process, go to **Scripts**, and enter the following under **Additional terminal commands for post processing**:

```<FULL_PATH_TO_OCTOPRINT> -s <OCTOPRINT_URL> -k <API_KEY> -g "[output_filepath]"```

Example:

```/usr/local/bin/octoprint -s http://octopi.local -k a2WEL2J32LHJ2LJ2LK2J -g "[output_filepath]"```

When you print, click **Save Toolpaths to Disk** and save the gcode file. The script will automatically upload the file and place it in the trash.
