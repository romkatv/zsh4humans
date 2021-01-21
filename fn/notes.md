Write man pages: `man z4h`, `man z4hssh`, etc.

---

Implement completions for `z4h`.

---

Make `z4h help` more useful.

---

Implement `z4h bindkey`. `z4h bindkey -l` should list bindings in a nice table with sections. All
widgets should have a human-readable description.

`z4h bindkey -L [array]` should list all bindings in `z4h bindkey` command format. If `array` is
specified, it's filled with `z4h bindkey` commands that can be passed through `eval`. `-r escseq`
should allow binding raw escape sequences. By default should warn when something got unbound. Can be
turned off with `-q`.

```zsh
zh4 bindkey emacs,viins 'up','ctrl-p' z4h-up-local-history
```

---

`vicmd` has `^P` bound to `up-history` by default. It should probably use bound to the same thing
but with local history.

`vicmd` has no bindings for global history. It should.

---

Add "Try it locally" to docs. Basically, create a directory and make it `ZDOTDIR`.

---

Add `z4h replicate [-f] [-b dir] [var=val]...`. It should have its own `:z4h:replicate: files`
style. Argument `ZDOTDIR=$HOME` is implied. All zsh startup files that don't exist in the current
`ZDOTDIR` should also not exist in the target. `-b ''` disables backup. The default argument is
something like `$ZDOTDIR/z4h-backup.date-time`. Files should be stored there with subdirectories all
the way from `/`. `-f` causes silent action, including backing up or deleting files. If not set,
`z4h replicate` first prints the whole plan of what it's going to do (move this file here, copy that
file there, etc.) and asks for confirmation.

---

Add `z4h uninstall`.

---

Add `install` script that people can download and run. Should have a wizard inside.

---

Try to make this work:

```zsh
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.*' insert-sections true
```

`man printf<tab>` should show:

```text
1  printf -- general commands
3  printf -- library functions
3p printf -- library functions [POSIX]
```

Maybe this can be done by writing a custom completion function for `man` and enabling it with
`compdef`.

---

Install `bat`.

---

Add options to `z4h chsh`. Perhaps `-v` so that it prints what your login and current shells are
and what it's going to do about it. Also add `-r` or something to prevent the creation of
`no-chsh`. Maybe `-f` to ignore `no-chsh` and to call `chsh` even if it seems unnecessary.
Should return `0` if login shell is current shell or if it successfully changes it. Should return
`1` if user says "no" and `2` on errors.

---

Move `z4h chsh` to `z4h-chsh`.

---

`zcompile` autoloadable files.

---

Create `fn` directory similarly to `bin`. Add it to `fpath`.

---

Add `:z4h:fzf disable yes`. List: `fzf`, `fzf-bin`, `fzf-tab`, `powerlevel10k`, `extra-completions`,
`autosuggestions`, `syntax-highlighting`. This disabled cloning and all usage.

---

Add `:z4h:fzf update no`. The list is the same as for `disable` plus `z4h`.

---

Add `:z4h:fzf git-clone-flags` and `:z4h:fzf git-pull-flags`.

---

Add `-f` to `z4h clone` to force `Z4H_UPDATE=1` behavior. 

---

Add `z4h download [-f] [-q] [-o file] url` that uses `curl` or `wget`. Respects `Z4H_UPDATE` unless
`-f` is specified.

---

Add `z4h-recovery-shell`. Copy from https://github.com/zsh4humans/core/blob/master/init.zsh. Bind
it to something. Defend against builtins being overridden by functions or disabled.

---

Add `_z4h_intro`. Copy from https://github.com/zsh4humans/core/blob/master/init.zsh.

---

Add `_z4h_err`. Copy from https://github.com/zsh4humans/core/blob/master/init.zsh.

---

Add this:

```zsh
zstyle :z4h: hidden-files [ignore|show|recurse]
```

If not `ignore`, should set `dotglob`, add `-A` to `ls`, make `alt-down` and `alt-f` show hidden
leaves. `recurse` should make `alt-down` and `alt-f` recurse hidden directories.

Will need to find another example of modifying aliases in `.zshrc` (currently it adds `-A` to `ls`).

---

Make `cd <alt-f>` consistent with `alt-down`.

---

Check if `alt-f` works on alpine (busybox).

---

Add options I like directly to `.zshrc`. They'll also serve as example. (Not sure if there are any
that aren't already set in `z4h.zsh`.)

---

Check what happens when running `sudo zsh`. Consider adding `$USER` to `$Z4H`.

---

Name all private functions like this: `-z4h-foo-bar`.

---

Make `-z4h-clone` (or rather `-z4h-clone`) autoloadable.

---

Replace `git pull` with `git fetch origin $ref` followed by `git reset --hard origin/$ref`. If the
latter fails, try `git clean -df` and repeat `git reset`. If the whole thing fails, try `git clone`.

---

`-z4h-clone` should print "installing" or "updating" based on the presence of the target directory.
It shouldn't produce additional output on success.

---

Restore "downloading z4h.zsh" message in `.zshrc`.

---

Change the structure of `$Z4H` to this:

```text
.
├── bin
├── romkatv
│   └── zsh4humans
│       ├── fn
│       │   ├── -z4h-clone
│       │   └── z4h-help
│       ├── main.zsh         # defines and calls _z4h_prelude, defines z4h, etc.
│       └── z4h.zsh          # the same as $Z4H/z4h.zsh but could be newer version; not used
├── zsh-users
│   └── zsh-autosuggestions
└── z4h.zsh                  # downloaded by zshrc
```

`z4h.zsh` is in fact a pure POSIX sh script. It looks like this:

```sh
if [ -e "$Z4H"/zsh4humans/main.zsh ]; then
  . "$Z4H"/zsh4humans/main.zsh
  return
fi

# git clone, curl or wget romkatv/zsh4humans

. "$Z4H"/zsh4humans/main.zsh
```

`romkatv/zsh4humans` shouldn't be hard-coded but derived from `$Z4H_URL`.

It's not very important to update this file. The only case where it executes to the end after the
initial installation is when `z4h` self-update gets aborted in the very short time window where
`romkatv/zsh4humans` is renamed. So it's OK to never update the root `z4h.zsh`. But updating it
is also OK (`cp` + `mv` should be easy enough).

---

Use src branch of powerlevel10k. When updating, use the following algorithm:

- if there is more than one `gitstatus/usrbin/gitstatusd-*`, nuke them all
- rename `gitstatus/usrbin/gitstatusd-*`
- `git pull`
- rename `gitstatus/usrbin/gitstatusd-*` back
- run `gitstatus/install`

When initializing, check if there is exactly one `gitstatus/usrbin/gitstatusd-*`. If not, nuke
all and run `gitstatus/install`.

This way `gitstatus/install` is called only when installing or updating, so it's ok if it runs
`uname` (by the way, change `gitstatus` to use `uname -sm`). We also avoid downloading `gitstatusd`
when it doesn't change.

---

Try harder when looking for zsh. Check `command zsh`, `$SHELL`, `/usr/local/bin/zsh`,
`/usr/bin/zsh`, `/bin/zsh` and `~/.zsh-bin/bin/zsh`, in this order.

---

Add `-z4h-restart` (or `z4h restart`?) and use it instead of plain `exec $_z4h_exe`. This function
should check whether `$_z4h_exe` is good before execing it.

```zsh
$_z4h_exe -fc '[[ $ZSH_VERSION == (5.<4->*|<6->.*) ]]'
```

Maybe also check that `zmodload zsh/zselect` and `autoload add-zsh-hook` work.

If `$_z4h_exe` is not good, try to find a good one. If there aren't any, install zsh-bin. If
everything fails, keep current prompt. Basically the same thing as `_z4h_prelude`.

---

Use some kind of counter to detect exec loop during initialization.

---

Figure out how to allow customization of zsh-bin installation location. This should be defined with
`zstyle`, so it won't be available when we actually need to install zsh-bin. Install it to `$Z4H`,
`exec` into zsh, and then move zsh-bin to its intended location.

Should it be allowed to put zsh-bin in `$Z4H`? One problem with this is that `chsh` becomes very
dangerous. OK in ssh though? Probably better to disallow putting zsh-bin under `$XDG_CACHE_HOME`
or `~/.cache`.

```zsh
zstyle :z4h:    zsh-installation-dir /usr/local ~/.local
zstyle :z4h:ssh zsh-installation-dir /usr/local ~/.local
```

If there is more than one option, ask the user to choose. Mark options that would require `sudo`.

---

Make `persist=1` option in `zstyle :z4h:ssh files` the default and remove support for `persist`.

---

Make `LS_COLORS` less obnoxious on NTFS.

---

When `main.zsh` is being sourced, traverse the stack to find `.zshrc` and export `ZDOTDIR` pointing
to its directory.

---

Remove all uses of `$TTY` before `z4h init`. Instead, check `[[ -t 0 && -t 1 ]]`.

---

Add this:

```zsh
zstyle :z4h:locale lang  'c' 'en_us' 'en_gb' 'en_*' '*'
zstyle :z4h:locale force no  # if 'no', locale is changed only when encoding is not UTF-8
```

Set locale early in `z4h install`.

---

Add this:

```zsh
zstyle :z4h:fzf-tab             channel stable
zstyle :z4h:syntax-highlighting channel dev
zstyle :z4h:powerlevel10k       git-ref src

zstyle :z4h:fzf-tab:channel     stable fca05e66d1c397cb5e72e8b185b1c3d1a0fc063d
zstyle :z4h:fzf-tab:channel     dev    master
```

If `git-ref` is set, it wins. Otherwise commit is derived from `channel`.

---

Remove `~/.zshrc` from master branch.

---

Add this:

```zsh
z4h add-hook --after '*' --before 'foo*' --after 'foobar' preinit powerlevel10k _z4h-powerlevel10k-init arg1 arg2

z4h run-hooks preinit arg3 arg4

z4h preinit
```

- Ordering constraints are applied in the order they are specified.
- `z4h preinit` runs `z4h run-hooks preinit`. It complains if executed for the second time.
- The precmd hook runs `z4h postinit` if it hasn't run yet. This allows users to run it manually.
- If `_z4h_powerlevel10k_init arg1 arg2` is not specified, it defaults to `powerlevel10k`.
- It's OK to use `-a` and `-b` instead of `--after` and `--before`.

`.zshrc` will look like this:

```zsh
. "$Z4H"/z4h.zsh || return

z4h use zsh-syntax-highlighting
z4h use powerlevel10k

z4h install  # installs and/or updates everything
z4h preinit  # enables instant prompt, sources most things, sets parameters, etc.
z4h postinit # runs compinit and sources zsh-syntax-highlighting; called from precmd if not called called explicitly
```

`z4h use foo` calls `z4h-use-foo`, which in turn calls `z4h add-hook` a few times and nothing else.

---

Add this:

```zsh
if z4h use -t powerlevel10k; then  # is powerlevel10k used?
  ...
fi
```

---

Add config presets:

```zsh
. "$Z4H"/z4h.zsh || return

zstyle :z4h: config-version 1.0.0  # <==

z4h use zsh-syntax-highlighting
z4h use powerlevel10k
...

```

`config-version` can be used by the core code to do things differently but its primary purpose is
to set default values of various parameters, styles, options, bindings, etc.

All `z4h use` directives should be in `.zshrc`. `z4h install` and `z4h preinit` should also be in
`.zshrc`. Everything else should be in preset.

---

Make `z4h ssh` use the same directories (`ZDOTDIR`, `Z4H`, etc.) as local.

Make setup and teardown configurable through `zstyle`.

```zsh
zstyle ':z4h:ssh:*' setup my-ssh-setup

function my-ssh-setup() {
  local ssh_args=("$@")
  z4h ssh-send-env FOO $foo
  z4h ssh-send-env BAR
  z4h ssh-eval 'baz=qux'
  z4h ssh-send-file -f /foo/bar '$FOO/baz'
}
```

All these commands must be applied in the order they are listed. Remote code must be interpreted
by zsh (hence `$FOO/baz` is OK without quotes).

`ssh-send-file` should be able to send directories. The meaning of trailing slash in source and
`destination` should be the same as in `rsync`.

---

`z4h ssh` should be able to send history and then to retrieve it. For retrieving there needs to
be `teardown` hook similar to `setup`.

---

`z4h ssh` should perform setup and interactive connection with these SSH options:

```
-o 'ControlMaster auto' -o 'ControlPath ~/.ssh/control-master-%r@%h:%p' -o 'ControlPersist 10'
```

These can be overridden via zstyle.

---

Create `zle-experimental-save-restore-cursor` branch in `zsh`. Sync it to 5.8 and add `fix-sigwinch`
code on top. Guard the new code with `ZLE_EXPERIMENTAL_SAVE_RESTORE_CURSOR`.

Create a patch from this commit and store it in `zsh-bin`. Modify `build` to apply the patch.
Set patchlevel to the commit hash from `zle-experimental-save-restore-cursor`.

Add `ZLE_EXPERIMENTAL_SAVE_RESTORE_CURSOR=1` to zsh4humans.

---

Add an option to specify the minimum required zsh version. It should also allow specifying that you
really want zsh from zsh-bin and not some other zsh 5.8.

---

Add these straight to `.zshrc`?

```zsh
zstyle ':completion:*' sort false
zstyle ':completion:*' list-dirs-first true
```

It would be nice to add `--group-directories-first` to `ls` for consistency but it's tricky because
it's not POSIX.

---

Figure out if `_approximate` matcher works and whether it's worth it.

---

Implement syntax highlighting of preview in `z4h-fzf-history` with `zsh-syntax-highlighting`. To do
this, start a companion `zsh` (like in gitstatus), load `zsh-syntax-highlighting` there (make sure
to disable widget wrapping as it's very slow) and communicate with it over pipes.

---

Replace this status message from `z4h reset`:

```text
z4h: cloning zsh4humans/powerlevel10k
```

With this:

```text
z4h: cloning romkatv/powerlevel10k
```

---

Revamp vi bindings. See https://github.com/zsh-vi-more/vi-motions and
https://github.com/softmoth/zsh-vim-mode.

Cursor shape changes should go to p10k?

---

When looking for zsh, check `/etc/shells`.

If there are several zsh versions installed, pick the one from `PATH`. If it's too old, pick
the latest latest from the rest.

---

When zsh-bin installs zsh, it should ask whether to add it to /etc/shells. By default it should
do this only when the installation directory is world-readable.

---

If `ZDOTDIR` is set and doesn't point to `$HOME` when `install` starts, ask whether to install to
`$HOME` or `$ZDOTDIR`. Backups should go under the same directory.

---

Create `~/.zshenv` with just `setopt no_global_rcs` in it.

---

Add `z4h use [-d] [-f] [module]...` where `module` is one of the built-in things:
`zsh-users/zsh-autosuggestions`, `bindkey`, `term-title`, etc.

Without `-d` modules are added to `_z4h_use_queue`. With `-d` they are added to
`_z4h_use_queue_d[-1]`. The latter is an array with nul separated lists as its elements.

On `-f` it should install a `precmd` hook called `-z4h-precmd-$#_z4h_install_queue_d` that calls
`${(0)_z4h_install_queue_d[${0#-z4h-precmd-}]}`, and call `-z4h-use-rigi $_z4h_use_queue`.

`-z4h-use-rigi` should be the same as the current `-z4h-init` with a bunch of conditions added in:

```zsh
if (( ${@[(Ie)zsh-users/zsh-autosuggestions]} )); then
  ...
fi
```

It should issue warnings (but not fail) for arguments it doesn't recognize.

---

Add this:

```zsh
zstyle ':z4h:' preset rigi
```

Could support multiple values for preset "addons". Presets can be used by the core code to do things
differently but its primary purpose is to set default values of various parameters, styles, options,
bindings, etc.

`z4h init` will simply call the preset function -- `-z4h-init-rigi`. The latter will do this:

```zsh
local -a mods=()
zstyle -T :z4h:zsh-users/zsh-autosuggestion install && mods+=zsh-autosuggestion
...
z4h install -f -- $mods

local -a mods=()
zstyle -T :z4h:compinit use && mods+=compinit
...
z4h use -d -- $mods

local -a mods=()
zstyle -T :z4h:zsh-users/zsh-autosuggestion use && mods+=zsh-autosuggestion
...
z4h use -f -- $mods
```

---

Use `fc` to write history in `z4h-stash-buffer`. Might need `fc -p`.

---

Support this for local development:

```
zstyle ':z4h:romkatv/powerlevel10k' channel command ln -s ~/powerlevel10k
```

The command is called with an extra argument designating target directory.

---

Move the top of `~/.zshrc` to `~/.zshenv`. To make it work, `z4h ssh` will need to start
interactive sh.

---

Move `$ZDOTDIR` to `~/.zsh`, leave just `~/.zshenv` in the home directory. Also leave a symlink
form `~/.zshrc` to `~/.zsh/.zshrc` so that users and bad tools don't get confused.

---

When retrieving files in `z4h ssh` and there is no base64 either on local or remote host, use this
for encoding:

```zsh
od -t x1 -An -v | tr -d '[:space:]'
```

Decode with `sysread`, followed by `print -n -- ${buf//(#m)??/'\x'$MATCH}`. This can be done
while reading from the network to speed things up.

This encoding has 50% overhead compared to base64.

---

Make history over ssh more robust so that it never gets overwritten.

---

Protect scripts against rogue aliases as functions as described in the EXAMPLES section of
https://pubs.opengroup.org/onlinepubs/9699919799/utilities/command.html. Use `unset -f` on
all builtins, too.

```zsh
IFS=' 	
'
'unset' '-f' 'unalias' '[' 'cat' ...
'unalias' '-a'
PATH="$(command -p getconf PATH):$PATH"
...
```

This can be broken only by function `unset`.

There is a similar but different example at
https://pubs.opengroup.org/onlinepubs/9699919799/utilities/env.html.

---

Add `z4h pack` that produces `install-z4h` file. It should be similar to the bootstrap script
created by `z4h ssh`. It should be all ASCII. It should respect `:z4h:pack:tag extra-files` and
similar. `tag` is the value passed via optional `-t tag`. Defaults to emty. This allows one to
define different file sets for different packs. By default the same set of files as sent by ssh
should be packed, plus all history files.

---

Support `fzf` customization via `zstyle`. Add nice support for bindings (including continuous
completion and query insertion via fake actions like `z4h-accept-and-repeat` and
`z4h-accept-query`). Also allow for low level overrides.

```zsh
zstyle :z4h:expand-or-complete:fzf command  my-fzf
zstyle :z4h:expand-or-complete:fzf bindings ctrl-u:kill-line
zstyle :z4h:expand-or-complete:fzf flags    --no-exact
```

`flags` and `bindings` have the semantics of *extra* flags and bindings.

Extra flags should be added at the front of standard flags because the first flag wins.
All flags should be passed to the command (`my-fzf` above) where users can munge them any way they
like. Use `--foo=bar` syntax to make it easier to remove flags (one argument -- one flag).

Extra bindings could be added at the end of standard bindings because the last binding wins.
However, in order to handle fake actions such as `z4h-accept-and-repeat` it'll probably be necessary
to resolve binding conflicts within z4h. The goal is to allow this syntax for disabling continuous
completion:

```zsh
zstyle :z4h:expand-or-complete:fzf extra-bindings tab:ignore
```

`ignore` could be any other legit action. The point is that by default `tab` is bound to
`z4h-accept-and-repeat` but we rebind it.

---

Support preview customization in fzf. At the very least allow changing the size (down to 0) of
preview in history.

---

<kbd>Ctrl+/</kbd> is a bad binding on some keyboard layouts. See #35.

---

`run-help` has some issues with aliases. See
https://github.com/romkatv/zsh4humans/issues/35#issuecomment-657515701.

---

Currently `find` for recursive completions is called with `-xdev`. This should be customizable.
See https://github.com/romkatv/zsh4humans/issues/35#issuecomment-660477146.

---

Define `command_not_found_handler` for more operating systems (similarly to how it's done for
Homebrew and Debian).

---

`command_not_found_handler` should simultaneously use Homebrew and `/usr/lib/command-not-found` if
both are available.

---

Make `Alt+{Up,Left,Right}` work within `fzf`. See [this comment](
  https://github.com/romkatv/zsh4humans/issues/35#issuecomment-674357739).

---

Colorize files in git completions the same way they are shown in `git status`.

---

Propagate arguments of `zsh -ic "..."` trhough `exec` when switching to a different zsh.

---

Make `run-help z4h source` work.

---

`z4h ssh` should start login shell.

---

When doing `exec $_z4h_exe`, preserve `-l`.

---

Document binding syntax in `z4h help bindkey`.

---

Make it safe to continue using an old shell after z4h has been updated in another shell.

Assuming that flock works, it can be done as follows. Rename `Z4H` to `Z4H_CACHE_DIR` in
`~/.zshenv`. Within `$Z4H_CACHE_DIR` store:

- `z4h.zsh`
- `last-update-ts`
- `no-chsh`
- `snapshot-00000000` through `snapshot-ffffffff`

`z4h.zsh` should point `Z4H` to the latest snapshot. If there are none, it should create a unique
temporary snapshot which would later be transformed into a regular snapshot by `main.zsh`.
Preferably this should be the same code path as in `z4h update`.

`Z4H_CACHE_DIR` should not propagate through `zsh` the way `Z4H` currently propagates. `Z4H` should
still propagate. It seems like there shouldn't be a requirement that `Z4H_CACHE_DIR` gets set to
the same value in the child shell created by `z4h update` as in the parent.

`main.zsh` should reader-flock its snapshot. If that fails due to the directory being deleted (see
below), it should `exec zsh`.

Whenever `main.zsh` creates a new snapshot, it should do this while holding a writer-flock on
`$Z4H_CACHE_DIR`.

`main.zsh` should scan the existing snapshots while holding a writer-flock on `$Z4H_CACHE_DIR` and
delete all that can be writer-flocked.

On a system where flock always succeeds (WSL1, see https://github.com/Microsoft/WSL/issues/1927),
this would make matters much worse than currently thanks to `main.zsh` thinking that all snapshots
are unused and deleting them. Special code is required in this case.

---

Make this:

```zsh
% ls foo/..<TAB>
```

Complete to this:

```zsh
% ls foo/../
```

However, `..` should never appear in the listing. In addition, this should work as before:

```zsh
touch ..x
ls ..<TAB>
```

It should complete to `ls ..x `.

---

The three minor issues with the integrated tmux that I've mentioned in
https://github.com/romkatv/zsh4humans/issues/35#issuecomment-719639084 are here:

```text
3a8eb6f08fb26ffdad79dae6f00c9a80ba30ecc0f0ee0a142322005f1d28710a */home/romka/notes/z4h-tmuw-issues.md
```

---

See if it's feasible to fix
https://github.com/romkatv/powerlevel10k#horrific-mess-when-resizing-terminal-window by patching
tmux.

---

`kitty @ launch cat` doesn't work. See
https://github.com/romkatv/zsh4humans/issues/35#issuecomment-720134760.

---

`new_os_window_with_cwd` doesn't work in Kitty. See
https://github.com/romkatv/zsh4humans/issues/35#issuecomment-720134760.

---

Make `z4h ssh` work when the target machine doesn't have internet.

Implement `z4h fetch` that on a local machine would be a wrapper around `curl`/`wget` and on a
remote machine would send a request via the marker to the local. Local machine would fetch the
file (via `z4h fetch`, naturally) and upload it via `ssh host 'cat >$dst.$$ && mv $dst.$$ $dst`.
The file should have error code, stderr and finally the file.

There is `curl` in `~/.zshenv`. In order to deal with that, add one more condition to `~/.zshenv`:

```zsh
if command -v z4h >/dev/null 2>&1; then
  z4h fetch "$Z4H_URL"/z4h.zsh >"$Z4H"/z4h.zsh.$$
elif ...
fi
```

`z4h` will be a function that can handle nothing but this command.

`z4h fetch` should have a whitelist of URLs it can handle (for security).

---

Implement `z4h clipboard-{cut,copy,paste}` that can work over ssh. Add this to `.zshrc`:

```zsh
# Should clipboard-related z4h commands on the local host use
# the OS clipboard ('system') or a file ('file')?
zstyle :z4h: clipboard system

# Allow remote hosts access to the clipboard of the client? If set to 'no',
# clipboard-related z4h functions on the remote host will use a file.
zstyle ':z4h:ssh:*' client-clipboard no

# Copy the current command line to clipboard.
z4h bindkey z4h-copy-bufer-to-clipboard Ctrl+X

alias x='z4h clipboard-copy'   # write stdin to clipboard
alias c='z4h clipboard-copy'   # write stdin to clipboard and to stdout
alias v='z4h clipboard-paste'  # write clipboard to stdout
```

---

Add `z4h {slurp,barf}` similar to `z4h clipboard-{cut,copy,paste}`.

---

Make <kbd>Ctrl+R</kbd> display the preview right on the command line. Before opening it, set
`BUFFER` to `$'..\n\n\n'` so that it scrolls a bit.

---

Set `TERM=screen-256color` by default. Make it easy to override it per-app and the default as well.

```zsh
zstyle :z4h:terminfo:     term screen-256color
zstyle :z4h:terminfo:ssh  term screen-256color
zstyle :z4h:terminfo:sudo term screen-256color
```

These styles should be consulted only when using tmux with 256 colors.

Hm, those styles won't work because we need to define functions for all apps (`ssh`, `sudo`, etc.).
This, then?

```zsh
zstyle :z4h:tmux term                  screen-256color
zstyle :z4h:tmux force-screen-256color ssh sudo
zstyle :z4h:tmux force-tmux-256color   kak vi
```

Or maybe hook `TRAPDEBUG` and use the first syntax?

Or do it like this:

```zsh
zstyle :z4h: term-spec {ssh,sudo,docker}:{tmux-256color:screen-256color,alacritty:xterm-256color}
```

This isn't good. Figure out how to make it possible to add commands without wiping the default ones.

---

Profile tmux when printing a ton of data to the terminal and see if there is an easy way to speed
it up (likely not).

---

`$TTY` is not writable when doing something like this:

```zsh
% sudo useradd -ms =zsh test
% sudo -iu test
% [[ -w $TTY ]] || echo 'not writable'
```

This breaks a bunch of things. For example, <kbd>Tab</kbd> doesn't work. To fix this, `dup` one of
the standard file descriptors into `_z4h_tty_fd` on startup and use it through the code instead of
`$TTY`.

---

Change the way <kbd>Up</kbd>/<kbd>Down</kbd> work with multi-line commands. Pressing <kbd>Up</kbd>
twice should always have the effect of fetching from history twice, whether the command line was
empty or not to begin with.

---

Consider changing <kbd>Up</kbd>/<kbd>Down</kbd> so that it searches for individual words. There
is `HISTORY_SUBSTRING_SEARCH_FUZZY=1` for it.

---

Add a banner to `~/.zshrc` that requires confirmation. Add the same banner to `install`. When
the user consents during the installation, remove the banner from `~/.zshrc`.

The banner should say that this is bleeding edge, blah, blah.

---

Do not install zsh-bin if the only thing missing from the stock is terminfo. Also remove the
requirement for `zsh/pcre`. Better yet, add a `zstyle` for required modules.

The goal here is to avoid installing zsh-bin when using macOS Big Sur or having zsh from brew.

---

Make zsh-bin work like `tmux -u`. That is, assume UTF-8 always. If there is no UTF-8 locale on the
machine (or maybe if the current locale is not UTF-8) require zsh-bin.

---

Make integrated tmux work with `TERM=xterm-256color`.

---

Remove client-server architecture from the integrated tmux. Would be nice to put it in the same
process as zsh but it might make it more difficult to update tmux. For starters it's probably a good
idea to have zsh in one process and everything else in another (`z4hd`).

Actually, maybe this is a bad idea. Maybe it's better to run `z4hd` the way `tmux` currently runs.
Just add `version` to the socket name. The latter can be done right now, without any architectural
changes.

---

Add a special escape code to the integrated tmux that would allow identifying via a roundtrip to
the TTY. Since other terminals won't reply, the logic should be like this:

1. Write "are you integrated tmux".
2. Write "where is cursor".
3. Read the cursor positions. If a special response preceeds it, this is integrated tmux.

---

Add `z4h [-r] output` that prints the output of the last command. With `-r` the output is printed
without styling (no colors, etc.). Print a warning if the output has more than `N` bytes (or
terminal lines?). `N` should be configurable.

Implement this by printing a marker in preexec and another in precmd.

---

Complain if users override `TERM` when using integrated tmux.

---

Figure out better key bindings for macOS.

---

If using iTerm2 with the default color scheme, change it to Tango Dark with dark-grey for black.
Do it in `p10k configure` for now.

---

`z4h ssh` should backup remote files to `~/zsh-backup/ssh`. Each file/directory just once. When
backing up, write a message to the tty saying so. Have a `zstyle` to control this.

---

List `~/.tmux.conf` in `~/.zshrc` among the files to send over ssh.
