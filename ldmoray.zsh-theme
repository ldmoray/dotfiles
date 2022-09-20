# vim:ft=zsh ts=2 sw=2 sts=2

# https://gist.github.com/ldmoray/90845fae1fef04e56518fc58e1d50857

# Characters
SEGMENT_OPEN="["
SEGMENT_CLOSE="]"
PLUSMINUS="\u00b1"
CROSS="\u2718"
LIGHTNING="\u26a1"
GEAR="\u2699"

# Write a segment
# The first argument is text to write, the optional second is the color to write it
prompt_segment() {
  local color
  if [[ -n $1 ]]; then
    [[ -n $2 ]] && color="%F{$2}" || color="%f"
    print -n "%{$color%}$SEGMENT_OPEN$1$SEGMENT_CLOSE%{%f%}"
  fi
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown
prompt_context() {
  local user=`whoami`
  local color
  [[ -n $1 ]] && color=$1 || color=yellow
  prompt_segment "$user" $color
}

# Git: branch/detached head, dirty status
prompt_git() {
  local ref
  local color
  [[ -n $1 ]] && color=$1 || color=magenta

  is_dirty() {
    test -n "$(git status --porcelain --ignore-submodules)"
  }
  ref="$vcs_info_msg_0_"
  if [[ -n "$ref" ]]; then
    if is_dirty; then
      ref="$PLUSMINUS ${ref}"
    else
      ref="${ref}"
    fi
    prompt_segment "$ref" $color
  fi
}

# Dir: current working directory
prompt_dir() {
  local color
  [[ -n $1 ]] && color=$1 || color=blue
  prompt_segment '%~' $color
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  local color
  [[ -n $1 ]] && color=$1 || color=red
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="$CROSS"
  [[ $UID -eq 0 ]] && symbols+="$LIGHTNING"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="$GEAR"

  [[ -n "$symbols" ]] && prompt_segment "$symbols" $color
}

# Display current virtual environment
prompt_virtualenv() {
  if [[ -n $VIRTUAL_ENV ]]; then
    local color
    [[ -n $1 ]] && color=$1 || color=cyan
    prompt_segment "$(basename $VIRTUAL_ENV)" $color
  fi
}

## Main prompt
prompt_ldmoray_main() {
  RETVAL=$?
  prompt_status
  prompt_virtualenv
  prompt_context
  prompt_dir
  prompt_git
  print -n ":"
}

prompt_ldmoray_precmd() {
  vcs_info
  PROMPT='%{%f%b%k%}$(prompt_ldmoray_main) '
}

prompt_ldmoray_setup() {
  autoload -Uz add-zsh-hook
  autoload -Uz vcs_info

  prompt_opts=(cr subst percent)

  add-zsh-hook precmd prompt_ldmoray_precmd

  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' check-for-changes false
  zstyle ':vcs_info:git*' formats '%b'
  zstyle ':vcs_info:git*' actionformats '%b (%a)'
}

prompt_ldmoray_setup "$@"
