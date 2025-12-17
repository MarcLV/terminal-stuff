# Powerlevel10k configuration for HyDE / Arch Linux

# Custom Login Segment
function prompt_my_login() {
  p10k segment -f reset -i " %n%F{cyan}:%f "
}

# --- PROMPT LAYOUT ---
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  time dir status newline my_login
)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=( vcs )

# --- CORE VISUALS ---
typeset -g POWERLEVEL9K_MODE=nerdfont-complete
typeset -g POWERLEVEL9K_BACKGROUND=none
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=''
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=''
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='%F{cyan}┌─%f'
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{cyan}└─%f'

# --- TIME (White, No Icon) ---
typeset -g POWERLEVEL9K_TIME_FOREGROUND='none'
typeset -g POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_TIME_PREFIX='%f%F{cyan}[%F{15}'
typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
typeset -g POWERLEVEL9K_TIME_SUFFIX='%F{15}%F{cyan}]%f'

# --- DIRECTORY (2-Folder Depth) ---
typeset -g POWERLEVEL9K_DIR_FOREGROUND='yellow'
typeset -g POWERLEVEL9K_DIR_SHORTEN_STRATEGY=truncate_from_before_last
typeset -g POWERLEVEL9K_DIR_MAX_NUM_DIRS=2
typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=0
typeset -g POWERLEVEL9K_DIR_SHORTEN_DELIMITER=''
typeset -g POWERLEVEL9K_DIR_PREFIX='%F{yellow} %f'
typeset -g POWERLEVEL9K_DIR_VISUAL_IDENTIFIER_EXPANSION=''

# --- STATUS (Checkmark) ---
typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION=''
typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'

# --- VCS / GIT (Expert Mode) ---
typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='$(source ~/.config/hyde/zsh/git_format.zsh; _hyde_git_formatter)'
typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=''

# Force Full Counting (Crucial for +1 bug)
typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1
typeset -g POWERLEVEL9K_VCS_UNTRACKED_MAX_NUM=-1
typeset -g POWERLEVEL9K_VCS_STAGED_MAX_NUM=-1
typeset -g POWERLEVEL9K_VCS_UNSTAGED_MAX_NUM=-1

# --- VI MODE (Hidden) ---
typeset -g POWERLEVEL9K_VI_INSERT_MODE_STRING=''
typeset -g POWERLEVEL9K_VI_COMMAND_MODE_STRING=''
