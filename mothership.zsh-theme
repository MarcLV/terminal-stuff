# Color shortcuts
CYAN="%{$fg_no_bold[cyan]%}"
YELLOW="%{$fg_bold[yellow]%}"
WHITE="%{$fg_no_bold[white]%}"
GREEN="%{$fg_no_bold[green]%}"
RED="%{$fg_no_bold[red]%}"
BLUE="%{$fg_no_bold[blue]%}"
RESET="%{$reset_color%}"

# Git prompt info
_git_prompt_info() {
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    local ref=$(git symbolic-ref HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo "No commits..")
    local INDEX=$(git status --porcelain 2>/dev/null)
    local STATUS=""

    # Determine git status
    if [ "$(git rev-parse --is-empty)" = "true" ]; then
      echo "%{$CYAN%}[%{$RESET%}Empty repo%{$CYAN%}]"
      return
    fi
    if git log origin/$(git_current_branch)..HEAD &>/dev/null; then
      STATUS="$ZSH_THEME_GIT_PROMPT_AHEAD"
    elif git log HEAD..origin/$(git_current_branch) &>/dev/null; then
      STATUS="$ZSH_THEME_GIT_PROMPT_BEHIND"
    elif echo "$INDEX" | grep -qE '^(D[ M]|[MARC][ MD]) '; then
      STATUS="$ZSH_THEME_GIT_PROMPT_STAGED"
    elif echo "$INDEX" | grep -q '^[MTD] '; then
      STATUS="$ZSH_THEME_GIT_PROMPT_UNSTAGED"
    elif echo "$INDEX" | grep -q '^\?\? '; then
      STATUS="$ZSH_THEME_GIT_PROMPT_UNTRACKED"
    elif echo "$INDEX" | grep -qE '^(A[AU]|D[DU]|U[ADU]) '; then
      STATUS="$ZSH_THEME_GIT_PROMPT_UNMERGED"
    else
      STATUS="$ZSH_THEME_GIT_PROMPT_NONE"
    fi

    echo "%{$CYAN%}[%{$YELLOW%}$(_current_branch)%{$CYAN%}]%{$RESET%} %{$CYAN%}[%{$RESET%}$(_shortened_commit)%{$CYAN%}] [%{$RESET%}$STATUS$(parse_git_dirty)%{$CYAN%}]"
  else
    count=$(find . -maxdepth 1 -not -path '*/\.*' | wc -l)
    echo "%{$CYAN%}[%{$RESET%}$((count - 1)) files%{$CYAN%}]"
  fi
}

_shortened_commit() {
  if git rev-parse HEAD >/dev/null 2>&1; then
    # Get the latest commit message
    local latest_commit=$(git log --format=%B -n 1 | head -n 1)
    # Shorten the message to x characters max
    local shortened_commit=${latest_commit:0:15}

    # If the message is less than x characters, use it as is
    if [ ${#shortened_commit} -lt 15 ]; then
        echo "$latest_commit"
    else
        echo "$shortened_commit.."
    fi
  else
    local BLINK="\e[5m"
    local RESET="\e[0m"
    echo "${BLINK}no commits${RESET}"
  fi
}

# Set prompt
PROMPT='
%{$CYAN%}┌─[$(_time) ${_current_dir} ${_error_status}
%{$CYAN%}└─ %{$RESET%}$(_user_host) '

RPROMPT='$(_viStatus)%{$(echotc UP 1)%} $(_git_prompt_info) %{$RESET%}%{$(echotc DO 1)%}'

# Current directory and return status
_current_dir="%{$YELLOW%}%2~%{$RESET%} "
_error_status="%{$fg_bold[red]%}%(?..…err!)%{$RESET%}"

_date() {
  echo "%{$CYAN%}[%{$RESET%}$(date '+%a')%{$CYAN%}]"
}

# Current time in formatted style
_time() {
  echo "%{$RESET%}$(date +'%H:%M:%S')%{$CYAN%}]"
}
_day() {
  date '+%a'
}

# Current branch
_current_branch() {
  echo "%18>…>$(current_branch)%>>"
}

# User and host info
_user_host() {
  local me

  if [[ -n $SSH_CONNECTION ]]; then
    me="%n@%m"
  else
    me="%n"
  fi

  local BLINK="\e[5m"
  local RESET="\e[0m"
  if [[ $USER == "root" ]]; then
    echo "${BLINK}%{$RED%}$me${RESET}%{$CYAN%}:" 
  elif [[ -n $SSH_CONNECTION ]]; then
    echo "${BLINK}%{$GREEN%}$me${RESET}%{$CYAN%}:" 
  else
    echo "%{$RESET%}$me%{$CYAN%}:"
  fi  
}

# Vi mode status
_viStatus() {
  if echo $fpath | grep -q "plugins/vi-mode"; then
    echo "$(vi_mode_prompt_info)"
  fi
}

# Git status prompts
ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY="%{$RED%}dirty%{$RESET%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$GREEN%}clean%{$RESET%}"
ZSH_THEME_GIT_PROMPT_NONE="%{$GREEN%}latest%{$CYAN%}:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$GREEN%}ahead%{$CYAN%}:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$RED%}behind%{$CYAN%}:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$BLUE%}staged%{$CYAN%}:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$WHITE%}unstaged%{$CYAN%}:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$BLUE%}unmerged%{$CYAN%}:%{$RESET%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$RED%}untracked%{$CYAN%}:%{$RESET%}"

# Colors for time since last commit
ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%{$GREEN%}"
ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM="%{$YELLOW%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%{$RED%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%{$WHITE%}"

# LS colors
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:';
export GREP_COLOR='1;33'

# Reset terminal every second (for clock)
TMOUT=1
TRAPALRM() {
    case "$WIDGET" in
        expand-or-complete|up-line-or-beginning-search|down-line-or-beginning-search|.history-incremental-search-backward|.history-incremental-search-forward|.history-incremental-search-backward|.history-incremental-search-forward)
            ;;

        *)
            zle reset-prompt
            ;;
    esac
}

cd () {
    builtin cd "$@"
    ls
}

