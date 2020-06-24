# .bashrc
# -----------------------------------------------------
# -----------------------------------------------------
# Autoadded ssh key
# -----------------------------------------------------
env=~/.ssh/agent.env

_agent_is_running() {
    if [ "$SSH_AUTH_SOCK" ]; then
        ssh-add -l >/dev/null 2>&1 || [ $? -eq 1 ]
    else
        false
    fi
}

_agent_has_keys() {
    ssh-add -l >/dev/null 2>&1
}

_agent_load_env() {
    . "$env" >/dev/null
}

_agent_start() {
    (umask 077; ssh-agent >"$env")
    . "$env" >/dev/null
}

if ! _agent_is_running; then
    _agent_load_env
fi

if ! _agent_is_running; then
    _agent_start
    ssh-add
elif ! _agent_has_keys; then
    ssh-add
fi

unset env
# -----------------------------------------------------
# -----------------------------------------------------
# Different options
# -----------------------------------------------------
shopt -s histappend
PROMPT_COMMAND='history -a'
export HISTCONTROL="ignoredups"
shopt -s cdspell
shopt -s cmdhist
# -----------------------------------------------------
[ -r /etc/bashrc ] && . /etc/bashrc
[ -r /etc/bashrc.d/bash_prompt.sh ] && . /etc/bashrc.d/bash_prompt.sh
# -----------------------------------------------------
# Aliases
# -----------------------------------------------------
alias ll='ls -l'
alias u='sudo apt-get update'
alias ud='u && sudo apt-get -V dist-upgrade'
alias udk='ud && sudo update-kernel'
alias udkc='sudo apt-repo clean && udk'
alias ara='sudo apt-repo add'
alias art='sudo apt-repo test'
alias agip='u && sudo apt-get -V install'
alias agrp='sudo apt-get -V remove'
alias agar='sudo apt-get -V autoremove'
alias acs='apt-cache search'
alias acwd='apt-cache whatdepends'
alias sstat='systemctl status'
alias sstart='sudo systemctl start'
alias sstop='sudo systemctl stop'
alias ssres='sudo systemctl restart'
# -----------------------------------------------------
