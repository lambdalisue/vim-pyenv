let s:save_cpo = &cpo
set cpo&vim


let s:V = vital#of('vim_pyenv')

function! pyenv#utils#import(name) abort " {{{
  let cache_name = printf(
        \ '_vital_module_%s',
        \ substitute(a:name, '\.', '_', 'g'),
        \)
  if !has_key(s:, cache_name)
    let s:[cache_name] = s:V.import(a:name)
  endif
  return s:[cache_name]
endfunction " }}}
function! pyenv#utils#system(...) abort " {{{
  let P = pyenv#utils#import('Process')
  silent let stdout = call(P.system, a:000, P)
  let status = P.get_last_status()
  return {
        \ 'stdout': stdout,
        \ 'status': status,
        \ 'args': a:000,
        \}
endfunction " }}}

" echo
function! pyenv#utils#echo(hl, msg) abort " {{{
  execute 'echohl' a:hl
  try
    for m in split(a:msg, '\v\r?\n')
      echo m
    endfor
  finally
    echohl None
  endtry
endfunction " }}}
function! pyenv#utils#debug(...) abort " {{{
  if !get(g:, 'pyenv#debug', 0)
    return
  endif
  let args = map(deepcopy(a:000), 'pyenv#utils#ensure_string(v:val)')
  call pyenv#utils#echo('Comment', 'DEBUG: vim-pyenv: ' . join(args))
endfunction " }}}
function! pyenv#utils#info(...) abort " {{{
  let args = map(deepcopy(a:000), 'pyenv#utils#ensure_string(v:val)')
  call pyenv#utils#echo('Title', join(args))
endfunction " }}}
function! pyenv#utils#warn(...) abort " {{{
  let args = map(deepcopy(a:000), 'pyenv#utils#ensure_string(v:val)')
  call pyenv#utils#echo('WarningMsg', join(args))
endfunction " }}}
function! pyenv#utils#error(...) abort " {{{
  let args = map(deepcopy(a:000), 'pyenv#utils#ensure_string(v:val)')
  call pyenv#utils#echo('Error', join(args))
endfunction " }}}

" echomsg
function! pyenv#utils#echomsg(hl, msg) abort " {{{
  execute 'echohl' a:hl
  try
    for m in split(a:msg, '\v\r?\n')
      echomsg m
    endfor
  finally
    echohl None
  endtry
endfunction " }}}
function! pyenv#utils#debugmsg(...) abort " {{{
  if !get(g:, 'pyenv#debug', 0)
    return
  endif
  let args = map(deepcopy(a:000), 'pyenv#utils#ensure_string(v:val)')
  call pyenv#utils#echomsg('Comment', 'DEBUG: vim-pyenv: ' . join(args))
endfunction " }}}
function! pyenv#utils#infomsg(...) abort " {{{
  let args = map(deepcopy(a:000), 'pyenv#utils#ensure_string(v:val)')
  call pyenv#utils#echomsg('Title', join(args))
endfunction " }}}
function! pyenv#utils#warnmsg(...) abort " {{{
  let args = map(deepcopy(a:000), 'pyenv#utils#ensure_string(v:val)')
  call pyenv#utils#echomsg('WarningMsg', join(args))
endfunction " }}}
function! pyenv#utils#errormsg(...) abort " {{{
  let args = map(deepcopy(a:000), 'pyenv#utils#ensure_string(v:val)')
  call pyenv#utils#echomsg('Error', join(args))
endfunction " }}}

" string
function! pyenv#utils#ensure_string(x) abort " {{{
  let P = pyenv#utils#import('Prelude')
  return P.is_string(a:x) ? a:x : [a:x]
endfunction " }}}
function! pyenv#utils#smart_string(value) abort " {{{
  let P = pyenv#utils#import('Prelude')
  if P.is_string(a:value)
    return a:value
  elseif P.is_numeric(a:value)
    return a:value ? string(a:value) : ''
  elseif P.is_list(a:value) || P.is_dict(a:value)
    return !empty(a:value) ? string(a:value) : ''
  else
    return string(a:value)
  endif
endfunction " }}}
function! pyenv#utils#format_string(format, format_map, data) abort " {{{
  " format rule:
  "   %{<left>|<right>}<key>
  "     '<left><value><right>' if <value> != ''
  "     ''                     if <value> == ''
  "   %{<left>}<key>
  "     '<left><value>'        if <value> != ''
  "     ''                     if <value> == ''
  "   %{|<right>}<key>
  "     '<value><right>'       if <value> != ''
  "     ''                     if <value> == ''
  if empty(a:data)
    return ''
  endif
  let pattern_base = '\v\%%%%(\{([^\}\|]*)%%(\|([^\}\|]*)|)\}|)%s'
  let str = copy(a:format)
  for [key, value] in items(a:format_map)
    let result = pyenv#utils#smart_string(get(a:data, value, ''))
    let pattern = printf(pattern_base, key)
    let repl = strlen(result) ? printf('\1%s\2', result) : ''
    let str = substitute(str, pattern, repl, 'g')
  endfor
  return substitute(str, '\v^\s+|\s+$', '', 'g')
endfunction " }}}

function! pyenv#utils#doautocmd(name) abort " {{{
  let name = printf('vim-pyenv-%s', a:name)
  if 703 < v:version || (v:version == 703 && has('patch438'))
    silent execute 'doautocmd <nomodeline> User ' . name
  else
    silent execute 'doautocmd User ' . name
  endif
endfunction " }}}

let &cpo = s:save_cpo
" vim:set et ts=2 sts=2 sw=2 tw=0 fdm=marker:
