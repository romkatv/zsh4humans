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

If https://github.com/Aloxaf/fzf-tab/pull/70 doesn't get accepted, add a workaround. Patch
`_fzf_tab_colorize` by replacing `sort -u -t '\0' -k 2` with `-z4h-fzf-tab-colorize-sort`. The
latter does what the PR does. Do this only when `sort` is from busybox.

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

Add locking around writes (only writes). Make sure there is nothing interactive while the lock is
held. Store locks in /var/run. Their names should be derived from `$Z4H`.

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
form `~/.zshrc` to `~/.ssh/.zshrc` so that users and bad tools don't get confused.
