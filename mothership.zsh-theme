git_prompt_info() {
	ref=$(git symbolic-ref HEAD 2> /dev/null) || return
	INDEX=$(git status --porcelain 2> /dev/null)

	# is branch ahead?
	if $(echo "$(git log origin/$(git_current_branch)..HEAD 2> /dev/null)" | grep '^commit' &> /dev/null); then
		STATUS="$ZSH_THEME_GIT_PROMPT_AHEAD"
	# is branch behind?
	elif $(echo "$(git log HEAD..origin/$(git_current_branch) 2> /dev/null)" | grep '^commit' &> /dev/null); then
		STATUS="$ZSH_THEME_GIT_PROMPT_BEHIND"
	# is anything staged?
	elif $(echo "$INDEX" | command grep -E -e '^(D[ M]|[MARC][ MD]) ' &> /dev/null); then
		STATUS="$ZSH_THEME_GIT_PROMPT_STAGED"
	# is anything unstaged?
	elif $(echo "$INDEX" | command grep '^.[MTD] ' &> /dev/null); then
		STATUS="$ZSH_THEME_GIT_PROMPT_UNSTAGED"
	# is anything untracked?
	elif $(echo "$INDEX" | grep '^?? ' &> /dev/null); then
		STATUS="$ZSH_THEME_GIT_PROMPT_UNTRACKED"
	# is anything unmerged?
	elif $(echo "$INDEX" | command grep -E -e '^(A[AU]|D[DU]|U[ADU]) ' &> /dev/null); then
		STATUS="$ZSH_THEME_GIT_PROMPT_UNMERGED"
	else
		STATUS="$ZSH_THEME_GIT_PROMPT_NONE"
	fi

	echo "$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_PREFIX$STATUS$(current_branch)$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

get_pwd() {
	print -rP '%2/'
}

put_spacing() {
	local git=$(git_prompt_info)
	if [ ${#git} != 0 ]; then
		((git=${#git} - 21))
	else
		git=0
	fi

	local termwidth
	(( termwidth = ${COLUMNS} - 3 - ${#HOST} - ${#$(get_pwd)}  -  ${git} ))
	local spacing=""

	for i in {1..$termwidth}; do
		spacing="${spacing} "
	done

	echo $spacing
}

precmd() {
	print -rP '$fg[cyan]┌─[$fg[white]$(date +%H$fg[cyan]:$fg[white]%M$fg[cyan]:$fg[white]%S)$fg[cyan]] $fg[yellow]$(get_pwd)$(put_spacing)$(git_prompt_info)'
}

PROMPT='$fg[cyan]└──⇒%{$reset_color%} '
ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX="$reset_color"
ZSH_THEME_GIT_PROMPT_DIRTY="$fg[red]"
ZSH_THEME_GIT_PROMPT_CLEAN="$fg[green]"

ZSH_THEME_GIT_PROMPT_NONE="$fg[green][✓] "
ZSH_THEME_GIT_PROMPT_AHEAD="$fg[cyan][↑] "
ZSH_THEME_GIT_PROMPT_BEHIND="$fg[green][↓] "
ZSH_THEME_GIT_PROMPT_STAGED="$fg[green][→] "
ZSH_THEME_GIT_PROMPT_UNSTAGED="$fg[red][←] "
ZSH_THEME_GIT_PROMPT_UNTRACKED="$fg[white][↝] "
ZSH_THEME_GIT_PROMPT_UNMERGED="$fg[red][✕] "