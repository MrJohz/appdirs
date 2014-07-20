import nake
import strutils

const
    DOCS_FILES = ["appdirs.nim"]
    DOCS_DEST = "docs"

task "clean", "Removes nimcache folders, compiled exes":
    direshell("rm -rf nimcache")
    direshell("rm -rf appdirs")

task "docs", "Adds documentation to the docs/ directory":
    direshell("rm", "-rf", DOCS_DEST & "/*")
    for source in DOCS_FILES:
        let dest = DOCS_DEST & "/" & source.change_file_ext(".html")
        direshell("nimrod", "doc2", "--verbosity:0", "-o:" & dest, source)
