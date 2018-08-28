umask 033

# set PATH so it includes user's private bin if it exists
if false && [ -d "$HOME/bin" ] ; then
    case ":$PATH:" in
        *":$HOME/bin:"*) ;;
        *) PATH="$HOME/bin:$PATH" ;;
    esac
fi

# set PATH so it includes user's private bin if it exists
if false && [ -d "$HOME/.local/bin" ] ; then
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) PATH="$HOME/.local/bin:$PATH" ;;
    esac
fi
export PATH;

[ ! -e "$HOME/.ssh" ] && mkdir "$HOME/.ssh"

SSH_ENV="$HOME/.ssh/environment"
#[ ! -f "$SSH_ENV" ] && touch "$SSH_ENV"

start_agent() {
    #echo "Initialising new SSH agent..."
    ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    #echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    ssh-add;
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    # Check for a launchd-spawned ssh-agent
    if ps -ef | awk '/ssh-agent$/ {print ($3 == 1)}' | grep 1 >/dev/null; then
        # Check if our key has already been added
        ssh-add -l | cut -d ' ' -f 3 | grep "^$HOME/.ssh/id_rsa$" >/dev/null \
                || ssh-add
    else
        start_agent
    fi
fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi
