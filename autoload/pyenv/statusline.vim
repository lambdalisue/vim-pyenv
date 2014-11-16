"==============================================================================
" vim-pyenv statusline component
"
" Author:   Alsiue <lambdalisue@hashnote.net>
" License:  MIT license
"==============================================================================
let s:save_cpo = &cpo
set cpo&vim

function! pyenv#statusline#component()
  if g:pyenv#enable == 0
    return ""
  endif
  let py_version = pyenv#py_version()
  let pyenv_name = pyenv#activated_pyenv_name()
  if len(pyenv_name) > 0
    if py_version != pyenv_name
      let statusline = g:pyenv#statusline#component#long_pattern
    else
      let statusline = g:pyenv#statusline#component#short_pattern
    endif
  else
    let statusline = g:pyenv#statusline#component#without_pattern
  endif
  " substitute
  let statusline = substitute(statusline, "%e", pyenv_name, "g")
  let statusline = substitute(statusline, "%v", py_version, "g")
  return statusline
endfunction

let s:settings = {
      \ 'long_pattern': "'⌘ %e(%v)'",
      \ 'short_pattern': "'⌘ %e'",
      \ 'without_pattern': "''",
      \ }

function! s:init()
  for [key, val] in items(s:settings)
    if !exists('g:pyenv#statusline#component#'.key)
      exe 'let g:pyenv#statusline#component#'.key.' = '.val
    endif
  endfor
endfunction

call s:init()

let &cpo = s:save_cpo
unlet! s:save_cpo
"vim: foldlevel=0 sts=2 sw=2 smarttab et ai textwidth=0 fdm=marker
