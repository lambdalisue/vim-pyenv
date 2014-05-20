"==============================================================================
" vim-pyenv
"
" Correctly import modules of pyenv specified python.
"
" Author:   Alsiue <lambdalisue@hashnote.net>
" License:  MIT license
"==============================================================================
let s:save_cpo = &cpo
set cpo&vim

" Variables
let s:repository_root = fnameescape(expand('<sfile>:p:h:h'))

"------------------------------------------------------------------------------
" Utility functions
"------------------------------------------------------------------------------
" call pyenv with args
function! s:pyenv(args)
  return system(g:pyenv#pyenv_exec . " " . a:args)
endfunction

" call external python with args
function! s:external_python(args)
  return system(g:pyenv#python_exec . " " . a:args)
endfunction

"------------------------------------------------------------------------------
" pyenv manipulation
"------------------------------------------------------------------------------
" return the name of selected environment on pyenv
function! pyenv#pyenv_name()
  return split(s:pyenv('version'))[0]
endfunction

function! pyenv#display_pyenv_name()
  echo pyenv#pyenv_name()
endfunction

" return the activated pyenv python name
function! pyenv#activated_pyenv_name()
  if exists('g:pyenv#activated_name')
    return g:pyenv#activated_name
  else
    return ""
  endif
endfunction

function! pyenv#display_activated_pyenv_name()
  echo pyenv#activated_pyenv_name()
endfunction

" return the list of installed environment names on pyenv
" The result can be filtered with `prefix`
function! pyenv#pyenv_names(prefix)
  let original = split(s:pyenv("versions"), "\n")
  let venvs = []
  for row in original
    if len(row) <= 3
      continue
    endif
    " remove selection marker and address
    let name = split(substitute(row, "\*", "", "g"))[0]
    " add item which start from prefix
    if name =~ '^'.a:prefix
      call add(venvs, name)
    endif
  endfor
  return venvs
endfunction

" display the list of installed environment names on pyenv
function! pyenv#display_pyenv_names()
  for name in pyenv#versions("")
    echo name
  endfor
endfunction


"------------------------------------------------------------------------------
" python (internal/external) manipulation
"------------------------------------------------------------------------------
" return the version of internal python
function! pyenv#py_version()
  PyenvPython pyenv_vim.py_version()
  return return_value
endfunction

function! pyenv#display_py_version()
  echo pyenv#py_version()
endfunction

" return the version of external python
function! pyenv#external_py_version()
  let py_version = s:external_python("--version")
  return split(py_version)[1]
endfunction

function! pyenv#display_external_py_version()
  echo pyenv#external_py_version()
endfunction

"------------------------------------------------------------------------------
" main
"------------------------------------------------------------------------------
" force internal python version
function! pyenv#force_py_version(py_version, verbose)
  let filename = s:repository_root . "/initialize.py"
  if a:py_version == 2
    command! -nargs=1 PyenvPython python <args>
    execute 'pyfile ' . filename
  elseif a:py_version == 3
    command! -nargs=1 PyenvPython python3 <args>
    execute 'py3file ' . filename
  else
    echoerr "Unknown py_version '" . a:py_version . "' was specified"
    return
  endif
  if g:pyenv#force_py_version != a:py_version
    let g:pyenv#force_py_version = a:py_version
    if a:verbose
      echomsg "Python " . a:py_version . " is activated."
    endif
  endif
endfunction

" synchronize the internal python version to the external python version
function! pyenv#auto_force_py_version(verbose)
  if !(has('python') && has('python3'))
    echoerr "pyenv#auto_force_py_version feature require +python and +python3"
    return
  endif

  let py_version = pyenv#py_version()
  let external_py_version = pyenv#external_py_version()
  let py_version_prefix = split(py_version, '\.')[0]
  let external_py_version_prefix = split(external_py_version, '\.')[0]
  if py_version_prefix != external_py_version_prefix
    " synchronize
    call pyenv#force_py_version(external_py_version_prefix, a:verbose)
  endif
  if g:pyenv#auto_force_py_version_jedi
    if exists('jedi#force_py_version')
      call jedi#force_py_version(g:pyenv#force_py_version)
      echomsg "jedi#force_py_version is called with ".g:pyenv#force_py_version
    endif
  endif
endfunction

" activate the specified name of the pyenv
function! pyenv#activate(name, verbose)
  if exists("g:pyenv#activated_name")
    " deactivate pyenv first
    call pyenv#deactivate(0)
  endif

  let name = a:name
  let current_name = pyenv#pyenv_name()
  if len(name) == 0
    " the name is not specified thus use current pyenv
    let name = current_name
  elseif name != current_name || len(current_name) == 0
    " new pyenv name is specified, activate the new one
    call s:pyenv(g:pyenv#pyenv_application_scope . " " . name)
  endif
  " automatically force py version on vim-pyenv
  if g:pyenv#auto_force_py_version
    call pyenv#auto_force_py_version(a:verbose)
  endif
  " update the sys.path of internal python
  PyenvPython pyenv_vim.activate(vim.vars['pyenv#python_exec'])
  let g:pyenv#activated_name = name
  if a:verbose
    echomsg "'" . name . "' is activated."
  endif
endfunction

" deactivate the pyenv
function! pyenv#deactivate(verbose)
  if exists("g:pyenv#activated_name")
    " deactivate pyenv
    call s:pyenv(g:pyenv#pyenv_application_scope . " --unset")
    " automatically force py version on vim-pyenv
    if g:pyenv#auto_force_py_version
      call pyenv#auto_force_py_version(a:verbose)
    endif
    " restore the sys.path of internal python
    PyenvPython pyenv_vim.deactivate()
    if a:verbose
      echomsg "'" . g:pyenv#activated_name . "' is deactivated."
    endif
    unlet! g:pyenv#activated_name
  endif
endfunction


"------------------------------------------------------------------------------
" default settings
"------------------------------------------------------------------------------
let s:settings = {
      \ 'enable': 1,
      \ 'auto_activate': 1,
      \ 'force_py_version': 2,
      \ 'auto_force_py_version': has('python') && has('python3'),
      \ 'auto_force_py_version_jedi': 1,
      \ 'pyenv_application_scope': "'local'",
      \ 'pyenv_exec': "'auto'",
      \ 'python_exec': "'python'",
      \ }

function! s:init()
  for [key, val] in items(s:settings)
    if !exists('g:pyenv#'.key)
      exe 'let g:pyenv#'.key.' = '.val
    endif
  endfor
  " automatically detect the pyenv executable file
  if g:pyenv#pyenv_exec == 'auto'
    let DEFAULT_PYENV_EXEC = "~/.pyenv/bin/pyenv"
    if $PYENV_ROOT
      let g:pyenv#pyenv_exec = $PYENV_ROOT . "/bin/pyenv"
    elseif filereadable(expand(DEFAULT_PYENV_EXEC))
      let g:pyenv#pyenv_exec = DEFAULT_PYENV_EXEC
    else
      echoerr "vim-pyenv cannot find the pyenv executable file."
      echoerr "Please specify the executable pyenv path by g:pyenv#pyenv_exec"
      let pyenv#enable = 0
      finish
    endif
    let g:pyenv#pyenv_exec = expand(g:pyenv#pyenv_exec)
  endif
endfunction

call s:init()

" ------------------------------------------------------------------------
" python initialization
" ------------------------------------------------------------------------
if has('python') && has('python3')
  call pyenv#force_py_version(g:pyenv#force_py_version, 0)
elseif has('python')
  call pyenv#force_py_version(2, 0)
elseif has('python3')
  call pyenv#force_py_version(3, 0)
else
  if !exists("g:pyenv#squelch_py_warning")
    echoerr "vim-pyenv requires vim compiled with +python and/or +python3"
  endif
  finish
end

let &cpo = s:save_cpo
unlet! s:save_cpo
