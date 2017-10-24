# Prerequisites

- `Python 3`

-  Python packages `neovim` and `jedi` have been `pip` installed

# Where to put `neovim` config files?

There is some confusion or mess.

System-wide, there is `/etc/xdg/nvim/` and `/usr/local/share/nvim/`.

User local, on Mac there is `~/.local/share/nvim/` and `~/.config/nvim/`; on Linux there is `~/.local/share/nvim/`.


# Set up `neovim` on Mac

1. Download and unpack the Mac binary of `neovim`, put it somewhere (e.g. in `/Applications`), create a link or add to PATH so that the command can be found.

```
rm -f /usr/bin/vim
ln -s /Applications/nvim-osx64/bin/nvim /usr/bin/vim
```

If you do not have permission to change `/usr/bin`,
then create the links in `/usr/local/bin`, and put

```
PATH=/usr/local/bin:$PATH
```
in `~/.bashrc`.


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

3. Launch `nvim` (or your custom or linked name). There should be no welcome intro screen (which is turned off in our config) or any warning.
   In 'insert` mode, type `:CheckHealth`; verify things are all right.

4. Edit a short Python or other text file to confirm auto-completion is working. As you type, there should be suggestion windows popping up
   from time to time; each suggestion row should contain `[...]` in the middle or at the end.


# Set up `neovim` on Linux

Follow a similar procedure, but use system location `/etc/xdg/nvim/`
(or user location `~/.local/share/nvim/`). Do not create or use `~/.config/nvim/`.

