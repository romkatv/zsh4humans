# Advanced configuration tips

The default configuration in Zsh for Humans is intentionally conservative. It's
meant to be non-surprising for new users and robust. Experienced Zsh users are
encouraged to customize their config to unlock the full potential of their
shell.

* 1. [tmux](#tmux)
* 2. [Prompt at bottom](#prompt-at-bottom)
* 3. [Autosuggestions](#autosuggestions)
* 4. [Shell integration](#shell-integration)
* 5. [Prompt](#prompt)
* 6. [Terminal title](#terminal-title)
* 7. [SSH](#ssh)
  * 7.1. [Extra dotfiles](#extra-dotfiles)
  * 7.2. [Better hostname reporting](#better-hostname-reporting)
  * 7.3. [Persistent and shared command history](#persistent-and-shared-command-history)
  * 7.4. [Unattended teleportation](#unattended-teleportation)
* 8. [Current directory](#current-directory)
* 9. [Completions](#completions)
* 10. [fzf](#fzf)
* 11. [Word-based widgets](#word-based-widgets)
* 12. [Oh My Zsh](#oh-my-zsh)
* 13. [Backup and restore](#backup-and-restore)
* 14. [vi mode](#vi-mode)
* 15. [Managing dotfiles](#managing-dotfiles)
  * 15.1. [Alternative `ZDOTDIR`](#alternative-zdotdir)
* 16. [Privileged shell](#privileged-shell)
* 17. [Homebrew](#homebrew)

## tmux

If you choose *No* when asked by the installer whether `zsh` should always run
in `tmux`, you'll have the following snippet in `~/.zshrc`:

```zsh
# Don't start tmux.
zstyle ':z4h:' start-tmux no
```

Several features in Zsh for Humans require knowing the content of the terminal
screen, and with the above option this condition won't be satisfied. If you
remove this `zstyle` line, Zsh for Humans will automatically start a
stripped-down version of `tmux` (referred to as "integrated tmux" in the source
code and discussions) that should enable the extra features with no other
visible effects. This used to be the default in Zsh for Humans for a long time
but eventually it's been changed because there are corner cases where integrated
tmux can cause issues. Try removing this line and see if everything still works.

If your terminal has a feature that allows it to open a new tab or window in
the same directory as the current tab, and it doesn't work, add the following
option:

```zsh
zstyle ':z4h:' propagate-cwd yes
```

If terminal title breaks, see [Terminal Title](#terminal-title).

If vertically resizing the terminal window breaks scrollback, add this option:

```zsh
zstyle ':z4h:' term-vresize top
```

If mouse wheel scrolling stops working in some applications, enable mouse
support for them explicitly. For example:

```zsh
alias nano='nano --mouse'
```

## Prompt at bottom

Having prompt always in the same location allows you to find it quicker and to
position your terminal window so that looking at prompt is most comfortable.

Add the following option to `~/.zshrc` to place prompt at the bottom when Zsh
starts and upon pressing <kbd>Ctrl+L</kbd>:

```zsh
# Move prompt to the bottom when zsh starts and on Ctrl+L.
zstyle ':z4h:' prompt-at-bottom 'yes'
```

This feature requires that [`start-tmux` is not set to `no`](#tmux).

If you have a habit of running `clear` instead of pressing <kbd>Ctrl+L</kbd>,
you can add this alias:

```zsh
alias clear=z4h-clear-screen-soft-bottom
```

Note that having prompt always at the *top* is [impossible](
  https://github.com/romkatv/powerlevel10k-media/issues/2#issuecomment-725277867).

## Autosuggestions

Most key shortcuts that move the cursor behave consistently in the presence of
autosuggestions. The only exceptions are `forward-char`, `vi-forward-char` and
`end-of-line`. These widgets accept the full autosuggestion instead of just one
character or one line. This can be fixed with the following options:

```zsh
zstyle ':z4h:autosuggestions' forward-char partial-accept
zstyle ':z4h:autosuggestions' end-of-line  partial-accept
```

## Shell integration

Add the following option to `~/.zshrc`:

```zsh
# Mark up shell's output with semantic information.
zstyle ':z4h:' term-shell-integration 'yes'
```

This enables extra features in terminals that understand [OSC 133](
  https://iterm2.com/documentation-escape-codes.html#:~:text=FTCS_PROMPT-,OSC%20133%20%3B,-A%20ST)
([iTerm2](https://iterm2.com/documentation-shell-integration.html),
[kitty](https://sw.kovidgoyal.net/kitty/shell-integration/), and perhaps
others). It also fixes [horrific mess when resizing terminal window](
  https://github.com/romkatv/powerlevel10k#horrific-mess-when-resizing-terminal-window),
provided that you've enabled [integrated tmux](#tmux).

In iTerm2 you'll see blue triangles to the left of every prompt. This can be
[disabled](
  https://stackoverflow.com/questions/41123922/iterm2-hide-marks/41661660#41661660)
in iTerm2 preferences.

## Prompt

Prompt can be configured with `p10k configure`. Some options work very well
together: try two-line prompt, sparse (adds an empty line before prompt), and
transient prompt. If you are optimizing for productivity, use *Lean* style and
choose *Few* icons rather than *Many*. The extra icons from *Many* are
decorative. See: [What is the best prompt style in the configuration wizard](
  https://github.com/romkatv/powerlevel10k#what-is-the-best-prompt-style-in-the-configuration-wizard).


Add the following option to `~/.zshrc` to make transient prompt work
consistently when closing an SSH connection:

```zsh
z4h bindkey z4h-eof Ctrl+D
setopt ignore_eof
```

This preserves the default zsh behavior on Ctrl+D. You can bind `z4h-exit`
instead of `z4h-eof` if you want Ctrl+D to always exit the shell.

If you are using a two-line prompt with an empty line before it, add this for
smoother rendering:

```zsh
POSTEDIT=$'\n\n\e[2A'
```

If you are using a one-line prompt with an empty line, or a two-line prompt
without an empty line, add this instead:

```zsh
POSTEDIT=$'\n\e[A'
 ```

## Terminal title

Some terminals by default do not allow shell to set tab and window title. This
can be changed in the terminal preferences.

Terminal title can be customized with `:z4h:term-title` style. Here are the
defaults:

```zsh
zstyle ':z4h:term-title:ssh'   preexec '%n@%m: ${1//\%/%%}'
zstyle ':z4h:term-title:ssh'   precmd  '%n@%m: %~'
zstyle ':z4h:term-title:local' preexec '${1//\%/%%}'
zstyle ':z4h:term-title:local' precmd  '%~'
```

`:z4h:term-title:ssh` is applied when connected over SSH while
`:z4h:term-title:local` is applied to local shells.

`preexec` title is set before executing a command: `$1` is the unexpanded
command line, `$2` is the same command line after alias expansion.

`precmd` title is set after executing a command. There are no positional
arguments.

All values undergo prompt expansion.

Tip: Add `%*` to `preexec` to display the time when the command started
executing.

Tip: Replace `%m` with `${${${Z4H_SSH##*:}//\%/%%}:-%m}`. This makes a
difference when using [SSH teleportation](#SSH): the title will show the
hostname as you typed it on the command line when connecting rather than
the hostname reported by the remote machine.

## SSH

[![SSH teleportation](https://asciinema.org/a/542763.svg)](https://asciinema.org/a/542763)

When you connect to a remote host over SSH, your local Zsh for Humans
environment can be teleported over to it. The first login to a remote host may
take some time. After that it's as fast as normal `ssh`.

SSH teleportation can be enable per host. By default it's disabled for all
hosts. You can use either a blacklist approach:

```zsh
# Enable SSH teleportation by default.
zstyle ':z4h:ssh:*'                   enable yes

# Disable SSH teleportation for specific hosts.
zstyle ':z4h:ssh:example-hostname1'   enable no
zstyle ':z4h:ssh:*.example-hostname2' enable no
```

Or a whitelist approach:

```zsh
# Disable SSH teleportation by default.
zstyle ':z4h:ssh:*'                   enable no

# Enable SSH teleportation for specific hosts.
zstyle ':z4h:ssh:example-hostname1'   enable yes
zstyle ':z4h:ssh:*.example-hostname2' enable yes
```

### Extra dotfiles

If your shell environment requires extra files other than zsh rc files (which
are teleported by default), add them to `send-extra-files`:

```zsh
zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'
```

You can add directories here as well. Don't add anything heavy as it'll slow
down SSH connection.

*NOTE*: Remote files and directories get silently overwritten when teleporting.

*NOTE*: If a file doesn't exist locally, it'll be silently deleted on the remote
host when teleporting.

### Better hostname reporting

When connected over SSH, by default prompt and terminal title will display the
hostname as reported by the remote machine. Sometimes it's not the same as
what you've passed to `ssh` on the command line and usually you would want to
see the latter. To achieve this, use  `${${${Z4H_SSH##*:}//\%/%%}:-%m}` instead
of `%m` in configuration options. For example, here's how you can configure
terminal title:

```zsh
zstyle ':z4h:term-title:ssh' preexec '%n@'${${${Z4H_SSH##*:}//\%/%%}:-%m}': ${1//\%/%%}'
zstyle ':z4h:term-title:ssh' precmd  '%n@'${${${Z4H_SSH##*:}//\%/%%}:-%m}': %~'
```

And here's prompt:

```zsh
typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE=%n@${${${Z4H_SSH##*:}//\%/%%}:-%m}
```

The latter should go in `~/.p10k.zsh`. You might already have some `CONTEXT`
templates in there. Customize them as needed.

### SSH config

For better user experience with SSH add the following stanza to `~/.ssh/config`:

```text
Host *
  ServerAliveInterval 60
  ConnectTimeout 10
  AddKeysToAgent yes
  EscapeChar `
  ControlMaster auto
  ControlPersist 72000
  ControlPath ~/.ssh/s/%C
```

See `man ssh_config` for the meaning of these options and adjust them
accordingly.

Make sure that `~/.ssh/s` is an existing directory with `0700` mode.

The above config remaps `EscapeChar` from the default tilde to backtick because
you often start zsh commands with tilde (and it's annoying that nothing shows
up) but you never start commands with backtick.

If your OS doesn't start SSH agent automatically, add this to `~/.zshrc`:

```zsh
zstyle ':z4h:ssh-agent:' start      yes
zstyle ':z4h:ssh-agent:' extra-args -t 20h
```

It's a good idea to list all hosts that you SSH to in `~/.ssh/config`. Like
this:

```text
Host pihole
  HostName 192.168.1.42
  User pi
Host blog
  HostName 10.100.1.2
  User admin
```

If you do this, you can [configure](#completions) `ssh` and similar commands to
complete hostnames nicely.

### Persistent and shared command history

Zsh for Humans can pull command history from remote hosts when you close an SSH
connection. It can also send command history to the remote host when connecting.
This allows you to retain command history from remote hosts even when they get
wiped. It also allows you to share command history between hosts. The mechanism
is very flexible but not easy to configure. Here's something to get you started.

```zsh
# This function is invoked by zsh4humans on every ssh command after
# the instructions from ssh-related zstyles have been applied. It allows
# us to configure ssh teleportation in ways that cannot be done with
# zstyles.
#
# Within this function we have readonly access to the following parameters:
#
# - z4h_ssh_client  local hostname
# - z4h_ssh_host    remote hostname as it was specified on the command line
#
# We also have read & write access to these:
#
# - z4h_ssh_enable          1 to use ssh teleportation, 0 for plain ssh
# - z4h_ssh_send_files      list of files to send to the remote; keys are local
#                           file names, values are remote file names
# - z4h_ssh_retrieve_files  the same as z4h_ssh_send_files but for pulling
#                           files from remote to local
# - z4h_retrieve_history    list of local files into which remote $HISTFILE
#                           should be merged at the end of the connection
# - z4h_ssh_command         command to use instead of `ssh`
function z4h-ssh-configure() {
  emulate -L zsh

  # Bail out if ssh teleportation is disabled. We could also
  # override this parameter here if we wanted to.
  (( z4h_ssh_enable )) || return 0

  # Figure out what kind of machine we are about to connect to.
  local machine_tag
  case $z4h_ssh_host in
    ec2-*) machine_tag=ec2;;
    *)     machine_tag=$z4h_ssh_host;;
  esac

  # This is where we are locally keeping command history
  # retrieved from machines of this kind.
  local local_hist=$ZDOTDIR/.zsh/history/retrieved_from_$machine_tag

  # This is where our $local_hist ends up on the remote machine when
  # we connect to it. Command history from files with names like this
  # is explicitly loaded by our zshrc (see below). All new commands
  # on the remote machine will still be written to the regular $HISTFILE.
  local remote_hist='"$ZDOTDIR"/.zsh/history/received_from_'${(q)z4h_ssh_client}

  # At the start of the SSH connection, send $local_hist over and
  # store it as $remote_hist.
  z4h_ssh_send_files[$local_hist]=$remote_hist

  # At the end of the SSH connection, retrieve $HISTFILE from the
  # remote machine and merge it with $local_hist.
  z4h_retrieve_history+=($local_hist)
}

# Load command history that was sent to this machine over ssh.
() {
  emulate -L zsh -o extended_glob
  local hist
  for hist in $ZDOTDIR/.zsh/history/received_from_*(NOm); do
    fc -RI $hist
  done
}
```

You'll need to add this block to `~/.zshrc` below `z4h init`. Before trying it
out you'll probably want to modify the logic that computes `machine_tag` based
on `$z4h_ssh_host` although you can also use it as is -- there is a reasonable
fallback.

If you are defining `z4h-ssh-configure`, you don't actually need to use
ssh-specific zstyles but you still can if you want to. The function is invoked
after zstyles are applied, so you can observe and/or override their effect
within `z4h-ssh-configure`. For example, `z4h_ssh_enable` within the function is
set to 0 or 1 according to the value of `zstyle :z4h:ssh:$hostname enable`. The
implementation of `z4h-ssh-configure` posted above bails out if `z4h_ssh_enable`
is zero, so it doesn't do anything unless you enable SSH teleportation via
`zstyle` for the target host. You could instead set `z4h_ssh_enable` in the
function itself based on `$z4h_ssh_host` or anything else.

You can add the following line at the top of `z4h-ssh-configure` to see the
initial values of all ssh parameters that Zsh for Humans lets you read/write.

```zsh
typeset -pm 'z4h_ssh_*'
```

You'll notice that there are a few more parameters than what is documented in
the comments above `z4h-ssh-configure`. Those are low-level blocks of code that
get executed on the remote host. You probably shouldn't touch them.

### Unattended teleportation

You can teleport Zsh for Humans to a remote host with a script like this:

```zsh
#!/usr/bin/env -S zsh -i

emulate -L zsh -o no_ignore_eof

ssh -t hostname <<<exit
```

Replace `hostname` with a real hostname.

The shebang says to execute this script with `zsh -i`, which makes `z4h`
function available to it.

After you run this script, it's guaranteed that SSH teleportation will be fast
and won't perform neither the installation or update.

To forcefully update Zsh for Humans on the remote machine, replace the last line
with this:

```zsh
ssh -t hostname <<<$'z4h update\nexit'
```

Usually this shouldn't be necessary because SSH teleportation automatically
updates Zsh for Humans on the remote host if your local rc files require a newer
version than what's available there. When a new feature is added to Zsh for
Humans (a function, an alias, a zstyle, etc.), [version](
  https://github.com/romkatv/zsh4humans/blob/v5/version) gets bumped. When
teleporting, the version number of the local Zsh for Humans installation is sent
over to the remote (it's the first part of `$Z4H_SSH`) and the remote is updated
if its version is lower. This ensures that your rc files are compatible with
Zsh for Humans on the remote host.

## Current directory

Zsh for Humans stores persistent directory history. It gets loaded into the
builtin `dirstack` when you start zsh. Try opening a new terminal and typing
`cd -<TAB>` -- you'll see the history. You can also hit <kbd>Alt+Left</kbd>
(<kbd>Shift+Left</kbd> on macOS) to go back in `dirstack`. This is useful if you
want to create a new terminal tab and `cd` into the last directory you've
visited, or to go back after a `cd`. <kbd>Alt+Left</kbd>/<kbd>Alt+Right</kbd>
(<kbd>Shift+Left</kbd>/<kbd>Shift+Right</kbd> on macOS) work like Back/Forward
buttons in a web browser.

<kbd>Alt+Up</kbd> (<kbd>Shift+Up</kbd> on macOS) goes to the parent directory
and <kbd>Alt+Down</kbd> (<kbd>Shift+Down</kbd> on macOS) goes to a subdirectory.
Since there are many subdirectories, the latter asks you to choose.

There is also <kbd>Alt+R</kbd> for fzf over directory history. This is the
closest thing to [autojump](https://github.com/wting/autojump),
[z](https://github.com/rupa/z) and similar tools.

You might want to configure things a bit differently:

```zsh
zstyle ':z4h:fzf-dir-history' fzf-bindings tab:repeat
zstyle ':z4h:cd-down'         fzf-bindings tab:repeat

z4h bindkey z4h-fzf-dir-history Alt+Down
```

This rebinds <kbd>Alt+Down</kbd> to `z4h-fzf-dir-history` -- the widget that you
can invoke via <kbd>Alt+R</kbd> by default. You'll no longer have a binding for
`z4h-cd-down` but that's OK because you can get the same behavior with
<kbd>Alt+Down Tab</kbd>.

The two `zstyle` lines rebind <kbd>Tab</kbd> in two fzf-based widgets from
the default `up` to `repeat`. The latter causes the selection to get accepted
(like pressing <kbd>Enter</kbd>) and immediately opens fzf once again. When you
invoke `z4h-fzf-dir-history`, the first entry is always the current directory,
so `repeat` on that will repopulate fzf with subdirectories of the current
directory -- just like `z4h-cd-down`. You can press <kbd>Tab</kbd> on other
entries, too, if you need to go into their subdirectories.

## Completions

Enable recursive file completions:

```zsh
# Recursively traverse directories when TAB-completing files.
zstyle ':z4h:fzf-complete' recurse-dirs yes
```

This takes a bit of getting used to but once you do, it's a massive time saver.

Rebind <kbd>Tab</kbd> in fzf from `up` to `repeat`:

```zsh
zstyle ':z4h:fzf-complete' fzf-bindings tab:repeat
```

Now <kbd>Tab</kbd> in fzf will accept the selection (like pressing
<kbd>Enter</kbd>) and immediately open fzf once again if the current word isn't
fully specified yet. It's very useful when TAB-completing file arguments.
Instead of waiting in fzf for all files and directories to be traversed
(assuming you've enabled [recursive file completions](#completions)), you can
accept a directory with <kbd>Tab</kbd> to narrow down the search.

You can undo and redo completions the same way as any other command line
changes. You can find their bindings in your `~/.zshrc` and might want to rebind
them to something else.

Tip: Use <kbd>Tab</kbd> to expand and verify globs and undo the expansion before
executing the command. For example, you can type `rm **/*.orig`, press
<kbd>Tab</kbd> to expand the glob, check that it looks good, press
<kbd>Ctrl+/</kbd> to undo the expansion and execute the command. (It's a good
idea execute commands with glob arguments in order to have them this way in
history. This allows you to re-execute them even when the set of `**/*.orig`
files changes.)

Try flipping `setup no_auto_menu` to `setopt auto_menu` and see if you like it.
This will automatically press <kbd>Tab</kbd> for the second time when the first
<kbd>Tab</kbd> inserts an unambiguous prefix.

If all hosts you SSH to are listed in `~/.ssh/config` (good idea), add this to
improve completions for `ssh` and similar commands:

```zsh
zstyle ':completion:*:ssh:argument-1:'       tag-order  hosts users
zstyle ':completion:*:scp:argument-rest:'    tag-order  hosts files users
zstyle ':completion:*:(ssh|scp|rdp):*:hosts' hosts
```

## fzf

Familiarize yourself with [fzf query syntax](
  https://github.com/romkatv/zsh4humans#interactive-search-with-fzf).

The highlight color can be changed (from the default poisonous pink) with the
following option:

```zsh
zstyle ':z4h:*' fzf-flags --color=hl:5,hl+:5
```

Replace `5` with the color of your choice. Here's a handy one-liner to print
the color table:

```zsh
for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done  #colors
```

That `#colors` at the end is technically a comment but you can use it as a tag.
Next time you need to find this command, press <kbd>Ctrl+R</kbd> and type
`#colors`. Tagging commands in this way is a good habit.

## Word-based widgets

You can bind `*-zword` widgets that operate on whole shell arguments. For
example, `ls '/foo/bar baz'` has two zwords: `ls` and `'/foo/bar baz'`. These
widgets are `z4h-forward-zword`, `z4h-backward-zword`, `z4h-kill-zword` and
`z4h-backward-kill-zword`. There are `word` variants of all these widgets, too.
They behave the same as word-based navigation in Visual Studio Code.

## Oh My Zsh

The default `~/.zshrc` has several references to `ohmyzsh`. They don't do
anything useful. Their only purpose is to show how you can load third-party
plugins. If you don't intend to load plugins from Oh My Zsh, remove all lines
with `ohmyzsh` in them from `~/.zshrc`. This will speed up bootstrapping of Zsh
for Humans when SSH teleporting to a host for the first time.

If you want to load plugins from Oh My Zsh, check what you get from them. The
vast majority of Oh My Zsh plugins don't do anything useful on top of Zsh for
Humans. If you are loading a plugin for the aliases it provides, it's almost
always a better idea to copy the specific aliases to your `~/.zshrc` instead of
loading the plugin.

## Backup and restore

It's highly recommended to [store your dotfiles in a git repository](
  #managing-dotfiles). As far as Zsh for Humans goes, you'll need to store these
files:

- `~/.zshenv`
- `~/.zshrc`
- `~/.p10k*.zsh` (there can be more than one).

You don't need to run Zsh for Humans installer on a new machine. Simply
copy/restore these files and Zsh for Humans will bootstrap itself. If you don't
have zsh on the machine, you can bootstrap Zsh for Humans from any Bourne-based
shell with the following command:

```sh
Z4H_BOOTSTRAPPING=1 . ~/.zshenv
```

## vi mode

The installer refuses to do anything if you select *vi* when asked about your
preferred keymap. If you don't mind manually defining a few bindings, you can
use Zsh for Humans in vi mode.

- Select *emacs* when asked by the installer about your preferred keymap.
- Add `bindkey -v` below `z4h init` in `~/.zshrc`.
- Add your own bindings with `bindkey` or `z4h bindkey` below `bindkey -v`.

## Managing dotfiles

It's highly recommended to store your dotfiles in a git repository. This allows
you to restore your shell environment when your development machine dies. It
also lets you synchronize dotfiles across different development machines. If you
aren't using [SSH teleportation](#SSH), you can also use git to pull dotfiles
onto remote hosts. With SSH teleportation this is automatic.

There are many tools out there that help you with dotfiles management. Choose
what you like. As an option, here's what the author of Zsh for Humans uses.

> I have two git repos where I store my stuff: [dotfiles-public](
>   https://github.com/romkatv/dotfiles-public) and dotfiles-private. Both are
> overlaid over `$HOME` (that is, their worktree is `$HOME`), so I can version
> any file without moving or symlinking it. I sync dotfiles between my dev
> machines (a desktop and two laptops) with [sync-dotfiles](
>   https://github.com/romkatv/dotfiles-public/blob/master/dotfiles/functions/sync-dotfiles),
> which I run manually. This function synchronizes both repos.
> 
> I store command history in dotfiles-private. There is a separate file per
> combination of local and remote machine (there is no remote machine for
> commands executed locally). The point of this separation is twofold. The first
> reason is that it gives local history priority: when I hit <kbd>Ctrl+R</kbd>
> on machine *A*, commands that I ran on machine *A* are displayed before the
> commands from other machines (assuming I'm sharing history from other machines
> with *A*). The second reason is that it avoids merge conflicts because every
> history file is modified only on one machine.
> 
> There are a few more important bits to my dotfiles management:
> 
> - [my_git_repo](
>     https://github.com/romkatv/dotfiles-public/blob/8784b2702621002172ecbe91abe27d5c62d95efb/.p10k.zsh#L45-L52)
>   prompt segment.
> - [toggle-dotfiles](
>     https://github.com/romkatv/dotfiles-public/blob/master/dotfiles/functions/toggle-dotfiles)
>   zle widget.
> - A [keybinding](
>     https://github.com/romkatv/dotfiles-public/blob/8334d8932eabddaf4569de4c3e617b2e911851b4/.zshrc#L115-L118)
>   for `toggle-dotfiles`.
> 
> When I press <kbd>Ctrl+P</kbd> once, I get `public` showing up in prompt and
> git status in prompt corresponds to dotfiles-public repo. All `git` commands
> also target this repo. So if I'm in `~/foo/bar` and want to add `./baz` to
> dotfiles-public, I hit <kbd>Ctrl+P</kbd> and type `git add baz`, `git commit`,
> etc. If I hit <kbd>Ctrl+P</kbd> another time, it activates dotfiles-private.
> Another <kbd>Ctrl+P</kbd> gets me to normal state.

### Alternative `ZDOTDIR`

By default zsh startup files are stored in the home directory. If you want to
store them in `~/.config/zsh` instead, use [this script](
  https://gist.github.com/romkatv/ecce772ce46b36262dc2e702ea15df9f) to migrate.
Note that `~/.zshenv` will still exist. Without it zsh won't know where to look
for startup files.

## Privileged shell

You can open a privileged shell with `sudo -Es`. This will start zsh as `root`
with your regular rc files and `$HOME` will point to your regular home
directory.

## Homebrew

When referencing files and directories managed by [Homebrew](https://brew.sh/),
you can rely on `HOMEBREW_PREFIX` being automatically set. This is much faster
than invoking `brew --prefix`. For example, here's how you can load
[asdf](https://github.com/asdf-vm/asdf):

```zsh
z4h source -- ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh}
```

This line won't do anything unless `asdf` has been installed with `brew`.
