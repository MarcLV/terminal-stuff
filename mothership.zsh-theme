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
    local INDEX=$(git status --porcelain 2>/dev/null)
    local STATUS=""

    # Ahead / Behind counts
    local AHEAD=$(git rev-list --count origin/$(git_current_branch)..HEAD 2>/dev/null || echo 0)
    local BEHIND=$(git rev-list --count HEAD..origin/$(git_current_branch) 2>/dev/null || echo 0)

    # File change counts
    local STAGED_COUNT=$(echo "$INDEX" | grep -c '^[^ ?][^ ]')
    local UNSTAGED_COUNT=$(echo "$INDEX" | grep -c '^ [MDRAU] ')
    local CONFLICT_COUNT=$(echo "$INDEX" | grep -c '^[ADU][ADU] ')
    local UNTRACKED_COUNT=$(echo "$INDEX" | grep -c '^?? ')

    local COUNTS=""
    [[ $STAGED_COUNT -gt 0 ]] && COUNTS="${COUNTS}%{$GREEN%}+$STAGED_COUNT%{$RESET%} "
    [[ $UNSTAGED_COUNT -gt 0 ]] && COUNTS="${COUNTS}%{$YELLOW%}~${UNSTAGED_COUNT}%{$RESET%} "
    [[ $CONFLICT_COUNT -gt 0 ]] && COUNTS="${COUNTS}%{$RED%}✖${CONFLICT_COUNT}%{$RESET%} "
    [[ $UNTRACKED_COUNT -gt 0 ]] && COUNTS="${COUNTS}%{$RED%}?${UNTRACKED_COUNT}%{$RESET%} "

    local DIVERGE=""
    if [[ $AHEAD -gt 0 && $BEHIND -gt 0 ]]; then
      DIVERGE="%{$YELLOW%}↕${AHEAD}↓${BEHIND}%{$RESET%}"
    elif [[ $AHEAD -gt 0 ]]; then
      DIVERGE="%{$GREEN%}↑$AHEAD%{$RESET%}"
    elif [[ $BEHIND -gt 0 ]]; then
      DIVERGE="%{$RED%}↓$BEHIND%{$RESET%}"
    fi

    # Main status indicator
    if [[ -n $DIVERGE ]]; then
      STATUS="$DIVERGE"
    elif [[ $STAGED_COUNT -gt 0 ]]; then
      STATUS="%{$BLUE%}staged%{$CYAN%}:%{$RESET%}"
    elif [[ $UNSTAGED_COUNT -gt 0 ]]; then
      STATUS="%{$WHITE%}unstaged%{$CYAN%}:%{$RESET%}"
    elif [[ $CONFLICT_COUNT -gt 0 ]]; then
      STATUS="%{$RED%}unmerged%{$CYAN%}:%{$RESET%}"
    elif [[ $UNTRACKED_COUNT -gt 0 ]]; then
      STATUS="%{$RED%}untracked%{$CYAN%}:%{$RESET%}"
    else
      STATUS="%{$GREEN%}latest%{$CYAN%}:%{$RESET%}"
    fi

    # Append counts if any changes exist
    [[ -n $COUNTS ]] && STATUS="${STATUS} ${COUNTS}"

    echo "%{$CYAN%}[%{$YELLOW%}$(_current_branch)%{$CYAN%}]%{$RESET%} %{$CYAN%}[%{$RESET%}$(_shortened_commit)%{$CYAN%}] [%{$RESET%}$STATUS$(parse_git_dirty)%{$CYAN%}]"
  else
    local count=$(find . -maxdepth 1 -not -path '*/\.*' | wc -l | tr -d ' ')
    echo "%{$CYAN%}[%{$RESET%}$((count - 1)) files%{$CYAN%}]"
  fi
}

_shortened_commit() {
  if git rev-parse HEAD >/dev/null 2>&1; then
    local latest_commit=$(git log --format=%B -n 1 HEAD | head -n 1 | sed 's/^[ \t]*//;s/[ \t]*$//')
    if [[ ${#latest_commit} -le 15 ]]; then
      echo "$latest_commit"
    else
      echo "${latest_commit:0:15}.."
    fi
  else
    echo "no commits"
  fi
}

# Python virtualenv info (cyan brackets, white content)
_virtualenv_info() {
  [[ -n $VIRTUAL_ENV ]] && echo "%{$CYAN%}[%{$WHITE%}venv:$(basename $VIRTUAL_ENV)%{$CYAN%}]%{$RESET%}"
}

# Node version info (cyan brackets, white content)
_node_version() {
  if command -v node >/dev/null 2>&1; then
    echo "%{$CYAN%}[%{$WHITE%}node:$(node -v | cut -c2-)%{$CYAN%}]%{$RESET%}"
  fi
}

# Last command duration (only if >10 seconds)
_cmd_duration() {
  [[ $cmd_start ]] && (( SECONDS - cmd_start > 10 )) && echo "%{$RED%}[took $((SECONDS - cmd_start))s]%{$RESET%}"
}

# Set prompts – removed trailing spaces after env/duration segments
PROMPT='
%{$CYAN%}┌─[$(_time)%{$RESET%} ${_current_dir}$(_error_status)$(_virtualenv_info)$(_node_version)$(_cmd_duration)
%{$CYAN%}└─ %{$RESET%}$(_user_host) '

RPROMPT='$(_viStatus)%{$(echotc UP 1)%} $(_git_prompt_info) %{$RESET%}%{$(echotc DO 1)%}'

# Current directory – single space after directory
_current_dir="%{$YELLOW%}%2~%{$RESET%} "

# Error status with signal name (fixed to run in precmd)
_error_status() {
  local code=$LAST_EXIT_CODE  # Set by precmd below
  [[ $code -eq 0 ]] && return

  local msg="%{$RED%}!"

  if [[ $code -gt 128 ]]; then
    local sig=$((code - 128))
    local signame
    case $sig in
      1)  signame="HUP" ;;
      2)  signame="INT" ;;   # Ctrl+C
      3)  signame="QUIT" ;;
      4)  signame="ILL" ;;
      6)  signame="ABRT" ;;
      8)  signame="FPE" ;;
      9)  signame="KILL" ;;
      11) signame="SEGV" ;;
      13) signame="PIPE" ;;
      15) signame="TERM" ;;
      *)  signame="SIG$sig" ;;
    esac
    msg="${msg}${signame} "
  else
    msg="${msg}$code"
  fi

  echo "${msg}%{$RESET%}"
}

# Current time
_time() {
  echo "%{$RESET%}$(date +'%H:%M:%S')%{$CYAN%}]"
}

# Current branch (truncated if long)
_current_branch() {
  echo "%18>…>$(git_current_branch)%>>"
}

# User@host with blinking for SSH/root
_user_host() {
  local me
  if [[ -n $SSH_CONNECTION ]]; then
    me="%n@%m"
  else
    me="%n"
  fi

  local BLINK="%{\e[5m%}"
  local RST="%{\e[0m%}"
  if [[ $USER == "root" ]]; then
    echo "${BLINK}%{$RED%}$me${RST}%{$CYAN%}:"
  elif [[ -n $SSH_CONNECTION ]]; then
    echo "${BLINK}%{$GREEN%}$me${RST}%{$CYAN%}:"
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

# Track command start time for duration
preexec() {
  cmd_start=$SECONDS
}

# Capture exit code and reset duration
precmd() {
  LAST_EXIT_CODE=$?
  unset cmd_start
}

# Git status prompts (kept for compatibility)
ZSH_THEME_GIT_PROMPT_DIRTY="%{$RED%}dirty%{$RESET%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$GREEN%}clean%{$RESET%}"

# LS and GREP colors
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36;'
export GREP_COLOR='1;33'

# Live clock (reset prompt every second)
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

# Auto ls on cd
cd() {
    builtin cd "$@"
    ls
}
