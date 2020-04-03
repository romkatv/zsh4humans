# Zsh for Humans

Single-file configuration for Zsh >= 5.3 with sane defaults.

## Installation

1. Install `zsh` version >= 5.3.
2. *Optional*: Install [powerlevel10k font](
  https://github.com/romkatv/powerlevel10k/blob/master/README.md#meslo-nerd-font-patched-for-powerlevel10k).
3. Download [.zshrc](https://raw.githubusercontent.com/romkatv/zsh4humans/master/.zshrc) to your
   home directory.
```zsh
curl -fsSLo ~/.zshrc https://raw.githubusercontent.com/romkatv/zsh4humans/master/.zshrc
```
or
```zsh
wget -O ~/.zshrc https://raw.githubusercontent.com/romkatv/zsh4humans/master/.zshrc
```
4. Start `zsh`.

## Features

Just Works.

## Customization

Edit `~/.zshrc`.

## Updating

You'll be prompted to update dependencies (zsh-syntax-highlighting, fzf, etc.) every two weeks when
starting Zsh. You can also force update with `z4h update`. There is no update mechanism for `.zshrc`
itself.
