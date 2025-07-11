# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# ~/.zshrc

# ------------------------------------------------------------------
# 2. 1. Environment Variables
# ------------------------------------------------------------------
# Add user's local bin directories to PATH for scripts and local installations.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
# ~/.zshrc
if [ -f ~/.env ]; then
    source ~/.env
fi
# Set language and locale to prevent character encoding issues.
# For Chinese environment as requested.
# export LANG=zh_CN.UTF-8

# Set preferred editor, using 'vim' in SSH sessions and 'nvim' locally.
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi
# ----- Language Env-----#

#fnm init
FNM_PATH="/home/Geist/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi

#rustup
. "$HOME/.cargo/env" 

# ------------------------------------------------------------------
# 2. 插件管理器初始
# ------------------------------------------------------------------

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
# 初始化 Zsh 的补全系统
#    这必须在加载任何使用 `compdef` 的插件 (通过 sheldon) 之前完成。
autoload -U compinit
compinit
if command -v sheldon &> /dev/null; then
  eval "$(sheldon source)"
fi

# ------------------------------------------------------------------
# 4. 编程环境&效率工具初始化
# They modify the PATH to prepend their shims.
# ------------------------------------------------------------------

# ----- cli tools config ----- #
# zoxide 初始化 (智能 cd)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
  # 你可以用 `zi` 代替 `z` 来进行交互式模糊搜索目录
  alias zi="z -i"
fi


# ------------------------------------------------------------------
# 5. Zsh 选项 (Options)
# configure shell behavior
# ------------------------------------------------------------------
# 已被history插件接管

# ------------------------------------------------------------------
# Section 6: 别名与函数
#
# 自定义简写。在最后用于重载任何前面的工具潜在的冲突
# ------------------------------------------------------------------

# Core Utils
alias ls='lsd'
alias ll='lsd -alhF'
alias la='lsd -A'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# git new features
alias gwt="git worktree"
alias gwta="git worktree add"
alias gwtl="git worktree list"
alias gwtr="git worktree remove"
alias gwtpr="git worktree prune"

# Custom Functions
# Example: go up N directories
up() {
  local count=${1:-1}
  local dir=""
  for ((i=0; i<count; i++)); do
    dir="../$dir"
  done
  cd "$dir"
}
# Archives
function extract {
  if [ -z "$1" ]; then
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
  else
    if [ -f $1 ]; then
      case $1 in
        *.tar.bz2)   tar xvjf $1    ;;
        *.tar.gz)    tar xvzf $1    ;;
        *.tar.xz)    tar xvJf $1    ;;
        *.lzma)      unlzma $1      ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar x -ad $1 ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xvf $1     ;;
        *.tbz2)      tar xvjf $1    ;;
        *.tgz)       tar xvzf $1    ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *.xz)        unxz $1        ;;
        *.exe)       cabextract $1  ;;
        *)           echo "extract: '$1' - unknown archive method" ;;
      esac
    else
      echo "$1 - file does not exist"
    fi
  fi
}
alias extr='extract '
function extract_and_remove {
  extract $1
  rm -f $1
}
alias extrr='extract_and_remove '

# Example: create a directory and cd into it
mkcd() {
    mkdir -p "$@" && cd "$_";
}
# 为 curl wget git 等设置代理
proxy () {
export HTTP_PROXY="http://127.0.0.1:7897"
export HTTPS_PROXY="http://127.0.0.1:7897"
export ALL_PROXY="http://127.0.0.1:7897"
}


# 取消代理
unproxy () {
  unset ALL_PROXY
  unset all_proxy
}

# pnpm
export PNPM_HOME="/home/Geist/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
# cunzhi mcp cli
