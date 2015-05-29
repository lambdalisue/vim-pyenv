let s:save_cpo = &cpo
set cpo&vim


let s:C = pyenv#utils#import('System.Cache.Memory')
let s:cache = s:C.new()


function! s:get_info() abort " {{{
  if !pyenv#python#is_enabled() || !pyenv#pyenv#is_enabled()
    return {}
  endif
  let info = s:cache.get('info', {})
  if empty(info)
    let info = {
          \ 'internal_version': pyenv#python#get_internal_version(),
          \ 'internal_major_version': pyenv#python#get_internal_major_version(),
          \ 'external_version': pyenv#python#get_external_version(),
          \ 'external_major_version': pyenv#python#get_external_major_version(),
          \ 'selected_versions': pyenv#pyenv#get_selected_envs(),
          \ 'activated_version': pyenv#pyenv#get_activated_env(),
          \}
    let info.selected_version = get(info.selected_versions, 0, 'system')
    let info.selected_versions = join(info.selected_versions, ', ')
    call s:cache.set('info', info)
  endif
  return info
endfunction " }}}
function! s:format_string(format, info) abort " {{{
  let format_map = {
        \ 'iv': 'internal_version',
        \ 'im': 'internal_major_version',
        \ 'ev': 'external_version',
        \ 'em': 'external_major_version',
        \ 'sv': 'selected_version',
        \ 'ss': 'selected_versions',
        \ 'av': 'activated_version',
        \}
  return pyenv#utils#format_string(a:format, format_map, a:info)
endfunction " }}}
function! s:format_string_by_preset(name, info) abort " {{{
  let preset = {
        \ 'long': '%{#}av%{ (|)}ev',
        \ 'short': '%{#}av',
        \}
  return s:format_string(get(preset, a:name, ''), a:info)
endfunction " }}}
function! s:clear() abort " {{{
  call s:cache.remove('info')
endfunction " }}}

function! pyenv#info#get(...) abort " {{{
  return call('s:get_info', a:000)
endfunction " }}}
function! pyenv#info#format(format, ...) abort " {{{
  if a:0 > 0
    let info = expr
  else
    let info = s:get_info()
  endif
  return s:format_string(a:format, info)
endfunction " }}}
function! pyenv#info#preset(preset_name, ...) abort " {{{
  if a:0 > 0
    let info = expr
  else
    let info = s:get_info()
  endif
  return s:format_string_by_preset(a:preset_name, info)
endfunction " }}}

" Autocmd
augroup vim-pyenv-info " {{{
  autocmd! *
  " clear cache when user activate/deactivate pyenv
  autocmd User vim-pyenv-activate-post call s:clear()
  autocmd User vim-pyenv-deactivate-post call s:clear()
augroup END " }}}

let &cpo = s:save_cpo
"vim: foldlevel=0 sts=2 sw=2 smarttab et ai textwidth=0 fdm=marker
