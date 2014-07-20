import unittest

import os
import strtabs

suite "Test `user_data`":
  setup:
    var old_env = newStringTable()

    old_env["HOME"] = os.get_env("HOME")
    os.put_env("HOME", os.join_paths("/home", "awesomeuser"))

    old_env["APPDATA"] = os.get_env("APPDATA")
    os.put_env("APPDATA", os.join_paths("C:", "Users", "awesomeuser", "AppData", "Roaming"))
    old_env["LOCALAPPDATA"] = os.get_env("LOCALAPPDATA")
    os.put_env("LOCALAPPDATA", os.join_paths("C:", "Users", "awesomeuser", "AppData", "Local"))
    old_env["PROGRAMDATA"] = os.get_env("PROGRAMDATA")
    os.put_env("PROGRAMDATA", os.join_paths("C:", "ProgramData"))

    var ad = a