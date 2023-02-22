vim9script

import "javacp.vim"

augroup CpidJavaLoading
    autocmd!
    autocmd BufRead *.java javacp.InitializeJavaBuffer()
augroup END

