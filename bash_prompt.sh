# https://habr.com/ru/company/mailru/blog/145008/

PS1_GIT_BIN=$(which git 2>/dev/null)

if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_is_on=true
	color_red="\[$(/usr/bin/tput setaf 1)\]"
	color_green="\[$(/usr/bin/tput setaf 2)\]"
	color_yellow="\[$(/usr/bin/tput setaf 3)\]"
	color_magenta="\[$(/usr/bin/tput setaf 5)\]"
	color_blue="\[$(/usr/bin/tput setaf 6)\]"
	color_white="\[$(/usr/bin/tput setaf 7)\]"
	color_gray="\[$(/usr/bin/tput setaf 8)\]"
	color_off="\[$(/usr/bin/tput sgr0)\]"
	color_error="$(/usr/bin/tput setab 1)$(/usr/bin/tput setaf 7)"
	color_error_off="$(/usr/bin/tput sgr0)"
	case `id -u` in
		0) color_user=$color_red
           char_user='#'
        ;;
		*) color_user=$color_blue
           char_user='$'
        ;;
	esac
fi

function prompt_command {
	local PS1_GIT=
	local PS1_VENV=
	local GIT_BRANCH=
	local GIT_DIRTY=
	local PWDNAME=$PWD

	# beautify working directory name
	if [[ "${HOME}" == "${PWD}" ]]; then
		PWDNAME="~"
	elif [[ "${HOME}" == "${PWD:0:${#HOME}}" ]]; then
		PWDNAME="~${PWD:${#HOME}}"
	fi

	# parse git status and get git variables
	if [[ ! -z $PS1_GIT_BIN ]]; then
		# check we are in git repo
		local CUR_DIR=$PWD
		while [[ ! -d "${CUR_DIR}/.git" ]] && [[ ! "${CUR_DIR}" == "/" ]] && [[ ! "${CUR_DIR}" == "~" ]] && [[ ! "${CUR_DIR}" == "" ]]; do CUR_DIR=${CUR_DIR%/*}; done
		if [[ -d "${CUR_DIR}/.git" ]]; then
			# 'git repo for dotfiles' fix: show git status only in home dir and other git repos
			if [[ "${CUR_DIR}" != "${HOME}" ]] || [[ "${PWD}" == "${HOME}" ]]; then
				# get git branch
				GIT_BRANCH=$($PS1_GIT_BIN symbolic-ref HEAD 2>/dev/null)
				if [[ ! -z $GIT_BRANCH ]]; then
					GIT_BRANCH=${GIT_BRANCH#refs/heads/}

					# get git status
					local GIT_STATUS=$($PS1_GIT_BIN status --porcelain 2>/dev/null)
					[[ -n $GIT_STATUS ]] && GIT_DIRTY=1
				fi
			fi
		fi
	fi

	# build b/w prompt for git and virtual env
	[[ ! -z $GIT_BRANCH ]] && PS1_GIT=" (git: ${GIT_BRANCH})"
	[[ ! -z $VIRTUAL_ENV ]] && PS1_VENV=" (venv: ${VIRTUAL_ENV#$WORKON_HOME})"

	# calculate prompt length
	local PS1_length=$((${#USER}+${#HOSTNAME}+${#PWDNAME}+${#PS1_GIT}+${#PS1_VENV}+3))
	local FILL=

	# if length is greater, than terminal width
	if [[ $PS1_length -gt $COLUMNS ]]; then
		# strip working directory name
		PWDNAME="...${PWDNAME:$(($PS1_length-$COLUMNS+3))}"
	else
		# else calculate fillsize
		local fillsize=$(($COLUMNS-$PS1_length))
		FILL=$color_gray
		while [[ $fillsize -gt 0 ]]; do FILL="${FILL}─"; fillsize=$(($fillsize-1)); done
		FILL="${FILL}${color_off}"
	fi

	if $color_is_on; then
		# build git status for prompt
		if [[ ! -z $GIT_BRANCH ]]; then
			if [[ -z $GIT_DIRTY ]]; then
				PS1_GIT=" ${color_green}${GIT_BRANCH}${color_off}"
			else
				PS1_GIT=" ${color_red}${GIT_BRANCH}${color_off}"
			fi
		fi

		# build python venv status for prompt
		[[ ! -z $VIRTUAL_ENV ]] && PS1_VENV=" (venv: ${color_blue}${VIRTUAL_ENV#$WORKON_HOME}${color_off})"
	fi

	PS1="${color_magenta}\t${color_off} ${color_user}${USER}${color_off}@${color_white}${HOSTNAME}: ${PWDNAME}${color_off}${PS1_GIT}${PS1_VENV} ${char_user} "

	# get cursor position and add new line if we're not in first column
	echo -en "\033[6n" && read -sdR CURPOS
	[[ ${CURPOS##*;} -gt 1 ]] && echo "${color_error}↵${color_error_off}"

	# set title
	echo -ne "\033]0;${USER}@${HOSTNAME}:${PWDNAME}"; echo -ne "\007"
}

# set prompt command (title update and color prompt)
PROMPT_COMMAND=prompt_command
# set new b/w prompt (will be overwritten in 'prompt_command' later for color prompt)
PS1='\u@\h:\w\$ '
