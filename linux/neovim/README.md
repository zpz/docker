# Prerequisites

- `Python 3` (this is required by a couple `neovim` extensions that we want to install)

-  Python packages `neovim` and `jedi` have been `pip` (or `pip3`) installed


# Installation

1. Run script [install.sh](./install.sh)

2. Launch `nvim`. There should be no welcome intro screen (which is turned off in our config) or any warning.
   In 'command' mode, type `:CheckHealth`; verify things are all right.

3. Edit a short Python or other text file to confirm auto-completion is working. As you type, there should be suggestion windows popping up
   from time to time; each suggestion row should contain `[...]` in the middle or at the end.
