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

Set decent bindings for `viins` and `vicmd`.

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
`.no-chsh`. Maybe `-f` to ignore `.no-chsh` and to call `chsh` even if it seems unnecessary.
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

Add `:z4h:fzf git-ref`. Try to make it work when the user changes `git-ref` without having to store
a separate database that records currently checked out refs.

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

Make `_z4h_clone` (or rather `-z4h-clone`) autoloadable.

---

When `-z4h-clone` fails to `git pull`, try `git reset --hard HEAD` and `git clean -df` followed by
another `pull`. If that also fails, try `git clone`.

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
if [ -e "$Z4H"/romkatv/zsh4humans/main.zsh ]; then
  . "$Z4H"/romkatv/zsh4humans/main.zsh
  return
fi

# git clone, curl or wget romkatv/zsh4humans

. "$Z4H"/romkatv/zsh4humans/main.zsh
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
