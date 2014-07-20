# Appdirs

*Appdirs finds the dirs for you to app in.*

Appdirs is a nimrod port of my JS [AppDirectory](https://github.com/MrJohz/appdirectory) module, which itself is a port of the Python [appdirs](https://github.com/ActiveState/appdirs) module.  It's fairly basic, and has roughly the same API as the JS version.  The official docs can be found in the docs directory of this repo.

## Usage:

```nimrod
import appdirs
let app = application("AppName", "AuthorName", "version", roaming=false)

echo user_data(app)
# -> /home/user/.local/share/AppName/version

echo user_config(app, platform="windows")
# -> C:\Users\<censored>\AppData\Local\AuthorName\AppName\version
```

There are functions for the user data folder, the user config folder, the logs folder and the cache folder.  The platform can be any of the string that nimrod's hostOS variable can resolve to, although Appdirs only checks for "macosx" and "windows", and assumes all of the other platforms to be UNIX-y.  If this is not the case, and you have a platform that can provide sensible data, config, logs, and cache folders, fork and send me a pull request.

## To Do List:

- Add site* functions
- Get round to adding tests