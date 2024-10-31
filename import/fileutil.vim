vim9script

# Returns a string that is either a readable path ending in the given filename
# or the emptry string if no such file was found above the given path.
export def FindFileAbove(filename: string, path: string): string
    var prefix = path
    while !filereadable(prefix .. "/" .. filename)
        prefix = fnamemodify(prefix, ":h")
        if prefix == "/"
            return ""
        endif
    endwhile
    return prefix .. "/" .. filename
enddef

