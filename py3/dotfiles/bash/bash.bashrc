# If not running iteractively, don't do anything
[[ -z "$PS1" ]] && return

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Basic aliases
alias ..='cd ..'
alias back='cd -'
alias ls='ls -FGh --color'
alias ll='ls -lA --color'
alias dir='ls -alg --color'
alias cp='cp -i'
alias rm='rm -i'
alias mv='mv -i'
alias grep='grep --color'

export LS_COLORS=$LS_COLORS:'di=0;36:'

# Customize command prompt. This is a big section---

function git_branch {
    # -- Finds and outputs the current branch name.
    # -- If not in a Git repository, prints nothing
    local path=$(pwd)
    local ff
    local line
    while true; do
        ff="$path/.git/HEAD"
        if [[ -f "$ff" ]]; then
            line=$(cat "$ff")
            if [[ "$line" == *'/'* ]]; then
                echo -e $(expr "$line" : '.*\/\([a-zA-Z0-9_-]*\)')
            else
                echo -e "$line"
            fi
            break
        fi
        if [[ "$path" = "/" ]]; then
            break
         fi
         path=$(dirname "$path")
     done
}

function git_prompt {
    # First, get the branch name...
    local branch=$(git_branch)
    # Empty output? Then we're not in a Git repository, so bypass the rest
    # of the function, producing no output
    if [[ -n "$branch" ]]; then
        local color
        local reset
        if [[ "$branch" == 'master' || "$branch" == release* || "$branch" == RELEASE* ]]; then
            color='\033[1;31m'  # red
        else
            if [[ "$branch" == 'develop' ]]; then
                color='\033[1;33m'  # yellow
            else
                color='\033[1;32m'  # green
            fi
        fi
        reset='\033[0m'
        echo -e " $color[$branch]$reset"
    fi
}

function host_prompt {
    if [[ -n "$IMAGE_NAME" ]]; then
        echo "$IMAGE_NAME"
    else
        echo "$(uname -n)"
    fi
}

B='\[\033['
E='m\]'
S="${B}${E}"
BLUE="${B}1;34${E}"
YELLOW="${B}1;33${E}"
GREEN="${B}1;32${E}"
RED="${B}1;31${E}"
WHITE="${B}1;37${E}"
GREY="${B}1;30${E}"
PINK="${B}35;40${E}"
GREEN="${B}32;40${E}"
ORANGE="${B}33;40${E}"
LIGHTGREEN="${B}0;32${E}"
LIGHTRED="${B}0;31${E}"
LIGHTPURPLE="${B}0;35${E}"
LIGHTYELLOW="${B}0;33${E}"

#PS1='$debian_chroot\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w$(git_prompt)\[\033[00m\]\$ '
#export PS1='[\u: \w] $ '

WINDOWTITLE="\[\e]2;$(if [[ -n "$IMAGE_NAME" ]]; then echo "[ $IMAGE_NAME ]  "; else echo "[ docker ]  "; fi)\W\a\]"
if [ $(whoami) = root ]; then
    PS1="${WINDOWTITLE}\n[${RED}\u${S} in $(host_prompt)] ${ORANGE}\w${S}\$(git_prompt)\n\$ "
else
    PS1="${WINDOWTITLE}\n[\u in $(host_prompt)] ${ORANGE}\w${S}\$(git_prompt)\n\$ "
fi

  # window-title new-line
  # user-name@host-name in current-directory [branch] new-line
  # $

#--- end of command prompt customization ---

