let g:python3_host_prog = '/usr/local/bin/python3'

if system('uname -s') == "Darwin\n"
    set rpt^=~/.local/share/nvim
else
    set rpt^='/etc/xdg/nvim'
endif
source &rpt/general.vim
source &rpt/autocmd.vim
source &rpt/keys.vim
source &rpt/plugins.vim

