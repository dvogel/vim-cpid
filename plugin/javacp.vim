vim9script

import "javacp.vim"

augroup CpidJavaLoading
    autocmd!
    autocmd BufRead *.java javacp.InitializeJavaBuffer()
augroup END

command! CpidReconnect :call javacp.ConnectToCpid()
command! CpidBufInit :call javacp.InitializeJavaBuffer()
command! FixMissingImports :call javacp.FixMissingImports()
command! ReindexProject :call javacp.ReindexProject()
command! ReindexClasspath :call javacp.ReindexClasspath()
command! CheckForMissingImports :call javacp.CheckBuffer()

