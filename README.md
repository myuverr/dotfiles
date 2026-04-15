# dotfiles

Personal dotfiles managed with a [bare git repository](https://www.atlassian.com/git/tutorials/dotfiles).

## Setup

```bash
# Clone
git clone --bare <repo-url> $HOME/.dotfiles

# Define alias
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Checkout (backup conflicting files first if needed)
dot checkout

# Hide untracked files
dot config --local status.showUntrackedFiles no

# Pull submodules
dot submodule update --init --depth 1
```

## Usage

```bash
# Update upstream themes
dot submodule update --remote --merge --depth 1
```

## License

Licensed under the [ISC License](LICENSE). Files with existing license headers retain their original license.
