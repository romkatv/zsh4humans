# Zsh for Humans

Single-file configuration for Zsh with sane defaults.

## Installation

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

## Features

Just Works. Type `z4h help` for help.

## Customization

Edit `~/.zshrc`.

## Updating

You'll be prompted to update dependencies (fzf, zsh-autosuggestions, etc.) once a month when
starting Zsh. You can also force update with `z4h update`. There is no update mechanism for `.zshrc`
itself.
