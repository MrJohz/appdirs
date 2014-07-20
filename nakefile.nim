import nake
import strutils

const
    DOCS_SOURCE = "lib"
    DOCS_DEST = "docs"

task "clean", "Removes nimcache folders, compiled exes":
    direshell("rm -rf */**nimcache")
    direshell("rm -rf lib/appdirs")

task "docs", "Adds documentation to the docs/ directory":
    direshell("rm", "-rf", DOCS_DEST & "/*")
    for source in walk_files(DOCS_SOURCE & "/*.nim"):
        let dest = source.change_file_ext(".html").replace(DOCS_SOURCE, DOCS_DEST)
        direshell("nimrod", "doc2", "--verbosity:0", "-o:" & dest, source)
