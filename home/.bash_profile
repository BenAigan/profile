# Bash Profile
echo ".bash_profile loading"

# Stop zsh nagging 
export BASH_SILENCE_DEPRECATION_WARNING=1

# Settings
export EDITOR=vim

# Path 
PATH=$PATH:~/bin

alias l='ls -lArth'
alias rm='rm -vi'
alias mv='mv -vi'
alias cp='cp -vip'
alias h='history 10'
alias hh='history'
alias t='tail -F'
alias ip='curl http://ipecho.net/plain; echo'
alias ssh='ssh -o ServerAliveInterval=60 -o StrictHostKeyChecking=no'
alias scp='scp -o LogLevel=quiet -o ServerAliveInterval=15 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

export PS1='\[`[ $? = 0 ] && X=2 || X=1; tput setaf $X`\]\u@\h:\[`tput sgr0`\]$PWD \D{%F %T}\n\$ '

# alias lightsail='ssh -i ./LightsailDefaultPrivateKey-us-east-1.pem admin@34.232.209.255'

if [[ -e ~/tmux.sh ]]; then
    source ~/tmux.sh
fi

IGNOREEOF=3   # Shell only exits after the 3rd consecutive Ctrl-d
