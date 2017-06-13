# Where to put `neovim` config files?

There is some confusion or mess.

System-wide, there is `/etc/xdg/nvim/` and `/usr/local/share/nvim/`.

User local, on Mac there is `~/.local/share/nvim/` and `~/.config/nvim/`; on Linux there is `~/.local/share/nvim/`.


# Set up `neovim` on Mac

1. Download and unpack the Mac binary of `neovim`, put it somewhere, create a link or add to PATH so that the command can be found.

1. Create `~/.local/share/nvim/`.

1. Place `init.vim` and other config files that are loaded by `init.vim` as well as the subdirectory `colors` in `~/.local/share/nvim/`.

1. Make sure the directories that appear in `init.vim` and `plugins.vim` point to `~/.local/share/nvim`.

1. Create `~/.local/share/nvim/bundle`. Git clone the plugin `Vundle.vim` in this folder.

1. Create `~/.config/nvim/`. In there, create a symlink `init.vim` that points to `~/.local/share/nvim/init.vim` (or create a one-liner that sources the target file).

1. Launch `nvim` (or your custom or linked name). There should be no welcome intro screen (which is turned off in our config) or any warning.

1. Launch `nvim`, run command `:PluginInstall`, followed by `:UpdateRemotePlugins`. Then type `:CheckHealth`; verify things are right.

1. Edit a short Python or other text file to confirm auto-completion is working. As you type, there should be suggestion windows popping up
   from time to time; each suggestion row should contain `[...]` in the middle or at the end.


# Set up `neovim` on Linux

Follow a similar procedure, but use system location `/etc/xdg/nvim/` or user location `~/.local/share/nvim/` (no `~/.config/nvim/`).

