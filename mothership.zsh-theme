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

	echo "%{$fg[cyan]%}╾─$(_git_time_since_commit)%{$fg[cyan]%}─($STATUS $(parse_git_dirty)%{$fg[cyan]%})─[%{$resetcolor%}%{$fg[yellow]%}$(current_branch)%{$fg[cyan]%}]─╼%{$resetcolor%}"
}

PROMPT='
%{$fg[cyan]%}┌─[$(timeNow)%{$fg[cyan]%}] ${_current_dir}
%{$fg[cyan]%}└──╼%{$resetcolor%} '

RPROMPT='$(_vi_status)%{$(echotc UP 1)%} %{$reset_color%} $(git_prompt_info)${_return_status}%{$(echotc DO 1)%}'

local _current_dir="%{$fg_bold[yellow]%}%3~%{$reset_color%} "
local _return_status="%{$fg_bold[red]%}%(?..(err)%{$reset_color%}"
local _hist_no="%{$fg[grey]%}%h%{$reset_color%}"

timeNow() {
	echo $'%F{white}%*%f'
}

function _current_dir() {
  local _max_pwd_length="65"
  if [[ $(echo -n $PWD | wc -c) -gt ${_max_pwd_length} ]]; then
    echo "%-2~ ... %3~ "
  else
    echo "%~ "
  fi
}

function _user_host() {
  if [[ -n $SSH_CONNECTION ]]; then
    me="%n@%m"
  elif [[ $LOGNAME != $USER ]]; then
    me="%n"
  fi
  if [[ -n $me ]]; then
    echo "%{$fg[white]%}$me%{$reset_color%}"
  fi
}

function _vi_status() {
  if {echo $fpath | grep -q "plugins/vi-mode"}; then
    echo "$(vi_mode_prompt_info)"
  fi
}

# Determine the time since last commit. If branch is clean,
# use a neutral color, otherwise colors will vary according to time.
function _git_time_since_commit() {
# Only proceed if there is actually a commit.
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
    sub_hours=$((hours % 24))
    sub_minutes=$((minutes % 60))
    sub_days=$((minutes % 86400))
    sub_months=$((minutes % 86400))
    sub_years=$((minutes % 86400))

    #YEAR
    if [ $months -ge 12 ]; then
      commit_age="${sub_years}y:${sub_months}m"
    #MONTH
    elif [ $days -gt 30 ]; then
      commit_age="${sub_months}m:${sub_days}d"
    #DAYS
    elif [ $hours -gt 24 ]; then
      commit_age="${sub_days}d:${sub_hours}h"
    #HOURS
    elif [ $minutes -gt 60 ]; then
      commit_age="${sub_hours}h:${sub_minutes}m"
    #MINS
    else
      commit_age="${minutes}m"
    fi

    color=$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL
    echo "%{$fg[cyan]%}[$color$commit_age%{$fg[cyan]%}]%{$reset_color%}"
  fi
}

if [[ $USER == "root" ]]; then
  CARETCOLOR="red"
else
  CARETCOLOR="white"
fi

MODE_INDICATOR="%{$fg_bold[yellow]%}❮%{$reset_color%}%{$fg[yellow]%}❮❮%{$reset_color%}"

SH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_NONE="%{$fg[green]%}✓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}dirty%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}clean%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%}✚"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[cyan]%}↑%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[green]%}↓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[green]%}→%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg[red]%}←%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%}⚑"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}x"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[blue]%}▴"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[cyan]%}§"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[white]%}↝"

# Colors vary depending on time lapsed.
ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%{$fg[green]%}"
ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM="%{$fg[yellow]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%{$fg[red]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%{$fg[white]%}"

# LS colors, made with https://geoff.greer.fm/lscolors/
export LSCOLORS="exfxcxdxbxegedabagacad"
export LS_COLORS='di=34;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:'
export GREP_COLOR='1;33'
