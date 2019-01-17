git_prompt_info() {
	ref=$(git symbolic-ref HEAD 2> /dev/null) || return
	echo "$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_PREFIX$(current_branch)$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

get_pwd() {
	print -D $PWD
}

put_spacing() {
	local git=$(git_prompt_info)
	if [ ${#git} != 0 ]; then
		((git=${#git} - 16))
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

PROMPT='$fg[cyan]└⇒%{$reset_color%} '
ZSH_THEME_GIT_PROMPT_PREFIX="["
ZSH_THEME_GIT_PROMPT_SUFFIX="]$reset_color"
ZSH_THEME_GIT_PROMPT_DIRTY="$fg[red]"
ZSH_THEME_GIT_PROMPT_CLEAN="$fg[green]"
