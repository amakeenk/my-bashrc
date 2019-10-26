# .bashrc
# -----------------------------------------------------
if [ -r /etc/bashrc ]; then
	. /etc/bashrc
fi
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
# -----------------------------------------------------
# Aliases
# -----------------------------------------------------
alias ll='ls -l'
# -----------------------------------------------------

