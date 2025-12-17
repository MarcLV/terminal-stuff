#!/usr/bin/env zsh
# Managed by HyDE - Rice Master Git Formatter

function _hyde_git_formatter() {
  emulate -L zsh
  
  # Only run if inside a git repo
  [[ -n $VCS_STATUS_LOCAL_BRANCH || -n $VCS_STATUS_COMMIT ]] || return 0

  # 1. Branch/Tag/Hash
  local branch="${VCS_STATUS_LOCAL_BRANCH:-${VCS_STATUS_TAG:-${VCS_STATUS_COMMIT:0:8}}}"
  
  # 2. Commit Name (Subject)
  local commit_msg=""
  if [[ -n $VCS_STATUS_COMMIT ]]; then
      commit_msg=$(git log -1 --pretty=%s 2>/dev/null | cut -c 1-20)
  else
      commit_msg="no commits"
  fi

  # 3. Numeric Counts (Forcing integer evaluation)
  local staged=${VCS_STATUS_NUM_STAGED:-0}
  local unstaged=${VCS_STATUS_NUM_UNSTAGED:-0}
  local conflicted=${VCS_STATUS_NUM_CONFLICTED:-0}
  local untracked=${VCS_STATUS_NUM_UNTRACKED:-0}
  local ahead=${VCS_STATUS_COMMITS_AHEAD:-0}
  local behind=${VCS_STATUS_COMMITS_BEHIND:-0}

  local counts=""
  (( staged > 0 ))     && counts+="%F{green}+${staged}%f "
  (( unstaged > 0 ))   && counts+="%F{yellow}~${unstaged}%f "
  (( conflicted > 0 )) && counts+="%F{red}✖${conflicted}%f "
  (( untracked > 0 ))  && counts+="%F{red}?${untracked}%f "

  # 4. Status Label Logic
  local status_label="%F{green}latest%f"
  if (( ahead > 0 && behind > 0 )); then status_label="%F{yellow}↕${ahead}↓${behind}%f"
  elif (( ahead > 0 )); then status_label="%F{green}↑${ahead}%f"
  elif (( behind > 0 )); then status_label="%F{red}↓${behind}%f"
  elif (( staged > 0 )); then status_label="%F{blue}staged%f"
  elif (( unstaged > 0 )); then status_label="%F{white}unstaged%f"
  elif (( untracked > 0 )); then status_label="%F{red}untracked%f"
  fi

  # 5. Output (The ${counts% } trims the trailing space)
  echo "%F{cyan}[%F{yellow}${branch}%F{cyan}] [%F{15}${commit_msg}%F{cyan}] [%F{reset}${status_label} ${counts% }%F{cyan}]%f"
}
