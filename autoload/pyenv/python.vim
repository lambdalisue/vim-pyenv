let s:save_cpo = &cpo
set cpo&vim


let s:P = pyenv#utils#import('System.Filepath')
let s:repository_root = fnameescape(expand('<sfile>:p:h:h:h'))
let s:selected_major_version = 0


" Private
function! s:is_enabled() abort " {{{
  return has('pythonx') || has('python') || has('python3')
endfunction " }}}

function! s:get_external_version() abort " {{{
  if !executable(g:pyenv#python_exec)
    return ''
  endif
  let result = pyenv#utils#system(join([
        \ g:pyenv#python_exec,
        \ '--version',
        \]))
  if result.status == 0
    return split(result.stdout)[1]
  endif
  return ''
endfunction " }}}
function! s:get_external_major_version() abort " {{{
  let external_version = s:get_external_version()
  if empty(external_version)
    return 0
  endif
  return get(split(external_version, '\.'), 0, '0')
endfunction " }}}
function! s:get_internal_version() abort " {{{
  return s:exec_code('pyenv_vim.py_version()')
endfunction " }}}
function! s:get_internal_major_version() abort " {{{
  if s:selected_major_version == 0
    if has('python') && has('python3')
      return get(g:, 'pyenv#default_major_version', 2)
    elseif has('python')
      return 2
    elseif has('python3')
      return 3
    endif
  endif
  return s:selected_major_version
endfunction " }}}
function! s:set_internal_major_version(major) abort " {{{
  if a:major == 2 && has('python')
    let s:selected_major_version = 2
    return 1
  elseif a:major == 3 && has('python3')
    let s:selected_major_version = 3
    return 1
  endif
  return 0
endfunction " }}}
function! s:auto_internal_major_version() abort " {{{
  let external_major = s:get_external_major_version()
  call s:set_internal_major_version(external_major)
endfunction " }}}

function! s:exec_file(file, ...) abort " {{{
  let major = get(a:000, 0, s:get_internal_major_version())
  if major == 2 && has('python')
    execute printf('pyfile %s', fnameescape(a:file))
  elseif major == 3 && has('python3')
    execute printf('py3file %s', fnameescape(a:file))
  endif
endfunction " }}}
function! s:exec_code(code, ...) abort " {{{
  let major = get(a:000, 0, s:get_internal_major_version())
  let return_value = 0
  if major == 2 && has('python')
    execute printf('python %s', a:code)
  elseif major == 3 && has('python3')
    execute printf('python3 %s', a:code)
  endif
  return return_value
endfunction " }}}


" External API
function! pyenv#python#is_enabled(...) abort " {{{
  return call('s:is_enabled', a:000)
endfunction " }}}
function! pyenv#python#get_external_version(...) abort " {{{
  return call('s:get_external_version', a:000)
endfunction " }}}
function! pyenv#python#get_external_major_version(...) abort " {{{
  return call('s:get_external_major_version', a:000)
endfunction " }}}
function! pyenv#python#get_internal_version(...) abort " {{{
  return call('s:get_internal_version', a:000)
endfunction " }}}
function! pyenv#python#get_internal_major_version(...) abort " {{{
  return call('s:get_internal_major_version', a:000)
endfunction " }}}
function! pyenv#python#set_internal_major_version(...) abort " {{{
  return call('s:get_internal_major_version', a:000)
endfunction " }}}
function! pyenv#python#auto_internal_major_version(...) abort " {{{
  return call('s:auto_internal_major_version', a:000)
endfunction " }}}
function! pyenv#python#exec_file(...) abort " {{{
  return call('s:exec_file', a:000)
endfunction " }}}
function! pyenv#python#exec_code(...) abort " {{{
  return call('s:exec_code', a:000)
endfunction " }}}


function! s:init() abort " {{{
  if empty(get(g:, 'pyenv#python_exec', ''))
    let candidates = [
          \ expand('~/.pyenv/shims/python'),
          \ expand('~/.anyenv/envs/pyenv/shims/python'),
          \ expand('/usr/local/bin/python'),
          \ 'python',
          \]
    let g:pyenv#python_exec = get(
          \ filter(candidates, 'executable(v:val)'),
          \ 0, '')
  endif
  " initialize internal python (invalid version will be ignored silently)
  let filename = s:P.join(s:repository_root, 'initialize.py')
  call s:auto_internal_major_version()
  call s:exec_file(filename, 2)
  call s:exec_file(filename, 3)
endfunction " }}}
call s:init()


let &cpo = s:save_cpo
" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker:
