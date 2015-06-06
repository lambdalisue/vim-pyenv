let s:save_cpo = &cpo
set cpo&vim


let s:R = pyenv#utils#import('Process')
let s:activated_name = ''


" Private
function! s:is_enabled() abort " {{{
  return executable(g:pyenv#pyenv_exec)
endfunction " }}}
function! s:parse_envs(rows) abort " {{{
  let envs = map(
        \ deepcopy(a:rows),
        \ 'split(substitute(v:val, "\*", "", "g"))[0]',
        \)
  return envs
endfunction " }}}
function! s:get_installable_envs() abort " {{{
  if !s:is_enabled()
    return []
  endif
  let result = pyenv#utils#system(join([
        \ g:pyenv#pyenv_exec,
        \ 'install',
        \ '--list',
        \]))
  if result.status == 0
    let candidates = split(result.stdout, "\n")[1:]
    return map(candidates, 'substitute(v:val, "^\\s\\+", "", "")')
  endif
  return []
endfunction " }}}
function! s:get_available_envs() abort " {{{
  if !s:is_enabled()
    return []
  endif
  let result = pyenv#utils#system(join([
        \ g:pyenv#pyenv_exec,
        \ 'versions',
        \]))
  if result.status == 0
    return s:parse_envs(split(result.stdout, "\n"))
  endif
  return []
endfunction " }}}
function! s:get_selected_envs() abort " {{{
  if !s:is_enabled()
    return []
  endif
  let result = pyenv#utils#system(join([
        \ g:pyenv#pyenv_exec,
        \ 'version',
        \]))
  if result.status == 0
    return s:parse_envs(split(result.stdout, "\n"))
  endif
  return []
endfunction " }}}
function! s:get_activated_env() abort " {{{
  return s:activated_name
endfunction " }}}

function! s:is_activated() abort " {{{
  return !empty(s:activated_name)
endfunction " }}}
function! s:activate(name) abort " {{{
  if !s:is_enabled()
    return 0
  endif
  let previous_name = s:activated_name
  let $PYENV_VERSION = a:name
  let s:activated_name = a:name
  return 1
endfunction " }}}
function! s:deactivate() abort " {{{
  if !s:is_enabled()
    return 0
  endif
  let is_activated = s:is_activated()
  let $PYENV_VERSION = ''
  let s:activated_name = ''
  return 1
endfunction " }}}


" External API
function! pyenv#pyenv#is_enabled(...) abort " {{{
  return call('s:is_enabled', a:000)
endfunction " }}}
function! pyenv#pyenv#get_installable_envs(...) abort " {{{
  return call('s:get_installable_envs', a:000)
endfunction " }}}
function! pyenv#pyenv#get_available_envs(...) abort " {{{
  return call('s:get_available_envs', a:000)
endfunction " }}}
function! pyenv#pyenv#get_selected_envs(...) abort " {{{
  return call('s:get_selected_envs', a:000)
endfunction " }}}
function! pyenv#pyenv#get_activated_env(...) abort " {{{
  return call('s:get_activated_env', a:000)
endfunction " }}}
function! pyenv#pyenv#is_activated(...) abort " {{{
  return call('s:is_activated', a:000)
endfunction " }}}
function! pyenv#pyenv#activate(...) abort " {{{
  return call('s:activate', a:000)
endfunction " }}}
function! pyenv#pyenv#deactivate(...) abort " {{{
  return call('s:deactivate', a:000)
endfunction " }}}


function! s:init() abort " {{{
  if empty(get(g:, 'pyenv#pyenv_exec', ''))
    let candidates = [
          \ expand('~/.pyenv/bin/pyenv'),
          \ expand('~/.anyenv/envs/pyenv/bin/pyenv'),
          \ expand('/usr/local/bin/pyenv'),
          \ 'pyenv',
          \]
    let g:pyenv#pyenv_exec = get(
          \ filter(candidates, 'executable(v:val)'),
          \ 0, '')
  endif
endfunction " }}}
call s:init()

let &cpo = s:save_cpo
" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker:
