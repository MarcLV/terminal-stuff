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
    original_minutes=$((seconds_since_last_commit/60))
    original_hours=$((original_minutes/60))
    original_days=$((original_hours/24))
    original_months=$((original_days/30))
    original_years=$((original_months/12))

    # Calculate and display correct time (ex: instead of 63 days it will display 2m3d which is 2 months and 3 days (as in 63..))
    years=$[$diff/$[60*60*24*365]]
    diff=$[$diff%(60*60*24*365)]
    months=$[$diff/(60*60*24*30)]
    diff=$[$diff%(60*60*24*30)]
    days=$[$diff/(60*60*24)]
    diff=$[$diff%(60*60*24)]
    hours=$[$diff/(60*60)]
    diff=$[$diff%(60*60)]
    minutes=$[$diff/60]

    # Years
    if [ $original_months -ge 12 ]; then
      commit_age="${years}y${months}m"
    # Months
    elif [ $original_days -ge 30 ]; then
      commit_age="${months}m${days}d"
    # Days
    elif [ $original_hours -ge 24 ]; then
      commit_age="${days}d${hours}h"
    # Hours
    elif [ $original_minutes -ge 60 ]; then 
      commit_age="${hours}h${minutes}m"
    # Minutes
    elif [ $seconds_since_last_commit -ge 60 ]; then 
      commit_age="${minutes}m${seconds_since_last_commit}s"
    # Seconds
    else
      commit_age="${seconds_since_last_commit}s.."
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
ZSH_THEME_GIT_PROMPT_NONE="%{$GREEN%}none:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$GREEN%}ahead:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$BLUE%}behind:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$BLUE%}staged:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$RED%}unstaged:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$RED%}unmerged:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$RED%}renamed:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$RED%}modified:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$RED%}untracked:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_ADDED="%{$RED%}+ added:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_DELETED="%{$RED%}- deleted:%{$RESET%}"

# Colors vary depending on time lapsed.
ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%{$GREEN%}"
ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM="%{$YELLOW%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%{$RED%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%{$WHITE%}"

# LS colors, made with https://geoff.greer.fm/lscolors/
export LS_COLORS='di=1;30;46:ln=1;35:so=1;32:pi=1;33:ex=1;36:bd=34;46:cd=36:su=1;0;41:sg=1;30;41:tw=30;46:ow=30;46'
export GREP_COLOR='1;33'
