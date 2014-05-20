if exists("g:pyenv_loaded")
  finish
endif
let g:pyenv_loaded = 1

let s:save_cpo = &cpo
set cpo&vim

command! -bar -nargs=? -complete=customlist,s:CompletePyenv 
      \ PyenvActivate :call pyenv#activate(<q-args>, 1)
command! -bar PyenvDeactivate :call pyenv#deactivate(1)
command! -bar PyenvList :call pyenv#display_pyenv_names()
command! -bar PyenvName :call pyenv#display_pyenv_name()
command! -bar PyenvVersion :call pyenv#display_py_version()
command! -bar PyenvExternalVersion :call pyenv#display_external_py_version()

function! s:CompletePyenv(arg_lead, cmd_line, cursor_pos)
    return pyenv#pyenv_names(a:arg_lead)
endfunction

if g:pyenv#enable && g:pyenv#auto_activate == 1
  call pyenv#activate("", 0)
endif

let &cpo = s:save_cpo
"vim: foldlevel=0 sts=2 sw=2 smarttab et ai textwidth=0 fdm=marker                        
