# Zsh for Humans

Configuration for [Z shell](https://en.wikipedia.org/wiki/Z_shell) that aims to work really well out
of the box. It combines the best Zsh plugins into a coherent whole that feels like a finished
product rather than a DIY starter kit.

If you want a great shell that just works, this project is for you.

- [Installation](#installation)
- [Try it in Docker](#try-it-in-docker)
- [Usage](#usage)
- [Customization](#customization)
- [Updating](#updating)

## Installation

```shell
if command -v curl >/dev/null 2>&1; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v2/install)"
else
  sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh4humans/v2/install)"
fi
```

## Try it in Docker

Try Zsh for Humans in Docker. You can safely make any changes to the file system while trying out
the theme. Once you exit Zsh, the image is deleted.

```zsh
docker run -e TERM -e COLORTERM -w /root -it --rm alpine sh -uec '
  sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh4humans/v2/install)"'
```

Use <kbd>Tab</kbd> to complete commands, <kbd>Ctrl-R</kbd> to search history
<kbd>Alt-{Left,Right,Up,Down}</kbd> to change current directory.

*Tip*: Install [powerlevel10k font](
  https://github.com/romkatv/powerlevel10k/blob/master/README.md#meslo-nerd-font-patched-for-powerlevel10k)
on your local machine before running the Docker command to get access to all prompt styles. Run
`p10k configure` while in Docker to try a different prompt style.

## Usage

If you've used Zsh, Bash or another shell descendant from Bourne shell, Zsh for Humans should feel
familiar.

### Key Bindings

If you aren't sure what `emacs`, `viins` and `vicmd` mean, you are likely using `emacs` keymap.
Ignore the other two columns.

*TODO: add a table.*

It's easy to swap bindings for <kbd>Alt-Arrows</kbd> and <kbd>Ctrl-Arrows</kbd>. Search for `cd-key`
in `~/.zshrc`.

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

*TODO*

### Changing Current Directory

<kbd>Alt-Arrows</kbd> allows you to quickly change current directory without losing command line
buffer. <kbd>Alt-Left</kbd> goes to the previous directory, <kbd>Alt-Right</kbd> goes to the next.
Think of Back and Forward buttons in a Web browser. <kbd>Alt-Up</kbd> goes to the parent directory.
<kbd>Alt-Down</kbd> opens a [fuzzy search](#fuzzy-search) dialog for selecting a subdirectory.

Another way to change directory is to type `cd ~/` and hit <kbd>Alt+I</kbd>. It works with any
directory prefix. <kbd>Alt+I</kbd> completes files with [fuzzy search](#fuzzy-search) but it's
smart enough to recognize that the argument to `cd` must be a directory, so it'll only show those.

## Customization

Edit `~/.zshrc`.

## Updating

You'll be prompted to update once a month when starting Zsh. You can also manually update with
`z4h update`. There is no update mechanism for `.zshrc` itself.
