tslime.vim
==========

About
-----
This is a simple vim script to send portion of text from a vim buffer to a
running tmux session.

It is based on slime.vim http://technotales.wordpress.com/2007/10/03/like-slime-for-vim/,
but use tmux instead of screen.

However, compared to tmux, screen doesn't have the notion of panes. So, the
script was adapt to take panes into account.

If you use version of tmux < 1.3 , you should use the stable branch. The version
available in that branch isn't aware of panes so it will paste to pane 0 of the
window.

Setting Keybindings
-------------------

I have modified how keybindings work in tslime.  Instead of forcing a
keybinding on a user, I have set some default keybindings plugin methods that a
user can set in there `.vimrc`.

To send a selection in visual mode to vim, set the following in your `.vimrc`:
```vimscript
  vmap <your_key_combo> <Plug>Selection_To_Tmux
```

To grab the current method that a cursor is in normal mode, set the following:
```vimscript
  nmap <your_key_combo> <Plug>N_Mode_Send_To_Tmux
```

Use the following to reset the session, window, and pane info:
```vimscript
  nmap <your_key_combo> <Plug>Set_Tmux_Vars
```

More info about the `<Plug>` and other mapping syntax can be found
[here](http://vim.wikia.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_3)).
