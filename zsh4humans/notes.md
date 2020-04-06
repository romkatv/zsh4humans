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
If https://github.com/Aloxaf/fzf-tab/pull/70 doesn't get accepted, add a workaround. If `sort` is
`busybox`, define function `sort` that handles `sort -u -t '\0' -k 2` specially and delegates to
`command sort` for the rest. This function should also start by checking whether `$+commands[sort]`
is still `busybox`. If not, `unfunction` itself and just run `command sort`.
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
Create `func` directory similarly to `bin`.
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
