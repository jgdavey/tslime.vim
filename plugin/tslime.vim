" Tslime.vim. Send portion of buffer to tmux instance
" Maintainer: C.Coutinho <kikijump [at] gmail [dot] com>
" Licence:    DWTFYWTPL

if exists("g:loaded_tslime") && g:loaded_tslime
  finish
endif

let g:loaded_tslime = 1

" Main function.
" Use it in your script if you want to send text to a tmux session.
function! Send_to_Tmux(text)
  if !exists("g:tmux_sessionname") || !exists("g:tmux_windowname") || !exists("g:tmux_panenumber")
    call <SID>Tmux_Vars()
  end

  let oldbuffer = system(shellescape("tmux show-buffer"))
  call <SID>set_tmux_buffer(a:text)
  call system("tmux paste-buffer -t " . s:tmux_target())
  call <SID>set_tmux_buffer(oldbuffer)
endfunction

function! s:tmux_target()
  return '"' . g:tmux_sessionname . '":' . g:tmux_windowname . "." . g:tmux_panenumber
endfunction

function! s:set_tmux_buffer(text)
  call system("tmux set-buffer '" . substitute(a:text, "'", "'\\\\''", 'g') . "'" )
endfunction

function! SendToTmux(text)
  call Send_to_Tmux(a:text)
endfunction

" Session completion
function! Tmux_Session_Names(A,L,P)
  return <SID>TmuxSessions()
endfunction

" Window completion
function! Tmux_Window_Names(A,L,P)
  return <SID>TmuxWindows()
endfunction

" Pane completion
function! Tmux_Pane_Numbers(A,L,P)
  return <SID>TmuxPanes()
endfunction

function! s:TmuxSessions()
  let sessions = system("tmux list-sessions | sed -e 's/:.*$//'")
  return sessions
endfunction

function! s:TmuxWindows()
  return system('tmux list-windows -t "' . g:tmux_sessionname . '" | grep -e "^\w:" | sed -e "s/ \[[0-9x]*\]$//"')
endfunction

function! s:TmuxPanes()
  return system('tmux list-panes -t "' . g:tmux_sessionname . '":' . g:tmux_windowname . " | sed -e 's/:.*$//'")
endfunction

" set tslime.vim variables
function! s:Tmux_Vars()
  let names = split(s:TmuxSessions(), "\n")
  if len(names) == 1
    let g:tmux_sessionname = names[0]
  else
    let g:tmux_sessionname = ''
  endif
  while g:tmux_sessionname == ''
    let g:tmux_sessionname = input("session name: ", "", "custom,Tmux_Session_Names")
  endwhile

  let windows = split(s:TmuxWindows(), "\n")
  if len(windows) == 1
    let g:tmux_windowname = substitute(windows[0], ":.*$" , '', 'g')
  else
    let g:tmux_windowname = substitute(input("window name: ", "", "custom,Tmux_Window_Names"), ":.*$" , '', 'g')
  endif

  let panes = split(s:TmuxPanes(), "\n")
  if len(panes) == 1
    let g:tmux_panenumber = panes[0]
  else
    let g:tmux_panenumber = input("pane number: ", "", "custom,Tmux_Pane_Numbers")
  endif

  if g:tmux_windowname == ''
    let g:tmux_windowname = '0'
  endif

  if g:tmux_panenumber == ''
    let g:tmux_panenumber = '0'
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

vmap <unique> <Plug>SendSelectionToTmux "ry :call Send_to_Tmux(@r)<CR>
nmap <unique> <Plug>NormalModeSendToTmux vip <Plug>SendSelectionToTmux

nmap <unique> <Plug>SetTmuxVars :call <SID>Tmux_Vars()<CR>

command! -nargs=* Tmux call Send_to_Tmux('<Args><CR>')
