# Zsh for Humans

Configuration for [Z shell](https://en.wikipedia.org/wiki/Z_shell) that aims to work really well out
of the box. It combines the best Zsh plugins into a coherent whole that feels like a finished
product rather than a DIY starter kit.

If you want a great shell that just works, this project is for you.

## Table of contents

* 1. [Installation](#installation)
* 2. [Try it in Docker](#try-it-in-docker)
* 3. [Usage](#usage)
	* 3.1. [Key bindings](#key-bindings)
		* 3.1.1. [Cursor movement](#cursor-movement)
		* 3.1.2. [Editing](#editing)
		* 3.1.3. [Accepting autosuggestions](#accepting-autosuggestions)
		* 3.1.4. [Completing commands](#completing-commands)
		* 3.1.5. [Searching command history](#searching-command-history)
		* 3.1.6. [Changing current directory](changing-current-directory)
		* 3.1.7. [Miscellaneous](#miscellaneous)
	* 3.2. [Fuzzy search](#fuzzy-search)
	* 3.3. [SSH](#SSH)
* 4. [Customization](#customization)
	* 4.1. [Customizing prompt](#customizing-prompt)
	* 4.2. [Customizing key bindings](#customizing-key-bindings)
	* 4.3. [Customizing appearance](customizing-appearance)
	* 4.4. [Using external commands or files](using-external-commands-or-files)
	* 4.5. [Additional Zsh startup files](additional-zsh-startup-files)
* 5. [Updating](#updating)
* 6. [Configuration files](#configuration-files)
* 7. [Replicating Zsh For Humans on another machine or restoring it from a backup](#replicating-zsh-for-humans-on-another-machine-or-restoring-it-from-a-backup)


## Installation

1. *Optional*: Install [MesloLGS NF](
   https://github.com/romkatv/powerlevel10k/blob/master/README.md#meslo-nerd-font-patched-for-powerlevel10k)
   terminal font.
2. Execute this command.
```shell
if command -v curl >/dev/null 2>&1; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v2/install)"
else
  sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh4humans/v2/install)"
fi
```

The installer backs up the existing Zsh startup files, downloads [.zshrc](
  https://github.com/romkatv/zsh4humans/blob/v2/.zshrc), installs everything necessary for Zsh For
Humans and opens a new shell. It asks for confirmation on every step so that you are always in
control. Installation requires `curl` or `wget`. It does not require `git`, `zsh`, `sudo` or
anything else.

## Try it in Docker

Try Zsh for Humans in a Docker container. You can safely make any changes to the file system. Once
you exit Zsh, the image is deleted.

```zsh
docker run -e TERM -e COLORTERM -w /root -it --rm alpine sh -uec '
  sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh4humans/v2/install)"'
```

## Usage

If you've used Zsh, Bash or Fish, Zsh for Humans should feel familiar. For the most part everything
works as you would expect.

### Key bindings

These are the key bindings that you get with the default `~/.zshrc`. You can
[change them](#customizing-key-bindings).

If you aren't sure what `emacs`, `viins` and `vicmd` mean, you are likely using `emacs` keymap.
You can ignore the other two columns.

#### Cursor movement

| Zle Widget | Description | emacs | viins | vicmd |
| - | - | - | - | - |
| `backward-char` | move cursor one char backward | <kbd>Left</kbd> <kbd>Ctrl-B</kbd> | | |
| `vi-backward-char` | move cursor one char backward (vi style) | | <kbd>Left</kbd> | <kbd>h</kbd> <kbd>Backspace</kbd> <kbd>Ctrl-Backspace</kbd> <kbd>Ctrl-H</kbd> |
| `forward-char` | move cursor one char forward | <kbd>Right</kbd> <kbd>Ctrl-F</kbd> | | |
| `vi-forward-char` | move cursor one char forward (vi style) | | <kbd>Right</kbd> | <kbd>Space</kbd> <kbd>l</kbd> |
| `backward-word` | move cursor one word backward | <kbd>Ctrl-Left</kbd> <kbd>Alt-B</kbd> | | |
| `vi-backward-word` | move cursor one word backward (vi style) | | <kbd>Ctrl-Left</kbd> | <kbd>b</kbd> |
| `forward-word` | move cursor one word forward | <kbd>Ctrl-Right</kbd> <kbd>Alt-F</kbd> | | <kbd>w</kbd> |
| `vi-forward-word` | move cursor one word forward (vi style) | | <kbd>Ctrl-Right</kbd> | |
| `z4h-up-local-history` | move cursor up or fetch [previous local history event](#searching-command-history) | <kbd>Up</kbd> <kbd>Ctrl-P</kbd> | <kbd>Up</kbd> | <kbd>k</kbd> |
| `z4h-down-local-history` | move cursor down or fetch [next local history event](#searching-command-history) | <kbd>Down</kbd> <kbd>Ctrl-N</kbd> | <kbd>Down</kbd> | <kbd>j</kbd> |
| `z4h-up-global-history` | move cursor up or fetch [previous global history event](#searching-command-history) | <kbd>Ctrl-Up</kbd> | <kbd>Ctrl-Up</kbd> | |
| `z4h-down-global-history` | move cursor down or fetch [next global history event](#searching-command-history) | <kbd>Ctrl-Down</kbd> | <kbd>Ctrl-Down</kbd> | |
| `beginning-of-line` | move cursor to the beginning of line | <kbd>Home</kbd> <kbd>Ctrl-A</kbd> | | |
| `vi-beginning-of-line` | move cursor to the beginning of line (vi style) | | <kbd>Home</kbd> | <kbd>Home</kbd> |
| `end-of-line` | move cursor to the end of line | <kbd>End</kbd> <kbd>Ctrl-E</kbd> | | |
| `vi-end-of-line` | move cursor to the end of line (vi style) | | <kbd>End</kbd> | <kbd>End</kbd> <kbd>$</kbd> |
| `z4h-beginning-of-buffer` | move cursor to the beginning of buffer | <kbd>Ctrl-Home</kbd> <kbd>Alt-Home</kbd> | <kbd>Ctrl-Home</kbd> <kbd>Alt-Home</kbd> | <kbd>Ctrl-Home</kbd> <kbd>Alt-Home</kbd> |
| `z4h-end-of-buffer` | move cursor to the end of buffer | <kbd>Ctrl-End</kbd> <kbd>Alt-End</kbd> | <kbd>Ctrl-End</kbd> <kbd>Alt-End</kbd> | <kbd>Ctrl-End</kbd> <kbd>Alt-End</kbd> |

#### Editing

| Zle Widget | Description | emacs | viins | vicmd |
| - | - | - | - | - |
| `delete-char` | delete the character under the cursor | <kbd>Delete</kbd> | <kbd>Delete</kbd> | <kbd>Delete</kbd> |
| `vi-delete-char` | delete the character under the cursor (vi style) | | | <kbd>x</kbd> |
| `backward-delete-char` | delete the character behind the cursor | <kbd>Backspace</kbd> | <kbd>Backspace</kbd> | |
| `vi-backward-delete-char` | delete the character behind the cursor (vi style) | | <kbd>Ctrl-Backspace</kbd> <kbd>Ctrl-H</kbd> | <kbd>X</kbd> |
| `backward-kill-word` | delete the previous word | <kbd>Ctrl-Backspace</kbd> <kbd>Alt-Backspace</kbd> <kbd>Ctrl-W</kbd> <kbd>Ctrl-H</kbd> | | |
| `vi-backward-kill-word` | delete the previous word (vi style) | | <kbd>Ctrl-W</kbd> | | |
| `kill-word` | delete the next word | <kbd>Ctrl-Delete</kbd> <kbd>Alt-Delete</kbd> <kbd>Alt-D</kbd> | | |
| `backward-kill-line` | delete from the beginning of the line to the cursor | <kbd>Alt-K</kbd> | | |
| `kill-line` | delete from the cursor to the end of the line | <kbd>Ctrl-K</kbd> | | |
| `kill-whole-line` | delete the whole current line | <kbd>Ctrl-U</kbd> | | |
| `vi-kill-line` | delete the whole current line (vi style) | | <kbd>Ctrl-U</kbd> | |
| `kill-buffer` | delete all lines | <kbd>Alt-J</kbd> | | |
| `undo` | undo the last edit | <kbd>Ctrl-/</kbd> | <kbd>Ctrl-/</kbd> | |
| `redo` | redo the last undone edit | <kbd>Alt-/</kbd> | <kbd>Alt-/</kbd> | <kbd>u</kbd> |

#### Accepting autosuggestions

All key bindings that move cursor can accept *command autosuggestions*. For example, moving the
cursor one word to the right will accept that word from the autosuggestion.

By default, <kbd>Right</kbd> accepts one character from the autosuggestion (because it moves cursor
one character forward) but you can [rebind it](#customizing-key-bindings) to accept the whole
autosuggestion instead.

There is one special binding that is specific to autosuggestions.

| Zle Widget | Description | emacs | viins | vicmd |
| - | - | - | - | - |
| `z4h-autosuggest-accept` | accept the whole autosuggestion without moving the cursor | <kbd>Alt-M</kbd> | <kbd>Alt-M</kbd> | <kbd>Alt-M</kbd> |

Autosuggestions in Zsh For Humans are provided by [zsh-autosuggestions](
  https://github.com/zsh-users/zsh-autosuggestions). See its homepage for more information.

#### Completing commands

| Zle Widget | Description | emacs | viins | vicmd |
| - | - | - | - | - |
| `z4h-expand` | expand an alias, glob or parameter | <kbd>Ctrl-Space</kbd> | <kbd>Ctrl-Space</kbd> | |
| `z4h-expand-or-complete` | complete interactively with [fuzzy search](#fuzzy-search) | <kbd>Tab</kbd> <kbd>Ctrl-I</kbd> | <kbd>Tab</kbd> <kbd>Ctrl-I</kbd> | <kbd>Tab</kbd> <kbd>Ctrl-I</kbd> |
| `fzf-completion` | complete files recursively; great for completing file paths | <kbd>Alt-I</kbd> | <kbd>Alt-I</kbd> | <kbd>Alt-I</kbd> |

When completing with <kbd>Tab</kbd>, you can move the cursor with arrow keys. Editing is mostly
consistent with `emacs` keymap from Zsh For Humans but not quite the same. There are several
additional bindings to accept selection.

| Description | Key Binding |
| - | - |
| accept selection | <kbd>Enter</kbd> |
| mark selection (for accepting multiple entries) | <kbd>Ctrl-Space</kbd> |
| accept selection and trigger another completion right away; great for completing file paths | <kbd>Tab</kbd> |

The content of command completions in Zsh For Humans comes from *completion functions*. For most
commands completion functions are provided by Zsh proper. Additional completion functions are
contributed by [zsh-completions](https://github.com/zsh-users/zsh-completions). See its homepage
for the list of commands it supports.

The UI for interacting with the completion system is provided by
[fzf-tab](https://github.com/Aloxaf/fzf-tab) and [fzf](https://github.com/junegunn/fzf). fzf-tab
is a bridge that connects the powerful Zsh completions system (*completion functions*) with fzf
fuzzy searcher.

#### Searching command history

<kbd>Up</kbd> and <kbd>Down</kbd> fetch commands from history when the cursor is already at the top
or bottom line respectively. Otherwise they just move the cursor. When they do fetch history, they
filter it by the prefix bound by the command line start and the cursor. For example, if you press
<kbd>Up</kbd> when the first line of the command buffer contains `echo hello world` and the cursor
is positioned before `world`, it'll fetch the last executed command that starts with `echo
hello`.

All active shells running under the same user have access to each other's command history in real
time. History events from the current shell together with all history events that happened before
the current shell started are collectively called *local history*. *Global history* contains all
events.

<kbd>Up</kbd> and <kbd>Down</kbd> use local history. Everything else uses global history. Thus,
when you press <kbd>Up</kbd> with empty command line buffer, it fetches the last command executed
in the current shell. Conversely, <kbd>Ctrl-Up</kbd> fetches the last command executed in *any*
shell. The only difference between <kbd>Up</kbd>/<kbd>Down</kbd> and
<kbd>Ctrl-Up</kbd>/<kbd>Ctrl-Down</kbd> is the use of local vs global history.

<kbd>Ctrl-R</kbd> searches over global history. There is no equivalent binding for local history.

| Zle Widget | Description | emacs | viins | vicmd |
| - | - | - | - | - |
| `z4h-up-local-history` | move cursor up or fetch previous local history event | <kbd>Up</kbd> <kbd>Ctrl-P</kbd> | <kbd>Up</kbd> | <kbd>k</kbd> |
| `z4h-down-local-history` | move cursor down or fetch next local history event | <kbd>Down</kbd> <kbd>Ctrl-N</kbd> | <kbd>Down</kbd> | <kbd>j</kbd> |
| `z4h-up-global-history` | move cursor up or fetch previous global history event | <kbd>Ctrl-Up</kbd> | <kbd>Ctrl-Up</kbd> | |
| `z4h-down-global-history` | move cursor down or fetch next global history event | <kbd>Ctrl-Down</kbd> | <kbd>Ctrl-Down</kbd> | |
| `z4h-fzf-history` | [fuzzy search](#fuzzy-search) history from all shells | <kbd>Ctrl-R</kbd> | <kbd>Ctrl-R</kbd> | <kbd>Ctrl-R</kbd> |

#### Changing current directory

These bindings allows you to quickly change current directory without losing command line buffer.
Going to the previous/next directory works similarly to the *Back* and *Forward* buttons in a Web
browser.

| Zle Widget | Description | emacs | viins | vicmd |
| - | - | - | - | - |
| `z4h-cd-back` | `cd` into the previous directory | <kbd>Alt-Left</kbd> | <kbd>Alt-Left</kbd> | <kbd>Alt-Left</kbd> |
| `z4h-cd-forward` | `cd` into the next directory | <kbd>Alt-Right</kbd> | <kbd>Alt-Right</kbd> | <kbd>Alt-Right</kbd> |
| `z4h-cd-up` | `cd` into the parent directory | <kbd>Alt-Up</kbd> | <kbd>Alt-Up</kbd> | <kbd>Alt-Up</kbd> |
| `z4h-cd-down` | `cd` into a subdirectory; uses [fuzzy search](#fuzzy-search) | <kbd>Alt-Down</kbd> | <kbd>Alt-Down</kbd> | <kbd>Alt-Down</kbd> |

Another way to change current directory is to type `cd ~/` and hit <kbd>Alt+I</kbd>. It works with
any directory prefix. <kbd>Alt+I</kbd> completes files with [fuzzy search](#fuzzy-search) but it's
smart enough to recognize that the argument to `cd` must be a directory, so it'll only show those.

If you want create a directory and `cd` into it, use `md`:

```zsh
md foo/bar  # the same as: mkdir -p foo/bar && cd foo/bar
```

This simple function is defined right in your `~/.zshrc` to serve as an example. It comes with a
completion function, too, so that `md fo<TAB>` will complete to `md foo/` but not to `md fo.txt`.

#### Miscellaneous

| Zle Widget | Description | emacs | viins | vicmd |
| - | - | - | - | - |
| `clear-screen` | clear screen and place prompt at the top | <kbd>Ctrl-L</kbd> | <kbd>Ctrl-L</kbd> | <kbd>Ctrl-L</kbd> |
| `z4h-run-help` | show help for the command at cursor | <kbd>Alt-H</kbd> | <kbd>Alt-H</kbd> | <kbd>Alt-H</kbd> |
| `z4h-do-nothing` | do nothing; useful for blocking keys that would otherwise print garbage | <kbd>PageUp</kbd> <kbd>PageDown</kbd> | <kbd>PageUp</kbd> <kbd>PageDown</kbd> | <kbd>PageUp</kbd> <kbd>PageDown</kbd> |

### Fuzzy search

Several UI elements in Zsh For Humans use [fzf](https://github.com/junegunn/fzf) to quickly select
an item from a potentially large list of candidates. You can type multiple search terms delimited by
spaces. For example:

```text
^music .mp3$ sbtrkt !fire
```

| Token     | Match type                 | Description                          |
| --------- | -------------------------- | ------------------------------------ |
| `sbtrkt`  | fuzzy-match                | Items that match `sbtrkt`            |
| `'wild`   | exact-match (quoted)       | Items that include `wild`            |
| `^music`  | prefix-exact-match         | Items that start with `music`        |
| `.mp3$`   | suffix-exact-match         | Items that end with `.mp3`           |
| `!fire`   | inverse-exact-match        | Items that do not include `fire`     |
| `!^music` | inverse-prefix-exact-match | Items that do not start with `music` |
| `!.mp3$`  | inverse-suffix-exact-match | Items that do not end with `.mp3`    |

A single bar character term acts as an OR operator. For example, the following query matches entries
that start with `core` and end with either `go`, `rb`, or `py`.

```text
^core go$ | rb$ | py$
```

See [fzf](https://github.com/junegunn/fzf) homepage for more information.

### SSH

When you SSH to a remote host, you can bring your Zsh For Humans environment along. Simply replace
`ssh` with `z4h ssh`.

```zsh
z4h ssh root@google.com
```

This command connect to the remote host over SSH and starts Zsh with your local configs. The remote
host must have login shell compatible with the Bourne shell (`sh`, `bash`, `zsh`, `ash`, `dash`,
etc.), `curl` or `wget`, and internet connection. Nothing else is required. In particular, the
remote host doesn't need to have Zsh or `sudo`.

Here's what `z4h ssh` does:

1. Archives Zsh config files on the local host and sends them to the remote host.
2. Extracts Zsh config files on the remote host.
3. Sources `.zshrc`, which starts the usual Zsh For Humans bootstrap process.

`ZDOTDIR` and `Z4H` on the remote host both point to `"${XDG_CACHE_HOME:-$HOME/.cache}/z4h-ssh"`.
This prevents clashes with regular Zsh configs if they exist.

The first login to a remote host may take some time. After that it's as fast as normal `ssh`.

For `z4h ssh` to work, you must follow the best practice of [checking for presence of external
external commands and files](#using-external-commands-or-files) before using them in `~/.zshrc`.

## Customization

You can (and should) edit `~/.zshrc` to customize your shell. It's a very good idea to read through
the whole file to see which customization options are in there and to flip some of them to your
liking.

When adding your customizations, put them next to the exiting lines that do similar things. The
default `~/.zshrc` contains the following types of customizations that should serve as examples:

- Export environment variables.
- Extend `PATH`.
- Define aliases.
- Add flags to existing aliases.
- Define functions.
- Source additional local files.
- Load Oh My Zsh plugins.
- Clone and load external Zsh plugins.
- Set shell options.
- Autoload functions.
- Change key bindings.

### Customizing prompt

Prompt in Zsh For Humans is provided by [Powerlevel10k](https://github.com/romkatv/powerlevel10k).
Run `p10k configure` to access its interactive configuration wizard. Further customization can be
done by editing `~/.p10k*.zsh` files. There can be more than one configuration file to account for
terminals with limited capabilities. Most users will ever only see `~/.p10k.zsh`. In in doubt,
consult `$POWERLEVEL9K_CONFIG_FILE`. This parameter is set by Zsh For Humans and it always points
to the config file currently in use.

See [Powerlevel10k](https://github.com/romkatv/powerlevel10k) homepage for more information.

### Customizing key bindings

There are several common key binding customizations that many users apply. They can be achieved
with one-line changes in `~/.zshrc`.

| Customization | How |
| - | - |
| swap the bindings for <kbd>Alt-Arrows</kbd> and <kbd>Ctrl-Arrows</kbd> | flip the value of `cd-key` style |
| accept the whole autosuggestion with <kbd>Right</kbd> key | flip the value of `forward-char` style |
| delete one character with <kbd>Backspace</kbd> and <kbd>Ctrl-H</kbd> | delete the binding for `backward-kill-word` |
| move cursor to the end when <kbd>Up</kbd>, <kbd>Down</kbd>, <kbd>Ctrl-Up</kbd> or <kbd>Ctrl-Down</kbd> fetch commands from history | flip the value of `leave-cursor` |

You can rebind any key with `bindkey` builtin. See [reference](
  http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Builtins).

### Customizing appearance

Different parts of Zsh For Humans UI are rendered by different projects.

![Zsh For Humans](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/prompt-highlight.png)

Everything within the highlighted areas on the screenshot is *prompt*. It is produced by
[Powerlevel10k](https://github.com/romkatv/powerlevel10k). See
[Customizing prompt](#customizing-prompt).

The listing of files produced by `ls` command is colored by `ls` itself. Different commands have
different ways of customizing their output, and even different version of `ls` have different flags
and environment variables related to colors. Zsh For Humans enables colored output from common
commands (such as `ls`). For further customization consult documentation of the respective command.

`echo hello` is the current command being typed. Syntax highlighting for it is provided by
[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting). See its homepage
for documentation on how to customize it.

After `echo hello` you can see `world` in grey. This is not a part of the command, so pressing
<kbd>Enter</kbd> will print only `hello` but not `world`. The latter is an autosuggestion provided
by [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) that you can
[accept](#accepting-autosuggestions) in part or in full. It comes from command history and it's a
great productivity booster. See [zsh-autosuggestions](
  https://github.com/zsh-users/zsh-autosuggestions) homepage for more information.

Last but not least, your terminal has a say about the appearance of *everything* that runs within
it. The base colors, numbered from 0 to 15, can look very different in different terminals and even
in the same terminal with different settings. Most modern terminals support *themes*,
*color palettes* or *color schemes* that allow you to quickly change base colors. If colors in your
terminal look unpleasant, try a different theme. Note that colors with codes above 15, as well as
colors specified as RGB triplets, don't get affected by terminal themes. They look the same
everywhere.

### Using external commands or files

When using external commands or files in `~/.zshrc`, prefer conditional evaluation. If your
`~/.zshrc` uses only things that exist, it'll be easier to [replicate shell on another machine](
  #replicating-shell-on-another-machine).

Here are a few examples to demonstrate this:

```zsh
# Load pyenv if ~/.pyenv exists.
if [[ -e ~/.pyenv ]]; then
  export PYENV_ROOT=~/.pyenv
  path=($PYENV_ROOT/bin $path)
  eval "$(pyenv init -)"
fi

# Enable direnv hooks if direnv is installed.
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi
```

When sourcing a file, prefer `z4h source` over plain `source`. The former will check that the file
exists before attempting to source it and will `zcompile` it for faster loading.

```zsh
# Enable iTerm2 shell integration if the corresponding file exists.
z4h source ~/.iterm2_shell_integration.zsh
```

### Additional Zsh startup files

When you start Zsh, it automatically sources `~/.zshrc` -- your personal config that builds on
Zsh For Humans. Zsh supports several additional startup files with complex rules governing when each
file is sourced. The additional startup files are `~/.zshenv`, `~/.zprofile`, `~/.zlogin` and
`~/.zlogout`. **It is not recommended to create these files.**

## Updating

By default you'll be prompted to update once a month when starting Zsh. You can customize frequency
or disable auto-update prompt altogether. You can manually update with `z4h update`. There are three
update channels. From the most stable to the most fresh: `stable` (default), `testing` and `dev`.

There is no update mechanism for `~/.zshrc` itself.

## Configuration files

Zsh For Humans uses the following configuration files:

- `~/.zshrc`. Main Zsh configuration file. Zsh For Humans gets bootstrapped from it. See
  [Replicating shell on another machine](#replicating shell on another machine).
- `~/.p10k*.zsh`. [Powerlevel10k](https://github.com/romkatv/powerlevel10k) (prompt) configuration
  files. There can be more than one such file (hence `*`) to account for terminals with limited
  capabilities. Most users will ever only see `~/.p10k.zsh`. Powerlevel10k configuration wizard
  starts automatically upon Zsh startup if there is no suitable configuration file. You can also run
  it manually with `p10k configure`. Either way it will write new configuration to `~/.p10k*.zsh`.

It's a very good idea to backup `~/.zshrc` and/or store it in a Git repository. If you expend
non-trivial amount of effort customizing prompt, give the same treatment to `~/.p10k*.zsh`.

Zsh For Humans stores transient state in the directory designated by `$Z4H`. Do not manually modify
or delete files from this directory. It's OK, however, to delete *the whole* directory. It'll be
recreated. You don't have to back it up and you shouldn't share it between different machines or
different users on the same machine.

## Replicating Zsh For Humans on another machine or restoring it from a backup

If you have `~/.zshrc` from your Zsh For Humans setup, you can recreate the environment on another
machine or restore it on the original machine.

1. *Optional*: Install [MesloLGS NF](
   https://github.com/romkatv/powerlevel10k/blob/master/README.md#meslo-nerd-font-patched-for-powerlevel10k)
   terminal font.
2. Remove or backup the existing Zsh config files: `~/.zshenv`, `~/.zshrc`, `~/.zprofile`,
   `~/.zlogin` and `~/.zlogout`.
3. Place `~/.zshrc` from your Zsh For Humans setup in the home directory.
4. If you have `~/.p10k*.zsh` files, place them in the home directory.
4. Run the following command:
```zsh
ZDOTDIR="$HOME" exec sh -c '. ~/.zshrc'
```

This requires requires `curl` or `wget`. It does not require `git`, `zsh`, `sudo` or anything else.

*Note*: If you have Zsh For Humans installed on local host and want to have the same environment
when you SSH to remote host, use `z4h ssh` command instead of the regular `ssh`. See [SSH](#SSH).
