from os import nil
import strutils

## Appdirs is a small module that finds the dirs for you to app in.
##
## More specifically, appdirs contains a number of functions that will return the
## correct directory for the platform you are on.  (All functions also allow you
## to override the platform.)  Note that these directories are simply strings
## naming possible directories.  You will need to ensure that the directory you
## wish to use is available yourself.
##
## There are generally three procs for each type of directory.  The first will
## return the base directory, whilst the other two will return the specific
## directory for a given application.  Of the more specialised procs, one takes
## a `TAppl` object (initialised using the `application()` proc) and the other
## takes all the arguments required to create a `TAppl` object, creates and
## initialises one under the hood, and then uses that in this function.  It is
## generally recommended to use the `TAppl` proc in most circumstances.
##
## This module assumes that the available OSs are either Windows or Mac OSX, or
## otherwise a "UNIX-y" variant.  This should cover most operating systems.
## There are no checks in place for systems that don't fall into the standard
## range of operating systems, but if you're in that situation you probably
## don't need this module.



type
    TAppl* = object of TObject
        name*: string
        author*: string
        version*: string
        use_roaming*: bool

## USEFUL PROCS

proc get_platform(platform:string = nil): string {.inline noSideEffect.} =
    if platform == nil:
        return hostOS
    else:
        return platform

proc empty_exists(name:string): bool {.inline.} =
    if not os.exists_env(name):
        return false
    else:
        return os.get_env(name).strip() != ""


## TAPPL CONSTRUCTOR

proc application(name:string, author:string=nil, version:string=nil, roaming:bool=false): TAppl =
    var auth: string
    if author == nil:
        auth = name
    else:
        auth = author

    result = TAppl(name: name, author: auth, version: version, use_roaming: roaming)


## USER DATA

proc user_data*(roaming: bool = false, platform: string = nil): string = 
    var plat = get_platform(platform)

    if plat == "macosx":
        return os.join_path(os.get_env("HOME"), "Library", "Application Support")
    elif plat == "windows":
        if (not roaming) and os.exists_env("LOCALAPPDATA"):
            return os.get_env("APPDATA")
        else:
            return os.get_env("LOCALAPPDATA")
    else:
        if empty_exists("XDG_DATA_HOME"):
            return os.get_env("XDG_DATA_HOME")
        else:
            return os.join_path(os.get_env("HOME"), ".local", "share")

proc user_data*(appl: TAppl, platform: string = nil): string =
    var path = user_data(appl.use_roaming, platform)

    if get_platform(platform) == "windows":
        path = os.join_path(path, appl.author, appl.name)
    else:
        path = os.join_path(path, appl.name)

    if appl.version != nil:
        path = os.join_path(path, appl.version)

    return path

proc user_data*(name:string, author:string=nil, version:string=nil, roaming:bool=false, platform:string=nil): string =
    ## Gets the data directory given the details of an application.
    ## This proc creates an application from the arguments, and uses it to call the
    ## `user_data(TAppl)` proc.
    return application(name, author, version, roaming).user_data(platform)


## USER CONFIG

proc user_config*(roaming: bool = false, platform: string = nil): string =
    var plat = get_platform(platform)

    if plat == "macosx" or plat == "windows":
        return user_data(roaming, plat)
    else:
        if empty_exists("XDG_CONFIG_HOME"):
            return os.get_env("XDG_CONFIG_HOME")
        else:
            return os.join_path(os.get_env("HOME"), ".config")

proc user_config*(appl: TAppl, platform: string = nil): string =
    var path = user_config(appl.use_roaming, platform)

    if get_platform(platform) == "windows":
        path = os.join_path(path, appl.author, appl.name)
    else:
        path = os.join_path(path, appl.name)

    if appl.version != nil:
        path = os.join_path(path, appl.version)

    return path

proc user_config*(name:string, author:string=nil, version:string=nil, roaming:bool=false, platform:string=nil): string =
    ## Gets the config directory given the details of an application.
    ## This proc creates an application from the arguments, and uses it to call the
    ## `user_config(TAppl)` proc.
    return application(name, author, version, roaming).user_config(platform)


## USER CACHE

proc generic_user_cache(platform: string =  nil): string =
    ## Gets the local users' cache directory.
    ##
    ## Note, on Windows there is no "official" cache directory, so instead this procedure
    ## returns the users's Application Data folder.    Use the `user_cache(TAppl)` version
    ## to with `force_cache = true` to add an artifical `Cache` directory inside your
    ## main appdata directory.
    ##
    ## On all other platforms, there is a cache directory to use.

    var plat = get_platform(platform)

    if plat == "windows":
        return user_data(false, platform)

    elif plat == "macosx":
        return os.join_path(os.get_env("HOME"), "Library", "Caches")

    else:
        if empty_exists("XDG_CACHE_HOME"):
            return os.get_env("XDG_CACHE_HOME")
        else:
            return os.join_path(os.get_env("HOME"), ".cache")

proc user_cache*(appl: TAppl, force_cache:bool = true, platform: string = nil): string =
    ## Gets the cache directory for a given application.
    ##
    ## Note, on Windows there is no "official" cache directory, so instead this procedure
    ## returns this application's Application Data folder.  If `force_cache = true` (the
    ## default) this procedure will add an artificial `Cache` directory inside the app's
    ## appdata folder.  Otherwise, this just returns the user's app data directory.
    ## 
    ## On all other platforms, there is a cache directory to use.

    var path = generic_user_cache(platform)

    if get_platform(platform) == "windows":
        path = os.join_path(path, appl.author, appl.name)

        if force_cache:  # Be assertive, give windows users a real cache dir
            path = os.join_path(path, "Cache")

    else:
        path = os.join_path(path, appl.name)

    if appl.version != nil:
        path = os.join_path(path, appl.version)

    return path

proc user_cache*(name:string, author:string=nil, version:string=nil, roaming:bool=false,
        force_cache:bool=true, platform:string=nil): string =
    ## Gets the cache directory given the details of an application.
    ## This proc creates an application from the arguments, and uses it to call the
    ## `user_cache(TAppl)` proc.

    return application(name, author, version, roaming).user_cache(force_cache, platform)


## USER LOGS

proc generic_user_logs(platform: string = nil): string =
    ## Gets the logs directory for a given platform.
    ## 
    ## Note that the only platform for which there is an official user logs directory
    ## is macosx.  On Windows, this proc returns the non-roaming user data directory,
    ## while for UNIX-y platforms this proc returns the cache directory.  See the
    ## `TAppl` version of this proc for more details.
    var plat = get_platform(platform)

    if plat == "windows":
        return user_data(false, platform)
    elif plat == "macosx":
        return os.join_path(os.get_env("HOME"), "Library", "Logs")
    else:
        return user_cache(platform)

proc user_logs(appl: TAppl, force_logs: bool = true, platform: string = nil): string =
    ## Gets the logs directory for a platform given application details.
    ##
    ## Note that the only platform for which there is an official user logs directory
    ## is macosx.  Otherwise, this returns the user data directory (for Windows) or the
    ## user cache directory (UNIX-y platforms), with a "logs" directory appended.
    ## 
    ## If force_logs is passed in and evaluates to false, this proc does not append
    ## the extra "logs" directory.
    var path = generic_user_logs(platform)

    if get_platform(platform) == "windows":
        path = os.join_path(path, appl.author, appl.name)

        if force_logs:
            path = os.join_path(path, "Logs")

    else:
        path = os.join_path(path, appl.name)

        if get_platform(platform) != "macosx" and force_logs:
            path = os.join_path(path, "logs")

    if appl.version != nil:
        path = os.join_path(path, appl.version)

    return path

proc user_logs*(name:string, author:string=nil, version:string=nil, roaming:bool=false,
        force_logs:bool=true, platform:string=nil): string =
    ## Gets the logs directory given the details of an application.
    ## This proc creates an application from the arguments, and uses it to call the
    ## `user_logs(TAppl)` proc.

    return application(name, author, version, roaming).user_logs(force_logs, platform)
