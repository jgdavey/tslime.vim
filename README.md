tslime.vim
==========

This is a simple vim script to send portion of text from a vim buffer to a
running tmux session.

It is based on slime.vim http://technotales.wordpress.com/2007/10/03/like-slime-for-vim/,
but use tmux instead of screen. However, compared to tmux, screen doesn't
have the notion of panes. So, the script was adapted to take panes into
account.

**Note:** If you use version of tmux earlier than 1.3, you should use the stable
branch. The version available in that branch isn't aware of panes so it
will paste to pane 0 of the window.

Settings
--------

You can tell tslime.vim to use the current session and current window, this let's you 
avoid specifying this on every upstart of vim.

let g:tslime_always_current_session = 1
let g:tslime_always_current_window = 1

These are disabled by default, meaning you will have the ability to choose from every 
session/window/pane combination.

You can also configure tslime.vim to automatically append newlines to the text
that will be sent to tmux:

    let g:tslime_ensure_trailing_newlines = 1

This is handy when you want to evaluate part of a line as a line of its own,
or when the REPL you are sending text two requires expressions to be followed
by a defined number of new lines (eg. Python):

    augroup ft_python
        au!

        let b:tslime_ensure_trailing_newlines = 2
    augroup END

Setting Keybindings
-------------------

In this fork of tslime.vim, keybindings are not set automatically
for you. Instead, you can map whatever you'd like to one of the
plugin-specific bindings in your `.vimrc` file.

To get the old defaults, put the following in your `.vimrc`:

``` vim
vmap <C-c><C-c> <Plug>SendSelectionToTmux
nmap <C-c><C-c> <Plug>NormalModeSendToTmux
nmap <C-c>r <Plug>SetTmuxVars
```

To send a selection in visual mode to vim, set the following in your `.vimrc`:

``` vim
vmap <your_key_combo> <Plug>SendSelectionToTmux
```

To grab the current method that a cursor is in normal mode, set the following:

``` vim
nmap <your_key_combo> <Plug>NormalModeSendToTmux
```

Use the following to reset the session, window, and pane info:

``` vim
nmap <your_key_combo> <Plug>SetTmuxVars
```

Have a command you run frequently, use this:

``` vim
nmap <your_key_combo> :Tmux <your_command><CR>
```

More info about the `<Plug>` and other mapping syntax can be found
[here](http://vim.wikia.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_3\) ).
