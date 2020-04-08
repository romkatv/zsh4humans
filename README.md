# Zsh for Humans

Configuration for [Z shell](https://en.wikipedia.org/wiki/Z_shell) that works really well out of
the box. It combines the best Zsh plugins into a coherent whole that feels like a finished product
rather than a DYI starter kit.

If you want a great shell that just works, this project is for you.

- [Getting Started](#getting-started)
- [Installation](#installation)
- [Try it in Docker](#try-it-in-docker)
- [Usage](#usage)
- [Initialization Sequence](#initialization-sequence)
- [Customization](#customization)
- [Uninstallation](#uninstallation)

## Getting Started

1. [Install](#installation) Zsh for Humans.
2. Try out the [features](#usage) of your new shell.
3. Read through `~/.zshrc` and [get comfortable](#initialization-sequence).
4. Migrate environment variables, aliases and other [customizations](#customization) from your old
   shell config.

## Installation

*[Optional]* **Back up the existing Zsh startup files**

```zsh
mkdir ~/zsh-backup
mv ~/.zshenv ~/.zprofile ~/.zshrc ~/.zlogin ~/.zlogout ~/zsh-backup 2>/dev/null
```

**Download [.zshrc](https://raw.githubusercontent.com/romkatv/zsh4humans/master/.zshrc)**

With `curl`:

```zsh
curl -fsSLo ~/.zshrc https://raw.githubusercontent.com/romkatv/zsh4humans/master/.zshrc
```

Or with `wget`:

```zsh
wget -O ~/.zshrc https://raw.githubusercontent.com/romkatv/zsh4humans/master/.zshrc
```

**(Re)start Zsh**

```zsh
ZDOTDIR=~ exec zsh
```

Don't have Zsh installed? Execute `~/.zshrc` with `sh` to install Zsh to `~/.zsh-bin`.

```zsh
ZDOTDIR=~ exec ~/.zshrc
```

## Try it in Docker

Try Zsh for Humans in Docker. You can safely make any changes to the file system while trying out
the theme. Once you exit Zsh, the image is deleted.

```zsh
docker run -e TERM -e COLORTERM -w /root -it --rm centos sh -uec '
  curl -fsSLo ~/.zshrc https://raw.githubusercontent.com/romkatv/zsh4humans/master/.zshrc
  exec sh ~/.zshrc'
```

Try directory navigation with *Alt-Arrows*, completion with *Tab* and command history with *Ctrl-R*.

*Tip*: Install [powerlevel10k font](
  https://github.com/romkatv/powerlevel10k/blob/master/README.md#meslo-nerd-font-patched-for-powerlevel10k)
before running the Docker command to get access to all prompt styles. Run `p10k configure` while in
Docker to try a different prompt style.

## Usage

If you've used Zsh, Bash or another shell descendant from Bourne shell, Zsh for Humans should feel
familiar.

### Key Bindings

*TODO*: add a table.

It's easy to swap bindings for <kbd>Alt-Arrows</kbd> and <kbd>Ctrl-Arrows</kbd>. Search for `cd-key`
in `~/.zshrc`.

See [customization](#changing-key-bindings) for how to rebind any key.

### Fuzzy Search

Several UI elements use [fzf](https://github.com/junegunn/fzf) to quickly select an item from a
potentially large list of candidates. You can type multiple search terms delimited by spaces. For
example:

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

For complete documentation (or to award a star!) go to [fzf](https://github.com/junegunn/fzf) on
GitHub.

### Completions

TODO

### Changing Current Directory

<kbd>Alt-Arrows</kbd> allows you to quickly change current directory without losing command line
buffer. <kbd>Alt-Left</kbd> goes to the previous directory, <kbd>Alt-Right</kbd> goes to the next.
Think of Back and Forward buttons in a Web browser. <kbd>Alt-Up</kbd> goes to the parent directory.
<kbd>Alt-Down</kbd> opens a [fuzzy search](#fuzzy-search) dialog for selecting a subdirectory.

Another way to change directory is to type `cd ~/` and hit <kbd>Alt+F</kbd>. It works with any
directory prefix. <kbd>Alt+F</kbd> completes **F**iles with [fuzzy search](#fuzzy-search) but it's
smart enough to recognize that the argument to `cd` must be a directory, so it'll only show those.

*Tip*: It's easy to swap bindings for <kbd>Alt-Arrows</kbd> and <kbd>Ctrl-Arrows</kbd>. Search for
`cd-key` in `~/.zshrc`.

-------------

TODO: remove this.

Arrow keys move cursor one character at a time.

<kbd>Home</kbd> and <kbd>End</kbd> move cursor to the beginning and the end of line.

<kbd>Delete</kbd> and <kbd>Backspace</kbd> delete one character at a time.

<kbd>Ctrl</kbd> boosts cursor movement and content deletion. It makes keys, <kbd>Delete</kbd> and
<kbd>Backspace</kbd> operate on words, and supercharge <kbd>Home</kbd> and <kbd>End</kbd> so that
they jump to the ends of the multiline buffer.



*Tip*: It's easy to swap bindings for <kbd>Alt-Arrows</kbd> and <kbd>Ctrl-Arrows</kbd>. Search for
`cd-key` in `~/.zshrc`.
  - 

- Ctrl-

Basic keys do what they normally do. Arrow keys move cursor, *Tab* completes what you
type, *Ctrl-R* allows you to search through history, etc.


 one character at a time while
*Ctrl-Arrows* jump by words. *Alt-Arrows* change current directory

*Tab* completes what you type, *Ctrl-R* allows you
to search through history, etc. 

## Customization

2. By default *Ctrl-Arrows* move cursor by words while *Alt-Arrows* change current directory. You
   can swap these by changing `alt` to `ctrl` in `~/.zshrc`. Search for it, it's fairly
   straightforward.

## Features

Zsh for Humans stands on the shoulders of giants. It combines the fruits of greatest software in a coherent
package with high attention to detail and

At its core is Z shell -- the most powerful shell
a powerful shell with
programmable completions  


1. *Optional*: Install [powerlevel10k font](
  https://github.com/romkatv/powerlevel10k/blob/master/README.md#meslo-nerd-font-patched-for-powerlevel10k).
2. Download [.zshrc](https://raw.githubusercontent.com/romkatv/zsh4humans/master/.zshrc) to your
   home directory and `source` it.
```zsh
curl -fsSLo ~/.zshrc https://raw.githubusercontent.com/romkatv/zsh4humans/master/.zshrc
source ~/.zshrc
```
or
```zsh
wget -O ~/.zshrc https://raw.githubusercontent.com/romkatv/zsh4humans/master/.zshrc
source ~/.zshrc
```

Just Works. Type `z4h help` for help.

## Customization

Edit `~/.zshrc`.

## Updating

You'll be prompted to update dependencies (fzf, zsh-autosuggestions, etc.) once a month when
starting Zsh. You can also force update with `z4h update`. There is no update mechanism for `.zshrc`
itself.

# Install additional software if it's missing or Z4H_UPDATE is set to 1 (update required).
if [[ ! -x $Z4H/bin/some-tool || $Z4H_UPDATE == 1 ]]; then
  # It's OK for the code installing software to be slow as it doesn't run often.
  # You can use `git`, `curl`, `wget` and even compile stuff here. Just make sure
  # the check guarding the installation code is very fast.
  z4h clone so-fancy/diff-so-fancy &&
    ln -s $Z4H/so-fancy/diff-so-fancy/third_party/build_fatpack/diff-so-fancy $Z4H/bin/
fi

docker run -e TERM -e COLORTERM -it --rm alpine sh -uec '
  wget -O ~/.zshrc https://raw.githubusercontent.com/romkatv/zsh4humans/v1/.zshrc
  . ~/.zshrc'
