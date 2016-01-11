let s:save_cpo = &cpo
set cpo&vim


let s:R = pyenv#utils#import('Process')
let s:P = pyenv#utils#import('System.Filepath')
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
  return empty(s:activated_name) ? 'builtin' : s:activated_name
endfunction " }}}
function! s:get_prefixes() abort " {{{
  if !s:is_enabled()
    return []
  endif
  let result = pyenv#utils#system(join([
        \ g:pyenv#pyenv_exec,
        \ 'prefix',
        \]))
  if result.status == 0
    return split(result.stdout, '\v\r?\n')
  endif
  return []
endfunction " }}}


function! s:is_activated() abort " {{{
  return !empty(s:activated_name)
endfunction " }}}
function! s:activate(name) abort " {{{
  if !s:is_enabled()
    return 0
  endif
  let previous_PYENV_VERSION = $PYENV_VERSION
  let $PYENV_VERSION = a:name
  let external_python_major_version = pyenv#python#get_external_major_version()
  if external_python_major_version == 2 && !has('python')
    " cannot activate this python
    let $PYENV_VERSION = previous_PYENV_VERSION
    return 0
  elseif external_python_major_version == 3 && !has('python3')
    " cannot activate this python
    let $PYENV_VERSION = previous_PYENV_VERSION
    return 0
  endif
  let s:activated_name = a:name
  if g:pyenv#auto_create_ctags
    call s:create_ctags()
  endif
  if g:pyenv#auto_assign_ctags
    call s:assign_ctags()
  endif
  return 1
endfunction " }}}
function! s:deactivate() abort " {{{
  if !s:is_enabled()
    return 0
  endif
  let is_activated = s:is_activated()
  let $PYENV_VERSION = ''
  let s:activated_name = ''
  if g:pyenv#auto_assign_ctags
    call s:assign_ctags()
  endif
  return 1
endfunction " }}}
function! s:create_ctags(...) abort " {{{
  let verbose = get(a:000, 0, 0)
  if !s:is_enabled() || empty(g:pyenv#ctags_exec)
    return 0
  endif
  let prefixes = s:get_prefixes()
  for prefix in prefixes
    let result = pyenv#utils#system(join([
          \ g:pyenv#ctags_exec,
          \ '-o', s:P.join(prefix, 'tags'),
          \ '-R', prefix,
          \]))
    if verbose && result.status
      echoerr result.stdout
      echo result.args
    endif
  endfor
  return 1
endfunction " }}}
function! s:assign_ctags() abort " {{{
  if !s:is_enabled()
    return 0
  endif
  let prefixes = s:get_prefixes()
  for prefix in prefixes
    let tagfile = s:P.join(prefix, 'tags')
    let taglist = split(&l:tags, ',')
    if filereadable(tagfile) && index(taglist, tagfile) == -1
      silent execute printf('setlocal tags+=%s', fnameescape(tagfile))
    endif
  endfor
endfunction " }}}
function! s:withdraw_ctags() abort " {{{
  if !s:is_enabled()
    return 0
  endif
  let prefixes = s:get_prefixes()
  for prefix in prefixes
    let tagfile = s:P.join(prefix, 'tags')
    let &l:tags = substitute(&l:tags,
          \ printf(',\?%s', tagfile),
          \ '', '',
          \)
  endfor
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
function! pyenv#pyenv#create_ctags(...) abort " {{{
  return call('s:create_ctags', a:000)
endfunction " }}}
function! pyenv#pyenv#assign_ctags(...) abort " {{{
  return call('s:assign_ctags', a:000)
endfunction " }}}
function! pyenv#pyenv#withdraw_ctags(...) abort " {{{
  return call('s:withdraw_ctags', a:000)
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
  if empty(get(g:, 'pyenv#ctags_exec', ''))
    if executable('ctags')
      let g:pyenv#ctags_exec = 'ctags'
    endif
  endif
  let g:pyenv#auto_create_ctags = get(g:, 'pyenv#auto_create_ctags', 0)
  let g:pyenv#auto_assign_ctags = get(g:, 'pyenv#auto_assign_ctags', 1)
endfunction " }}}
call s:init()

let &cpo = s:save_cpo
" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker:
