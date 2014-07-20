from os import nil
import strutils

## Appdirs is a small module that finds the dirs for you to app in.
##
## More specifically, appdirs contains a number of functions that will return the
## correct directory for the platform you are on.  (All functions also allow you
## to override the platform.)
##
## There are generally three procs for each type of directory.  The first will
## return the base directory, whilst the other two will return the specific
## directory for a given application.  Of the more specialised procs, one takes
## a `TAppl` object (initialised using the `application()` proc) and the other
## takes all the arguments required to create a `TAppl` object, creates and
## initialises one under the hood, and then uses that in this function.  It is
## generally recommended to use the `TAppl` proc in most circumstances.



type
    TAppl = object of TObject
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
    return application(name, author, version, roaming).user_config(platform)


## USER CACHE

proc user_cache*(platform: string =  nil): string =
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
        if empty_exists("LOCALAPPDATA"):
            return os.get_env("LOCALAPPDATA")
        else:
            return os.get_env("APPDATA")

    elif plat == "macosx":
        return os.join_path(os.get_env("HOME"), "Library", "Caches")

    else:
        if empty_exists("XDG_CACHE_HOME"):
            return os.get_env("XDG_CACHE_HOME")
        else:
            return os.join_path(os.get_env("HOME"), ".cache")

proc user_cache*(appl: TAppl, force_cache:bool = false, platform: string = nil): string =
    ## Gets the cache directory for a given application.
    ##
    ## Note, on Windows there is no "official" cache directory, so instead this procedure
    ## returns this application's Application Data folder.  If `force_cache = true` is
    ## passed in, this procedure will add an artificial `Cache` directory inside the main
    ## appdata folder.
    ## 
    ## On all other platforms, there is a cache directory to use.

    var path = user_config(platform)

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
        force_cache:bool=false, platform:string=nil): string =
    ## Gets the cache directory given the details of an application.
    ## This proc creates an application from the arguments, and uses it to call the
    ## `user_cache(TAppl)` proc.

    return application(name, author, version, roaming).user_cache(force_cache, platform)
