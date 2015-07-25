let s:save_cpo = &cpo
set cpo&vim


command! -bar -nargs=? -complete=customlist,s:PyenvActivateComplete
      \ PyenvActivate :call pyenv#activate(<q-args>)
command! -bar PyenvDeactivate :call pyenv#deactivate()
command! -bar PyenvCreateCtags :call pyenv#pyenv#create_ctags()
command! -bar PyenvAssignCtags :call pyenv#pyenv#assign_ctags()
command! -bar PyenvWithdrawCtags :call pyenv#pyenv#withdraw_ctags()


function! s:PyenvActivateComplete(arglead, cmdline, cursorpos) abort " {{{
  let candidates = pyenv#pyenv#get_available_envs()
  let prefix = get(split(a:arglead, ','), -1, '')
  return filter(candidates, 'v:val =~# "^" . prefix')
endfunction " }}}


" Automatically activate
if get(g:, 'pyenv#auto_activate', 1)
  if has('vim_starting')
    augroup vim-pyenv-vim-start
      autocmd! *
      autocmd VimEnter * call pyenv#activate('', {'quiet': 1})
    augroup END
  else
    call pyenv#activate('', {'quiet': 1})
  endif
endif

let &cpo = s:save_cpo
"vim: foldlevel=0 sts=2 sw=2 smarttab et ai textwidth=0 fdm=marker                        
