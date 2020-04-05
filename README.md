# Zsh for Humans

Configuration for [Z shell](https://en.wikipedia.org/wiki/Z_shell) that works really well out of
the box. It combines the best Zsh plugins into a coherent whole that feels like a finished product
rather than a DYI starter kit.

If you want a great shell that just works, this project is for you.

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

## Features

Just Works. Type `z4h help` for help.

## Customization

Edit `~/.zshrc`.

## Updating

You'll be prompted to update dependencies (fzf, zsh-autosuggestions, etc.) once a month when
starting Zsh. You can also force update with `z4h update`. There is no update mechanism for `.zshrc`
itself.
