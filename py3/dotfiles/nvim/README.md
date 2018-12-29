# Prerequisites

- `Python 3` (this is required by a couple `neovim` extensions that we want to install)

-  Python packages `neovim` and `jedi` have been `pip` (or `pip3`) installed

# Where to put `neovim` config files?

There is some confusion or mess.

System-wide, there is `/etc/xdg/nvim/` and `/usr/local/share/nvim/`.

User local, on Mac there is `~/.local/share/nvim/` and `~/.config/nvim/`; on Linux there is `~/.local/share/nvim/`.


# Set up `neovim` on Mac

1. Install by `homebrew`:

```
brew install neovim
```

2. Do the following things in a terminal:

```
cd /tmp
git clone https://github.com/zpz/docker.git
cd docker/dotfiles/nvim

mkdir -p ~/.local/share/nvim
cp *.vim ~/.local/share/nvim
cp -r colors ~/.local/share/nvim

mkdir -p ~/.config/nvim
ln -s ~/.local/share/nvim/init.vim ~/.config/nvim/init.vim

cd ~/.local/share/nvim
mkdir -p bundle
cd bundle
git clone https://github.com/VundleVim/Vundle.vim.git

nvim +PluginInstall +qall
nvim +UpdateRemotePlugins +qall

```

3. Launch `nvim`. There should be no welcome intro screen (which is turned off in our config) or any warning.
   In 'command' mode, type `:CheckHealth`; verify things are all right.

4. Edit a short Python or other text file to confirm auto-completion is working. As you type, there should be suggestion windows popping up
   from time to time; each suggestion row should contain `[...]` in the middle or at the end.


# Set up `neovim` on Linux

Follow a similar procedure, but use system location `/etc/xdg/nvim/`
(or user location `~/.local/share/nvim/`). Do not create or use `~/.config/nvim/`.

