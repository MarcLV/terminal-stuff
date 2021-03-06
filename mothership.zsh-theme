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
    diff=seconds_since_last_commit

    # Totals
    minutesLast=$((seconds_since_last_commit/60))
    hoursLast=$((minutesLast/60))
    daysLast=$((hoursLast/24))
    monthsLast=$((daysLast/30))
    yearsLast=$((monthsLast/12))

    testing=$[15-($monthsLast * $monthsLast)]

    years=$[$diff/$[60*60*24*365]]
    diff=$[$diff%(60*60*24*365)]
    months=$[$diff/(60*60*24*30)]
    diff=$[$diff%(60*60*24*30)]
    days=$[$diff/(60*60*24)]
    diff=$[$diff%(60*60*24)]
    hours=$[$diff/(60*60)]
    diff=$[$diff%(60*60)]
    minutes=$[$diff/60]
    seconds=$[$diff%60]

    # Years
    if [ $monthsLast -ge 12 ]; then
      commit_age="${years}%{$RED%}y%{$RESET%} ${months}%{$RED%}m%{$RESET%}"
    # Months
    elif [ $daysLast -ge 30 ]; then
      commit_age="${months}%{$BLUE%}m%{$RESET%} ${days}%{$BLUE%}d%{$RESET%}"
    # Days
    elif [ $hoursLast -ge 24 ]; then
      commit_age="${days}%{$BLUE%}d%{$RESET%} ${hours}%{$GREEN%}h%{$RESET%}"
    # Hours
    elif [ $minutesLast -ge 60 ]; then 
      commit_age="${hours}%{$GREEN%}h%{$RESET%} ${minutes}%{$GREEN%}m%{$RESET%}"
    # Minutes
    elif [ $diff -ge 60 ]; then 
      commit_age="%{$GREEN%}${minutes}min%{$RESET%}"
    # Seconds
    else
      commit_age="%{$GREEN%}${seconds_since_last_commit}sec%{$RESET%}"
    fi

    color=$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL
    echo "%{$CYAN%}[$color$commit_age%{$CYAN%}]%{$RESET%}"
    testing=$[15-($months * $months)]

    #echo "$commit_age: y:$years m:$months d:$days h:$hours m:$minutes test:$testing"
  fi
}

MODE_INDICATOR="%{$YELLOW%}❮%{$RESET%}%{$YELLOW%}❮❮%{$RESET%}"

SH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY="%{$RED%}dirty%{$RESET%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$GREEN%}clean%{$RESET%}"
ZSH_THEME_GIT_PROMPT_NONE="%{$GREEN%}latest%{$CYAN%}:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$GREEN%}ahead%{$CYAN%}:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$RED%}behind%{$CYAN%}:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$BLUE%}staged%{$CYAN%}:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$WHITE%}unstaged%{$CYAN%}:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$BLUE%}unmerged%{$CYAN%}:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$RED%}renamed%{$CYAN%}:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$RED%}modified%{$CYAN%}:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$RED%}untracked%{$CYAN%}:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_ADDED="%{$RED%}added%{$CYAN%}:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_DELETED="%{$RED%}deleted%{$CYAN%}:%{$RESET%}"

# Colors vary depending on time lapsed.
ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%{$GREEN%}"
ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM="%{$YELLOW%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%{$RED%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%{$WHITE%}"

# LS colors, made with https://geoff.greer.fm/lscolors/
export LS_COLORS='di=1;30;46:ln=1;35:so=1;32:pi=1;33:ex=1;36:bd=34;46:cd=36:su=1;0;41:sg=1;30;41:tw=30;46:ow=30;46'
export GREP_COLOR='1;33'
