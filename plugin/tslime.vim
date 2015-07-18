" Tslime.vim. Send portion of buffer to tmux instance
" Maintainer: C.Coutinho <kikijump [at] gmail [dot] com>
" Licence:    DWTFYWTPL

if exists("g:loaded_tslime") && g:loaded_tslime
  finish
endif

let g:loaded_tslime = 1

" Function to send keys to tmux
" useful if you want to stop some command with <c-c> in tmux.
function! Send_keys_to_Tmux(keys)
  if !exists("g:tslime")
    call <SID>Tmux_Vars()
  endif

  call system(<SID>tmux_command() . " send-keys -t " . s:tmux_target() . " " . a:keys)
endfunction

" Main function.
" Use it in your script if you want to send text to a tmux session.
function! Send_to_Tmux(text)
  if !exists("g:tslime")
    call <SID>Tmux_Vars()
  endif

  call <SID>set_tmux_buffer(a:text)
  call system(<SID>tmux_command() . " paste-buffer -t " . s:tmux_target())
  call system(<SID>tmux_command() . " delete-buffer")
endfunction

function! s:tmux_target()
  return '"' . g:tslime['session'] . '":' . g:tslime['window'] . "." . g:tslime['pane']
endfunction

function! s:set_tmux_buffer(text)
  let buf = substitute(a:text, "'", "\\'", 'g')
  call system(<SID>tmux_command() . " load-buffer -", buf)
endfunction

function! s:tmux_command()
  if exists("g:tslime['socket']")
    return "tmux -S " . g:tslime['socket']
  else
    return "tmux"
  endif
endfunction

function! SendToTmux(text)
  call Send_to_Tmux(a:text)
endfunction

" Session completion
function! Tmux_Socket_Names(A,L,P)
  return <SID>TmuxSockets()
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
  let sessions = system(<SID>tmux_command() . " list-sessions | sed -e 's/:.*$//'")
  return sessions
endfunction

function! s:TmuxWindows()
  return system(<SID>tmux_command() . ' list-windows -t "' . g:tslime['session'] . '" | grep -e "^\w:" | sed -e "s/\s*([0-9].*//g"')
endfunction

function! s:TmuxPanes()
  return system(<SID>tmux_command() . ' list-panes -t "' . g:tslime['session'] . '":' . g:tslime['window'] . " | sed -e 's/:.*$//'")
endfunction

function! s:TmuxSockets()
  return system("lsof -U | grep '^tmux\\|^tmate' | grep -v '\\->0x' | grep -oE '[^      ]+$'")
endfunction

" set tslime.vim variables
function! s:Tmux_Vars()
  let g:tslime = {}

  let sockets = split(s:TmuxSockets(), "\n") 
  let no_unsocketted_sessions = s:TmuxSessions() == "failed to connect to server\n"
  if no_unsocketted_sessions && len(sockets) == 1
    let g:tslime['socket'] = sockets[0]
  else
    if len(sockets) > 0
      let g:tslime['socket'] = ''
      let g:tslime['socket'] = input("socket name (leave blank for no socket): ", "", "custom,Tmux_Socket_Names")
      if g:tslime['socket'] == ''
        unlet g:tslime['socket']
      endif
    endif
  endif

  let names = split(s:TmuxSessions(), "\n")
  if len(names) == 1
    let g:tslime['session'] = names[0]
  else
    let g:tslime['session'] = ''
  endif
  while g:tslime['session'] == ''
    let g:tslime['session'] = input("session name: ", "", "custom,Tmux_Session_Names")
  endwhile

  let windows = split(s:TmuxWindows(), "\n")
  if len(windows) == 1
    let window = windows[0]
  else
    let window = input("window name: ", "", "custom,Tmux_Window_Names")
    if window == ''
      let window = windows[0]
    endif
  endif

  let g:tslime['window'] =  substitute(window, ":.*$" , '', 'g')

  let panes = split(s:TmuxPanes(), "\n")
  if len(panes) == 1
    let g:tslime['pane'] = panes[0]
  else
    let g:tslime['pane'] = input("pane number: ", "", "custom,Tmux_Pane_Numbers")
    if g:tslime['pane'] == ''
      let g:tslime['pane'] = panes[0]
    endif
  endif
endfunction

vmap <unique> <Plug>SendSelectionToTmux "ry :call Send_to_Tmux(@r)<CR>
nmap <unique> <Plug>NormalModeSendToTmux vip <Plug>SendSelectionToTmux

nmap <unique> <Plug>SetTmuxVars :call <SID>Tmux_Vars()<CR>

command! -nargs=* Tmux call Send_to_Tmux('<Args><CR>')
command! -nargs=* TmuxKeys call Send_keys_to_Tmux('<Args><CR>')
