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
