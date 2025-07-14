# dotfiles/zsh/functions.zsh

# 上级目录跳转
up() {
  local count=${1:-1}
  local dir=""
  for ((i=0; i<count; i++)); do
    dir="../$dir"
  done
  cd "$dir"
}

# 统一解压函数
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

# 解压并删除源文件
function extract_and_remove {
  extract $1
  rm -f $1
}

# 创建目录并进入
mkcd() {
    mkdir -p "$@" && cd "$_";
}

# 代理函数
proxy () {
  export HTTP_PROXY="http://127.0.0.1:7897"
  export HTTPS_PROXY="http://127.0.0.1:7897"
  export ALL_PROXY="http://127.0.0.1:7897"
}

unproxy () {
  unset ALL_PROXY HTTP_PROXY HTTPS_PROXY all_proxy
}