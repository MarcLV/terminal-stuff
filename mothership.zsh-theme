# Color shortcuts
CYAN=%{$fg_no_bold[cyan]%}
YELLOW=%{$fg_bold[yellow]%}
WHITE=%{$fg_no_bold[white]%}
GREEN=%{$fg_no_bold[green]%}
RED=%{$fg_no_bold[red]%}
BLUE=%{$fg_no_bold[blue]%}
RESET=$reset_color

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

	echo "$(_timeSinceCommit) %{$CYAN%}[%{$WHITE%}$(_whatChanged) files%{$CYAN%}] [$STATUS$(parse_git_dirty)%{$CYAN%}] [%{$YELLOW%}$(_currentBranch)%{$CYAN%}]%{$RESET%}"
}

_whatChanged() {
  command git whatchanged -1 --format=oneline | wc -l
}

PROMPT='
%{$CYAN%}┌─[$(_clock)%{$CYAN%}] ${_current_dir} ${_return_status}
%{$CYAN%}└$(_userHost)%{$CYAN%}╼ '

RPROMPT='$(_viStatus)%{$(echotc UP 1)%} $(git_prompt_info) %{$RESET%}%{$(echotc DO 1)%}'

local _current_dir="%{$YELLOW%}%2~%{$RESET%} "
local _return_status="%{$fg_bold[red]%}%(?..…err!)%{$RESET%}"

_clock() {
	echo $'%F{white}%*%f'
}

_currentBranch() {
  echo "%18>…>$(current_branch)%>>"
}


_userHost() {
  # Change user color depending on permissions
  if [[ $USER == "root" ]]; then
    rootColor=$RED
  else
    rootColor=$CYAN
  fi

  # Show machine name is ssh connection
  if [[ -n $SSH_CONNECTION ]]; then
    me="%n@%m"
  elif [[ $LOGNAME != $USER ]]; then
    me="%n"
  fi
  if [[ -n $me ]]; then
    echo "%{$fg_bold[$rootColor]%}$me$RESET"
  fi
}

_viStatus() {
  if {echo $fpath | grep -q "plugins/vi-mode"}; then
    echo "$(vi_mode_prompt_info)"
  fi
}


_timeSinceCommit() {
  if last_commit=$(git log --pretty=format:'%at' -1 2> /dev/null); then
    now=$(date +%s)
    seconds_since_last_commit=$((now-last_commit))

    # Totals
    minutes=$((seconds_since_last_commit / 60))
    hours=$((seconds_since_last_commit / 3600))
    days=$((seconds_since_last_commit / 86400))
    months=$((seconds_since_last_commit / 2629800))
    years=$((seconds_since_last_commit / 31557600))

    # Sub-hours and sub-minutes    
    sub_minutes=$((minutes % 60))
    sub_hours=$((hours % 24))
    sub_days=$((days % 86400))
    sub_months=$((months % 2629800))
    sub_years=$((years % 31557600))

    if [ $months -ge 12 ]; then # Years
      extra_months=$((months - 12))
      commit_age="${sub_years}y${extra_months}m"
    elif [ $days -gt 30 ]; then # Months
      extra_days=$((days - 30))
      commit_age="${sub_months}m${extra_days}d"
    elif [ $hours -gt 24 ]; then # Days
      extra_hours=$(((hours - 24) / 24))
      commit_age="${sub_days}d${extra_hours}h"
    elif [ $minutes -gt 60 ]; then # Hours
      extra_minutes=$(((minutes - 60) / 60))
      commit_age="${sub_hours}h${extra_minutes}m"
    elif [ $seconds_since_last_commit -gt 60 ]; then # Minutes
      commit_age="${minutes}m"
    else # Seconds
      commit_age="${seconds_since_last_commit}s"
    fi

    color=$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL
    echo "%{$CYAN%}[$color$commit_age%{$CYAN%}]%{$RESET%}"
  fi
}

MODE_INDICATOR="%{$YELLOW%}❮%{$RESET%}%{$YELLOW%}❮❮%{$RESET%}"

SH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY="%{$RED%}dirty%{$RESET%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$GREEN%}clean%{$RESET%}"
# remove the text in these ones after you've learned their meaning to save space
ZSH_THEME_GIT_PROMPT_NONE="%{$GREEN%}★ all good:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$GREEN%}↑ ahead:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$GREEN%}↓ behind:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$RED%}→ staged:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$RED%}← unstaged:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$RED%}↙ unmerged:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$RED%}↖ renamed:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$RED%}↗ modified:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$RED%}↘ untracked:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_ADDED="%{$GREEN%}+ added:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_DELETED="%{$RED%}- deleted:%{$RESET%}"

# Colors vary depending on time lapsed.
ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%{$GREEN%}"
ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM="%{$YELLOW%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%{$RED%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%{$WHITE%}"

# LS colors, made with https://geoff.greer.fm/lscolors/
export LS_COLORS='di=1;30;46:ln=1;35:so=1;32:pi=1;33:ex=1;36:bd=34;46:cd=36:su=1;0;41:sg=1;30;41:tw=30;46:ow=30;46'
export GREP_COLOR='1;33'
