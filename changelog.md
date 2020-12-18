## v4 => v5

- The default `fzf` key bindings for <kbd>Tab</kbd>/<kbd>Shift+Tab</kbd> and
  <kbd>Ctrl+R</kbd>/<kbd>Ctrl+S</kbd> have been changed to <kbd>Up</kbd>/<kbd>Down</kbd> in
  default layout and <kbd>Down</kbd>/<kbd>Up</kbd> in reversed layout. It is recommended to remove
  the following lines from `~/.zshrc` if you have them:
  ```zsh
  # When fzf menu opens on TAB, another TAB moves the cursor down ('tab:down')
  # or accepts the selection and triggers another TAB-completion ('tab:repeat')?
  zstyle ':z4h:fzf-complete'    fzf-bindings     'tab:down'
  # When fzf menu opens on Alt+Down, TAB moves the cursor down ('tab:down')
  # or accepts the selection and triggers another Alt+Down ('tab:repeat')?
  zstyle ':z4h:cd-down'         fzf-bindings     'tab:down'
  ```
- FreeBSD is no longer supported.
- `zstyle ':z4h:...' passthrough` has been replaced with `zstyle ':z4h:...' enable` that has the
  opposite meaning. The default value is `no`. If your `~/.zshrc` mentions `passthrough`, you need
  to change those styles. Here's how it looks in the default `.zshrc` now:
  ```zsh
  # Enable ('yes') or disable ('no') automatic teleportation of z4h over
  # ssh when connecting to these hosts.
  zstyle ':z4h:ssh:example-hostname1'   enable 'yes'
  zstyle ':z4h:ssh:*.example-hostname2' enable 'no'
  # The default value if none of the overrides above match the hostname.
  zstyle ':z4h:ssh:*'                   enable 'no'
  ```
- Function `ssh` has been moved from `.zshrc` to z4h proper. If your `.zshrc` defines it, you need
  to remove it.
- When connecting over ssh to a host for which `zstyle ':z4h:ssh:...' enable` is set to 'no', `TERM`
  value of `tmux-256color` gets replaced with `screen-256color`. This can be customized with
  `zstyle ':z4h:ssh:...' term`.
- New option to disable preview in `z4h-fzf-history`:
  ```zsh
  zstyle :z4h:fzf-history fzf-preview no
  ```
- iTerm2 integration can no longer be enabled by sourcing `~/.iterm2_shell_integration.zsh`.
  Instead, you need to put this line in `~/.zshrc`:
  ```zsh
  zstyle ':z4h:' iterm2-integration 'yes'
  ```
- The following bindings have been changed:
  - <kbd>Ctrl+P</kbd>/<kbd>Up</kbd>: `z4h-up-local-history` => `z4h-up-substring-local`
  - <kbd>Ctrl+N</kbd>/<kbd>Down</kbd>: `z4h-down-local-history` => `z4h-down-substring-local`
- The following widgets have been renamed:
  - `z4h-up-local-history` => `z4h-up-prefix-local`
  - `z4h-down-local-history` => `z4h-down-prefix-local`
  - `z4h-up-global-history` => `z4h-up-prefix-global`
  - `z4h-down-global-history` => `z4h-down-prefix-global`
- It's now possible to automatically start `tmux` when zsh4humans is initializing.
  ```zsh
  zstyle :z4h: start-tmux [arg]...
  ```
  Where `[arg]...` is either `integrated` (the default), `no`, `command <cmd> [flag]...`, or
  `system`. The latter is equivalent to `command tmux -u`.
- Widgets the perform recursive directory traversal (`z4h-cd-down` and `z4h-fzf-complete`) now
  use [bfs](https://github.com/tavianator/bfs) instead of `find` if it's installed. You can get
  the original behavior with the following declaration:
  ```zsh
  zstyle ':z4h:(cd-down|fzf-complete)' find-command command find
  ```
  You can also use a custom function in place of `command find` if you want to transform command
  line arguments.
- `z4h-fzf-history` (<kbd>Ctrl+R</kbd>) now uses `BUFFER` instead of `LBUFFER` for the initial
  query. This makes a difference only when the widget is invoked when the cursor is not at the very
  end of the command line.
