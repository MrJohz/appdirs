import nake
import os
import strutils

const
    DOCS_FILES = ["appdirs.nim"]
    DOCS_DEST = "docs"

task "clean", "Removes nimcache folders, compiled exes":
    removeDir("nimcache")
    removeFile("appdirs")

task "docs", "Adds documentation to the docs/ directory":
    DOCS_DEST.removeDir
    DOCS_DEST.createDir
    for source in DOCS_FILES:
        let dest = DOCS_DEST / source.change_file_ext(".html")
        direshell("nimrod", "doc2", "--verbosity:0", "-o:" & dest, source)
