let s:save_cpo = &cpo
set cpo&vim


function! s:activate(...) abort " {{{
  if pyenv#pyenv#is_activated()
    call s:deactivate({'quiet': 1})
  endif
  let envs = pyenv#pyenv#get_selected_envs()
  let env = get(a:000, 0, '')
  let env = empty(env) ? get(envs, 0, 'system') : env
  let opts = extend({
        \ 'quiet': 0,
        \}, get(a:000, 1, {}))
  " activate pyenv and select correct python
  if pyenv#pyenv#activate(env)
    " automatically select a correct python major version
    " and regulate sys.path
    call pyenv#python#auto_internal_major_version()
    call pyenv#python#exec_code(
          \ 'pyenv_vim.activate(vim.vars["pyenv#python_exec"])')
    call pyenv#utils#doautocmd('activate-post')
    if !opts.quiet
      redraw | call pyenv#utils#info(printf(
            \'vim-pyenv: "%s" is activated.', env,
            \))
    endif
  else
    redraw | call pyenv#utils#error(printf(
          \ 'vim-pyenv: Failed to activate "%s". Python version of the env is not supported in this Vim.',
          \ env,
          \))
  endif
endfunction " }}}
function! s:deactivate(...) abort " {{{
  let opts = extend({
        \ 'quiet': 0,
        \}, get(a:000, 0, {}))
  if pyenv#pyenv#is_activated()
    let env = pyenv#pyenv#get_activated_env()
    " reset 'sys.path' of internal python
    call pyenv#python#exec_code('pyenv_vim.deactivate()')
    " deactivate pyenv and select correct python
    call pyenv#pyenv#deactivate()
    call pyenv#python#auto_internal_major_version()
    call pyenv#utils#doautocmd('deactivate-post')
    if !opts.quiet
      redraw! | call pyenv#utils#info(printf(
            \'vim-pyenv: "%s" is deactivated.', env,
            \))
    endif
  endif
endfunction " }}}
function! s:validate() abort " {{{
  if !pyenv#pyenv#is_enabled()
    call pyenv#utils#error(
          \ '"pyenv" is not found in $PATH.',
          \ 'Specify g:pyenv#pyenv_exec',
          \)
    return 0
  elseif !pyenv#python#is_enabled()
    call pyenv#utils#error(
          \ 'vim-pyenv requires Python and/or Python3 interpreter (+python, +python3).',
          \)
    return 0
  endif
  return 1
endfunction " }}}


function! pyenv#activate(...) abort " {{{
  if s:validate()
    return call('s:activate', a:000)
  endif
endfunction " }}}
function! pyenv#deactivate(...) abort " {{{
  if s:validate()
    return call('s:deactivate', a:000)
  endif
endfunction " }}}


let &cpo = s:save_cpo
unlet! s:save_cpo
