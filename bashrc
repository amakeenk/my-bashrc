# .bashrc
if [ -r /etc/bashrc ]; then
	. /etc/bashrc
fi

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
# cp with progress showing
# -----------------------------------------------------
cp-p() {
    set -e
    strace -q -ewrite cp -- "${1}" "${2}" 2>&1 | awk '{
        count += $NF
            if (count % 10 == 0) {
                percent = count / total_size * 100
                printf "%3d%% [", percent
                for (i=0;i<=percent;i++)
                    printf "="
                printf ">"
                for (i=percent;i<100;i++)
                    printf " "
                printf "]\r"
            }
        }
        END { print "" }' total_size=$(stat -c '%s' "${1}") count=0
}

export -f cp-p
# -----------------------------------------------------