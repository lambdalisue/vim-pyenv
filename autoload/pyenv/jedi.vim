"==============================================================================
" vim-pyenv jedi-vim support
"
" Author:   Alsiue <lambdalisue@hashnote.net>
" License:  MIT license
"==============================================================================
let s:save_cpo = &cpo
set cpo&vim

" return the version of internal python
function! pyenv#jedi#py_version()
  Python pyenv_vim.py_version()
  return return_value
endfunction

function! pyenv#jedi#display_py_version()
  echo pyenv#jedi#py_version()
endfunction

function! pyenv#jedi#force_py_version(py_version, verbose)
  call jedi#force_py_version(a:py_version)
  if !exists('g:pyenv#jedi#internal_py_version') ||
        \ g:pyenv#jedi#internal_py_version != a:py_version
    if a:verbose > 0
      echomsg "Python " . a:py_version . " is activated on jedi"
    endif
    let g:pyenv#jedi#internal_py_version = a:py_version
  endif
endfunction

let s:settings = {
      \ 'auto_force_py_version': 1,
      \ }

function! s:init()
  for [key, val] in items(s:settings)
    if !exists('g:pyenv#jedi#'.key)
      exe 'let g:pyenv#jedi#'.key.' = '.val
    endif
  endfor
endfunction

call s:init()

let &cpo = s:save_cpo
unlet! s:save_cpo
"vim: foldlevel=0 sts=2 sw=2 smarttab et ai textwidth=0 fdm=marker
