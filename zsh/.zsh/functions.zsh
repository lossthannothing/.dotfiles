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

# --- proxy helper for WSL NAT / normal Linux/macOS ---
# 默认端口（可改），也可通过 PROXY_PORT 环境变量覆盖
: "${PROXY_PORT:=7897}"

# 内部：是否在 WSL（WSL1/WSL2 均可识别）
_is_wsl() {
  [[ -n "$WSL_DISTRO_NAME" ]] && return 0
  grep -qi "microsoft" /proc/version 2>/dev/null
}

# 内部：取宿主机地址（WSL NAT 下的网关）
_get_host() {
  if _is_wsl; then
    # 优先用默认路由网关；失败再从 resolv.conf 取 DNS
    local gw
    gw=$(ip route 2>/dev/null | awk '/default/ {print $3; exit}')
    [[ -z "$gw" ]] && gw=$(awk '/nameserver/ {print $2; exit}' /etc/resolv.conf 2>/dev/null)
    echo "${gw:-127.0.0.1}"
  else
    echo "127.0.0.1"
  fi
}

# 导出代理变量
_set_proxy_env() {
  local scheme="$1" host="$2" port="$3"

  case "$scheme" in
    http|https)
      export http_proxy="http://${host}:${port}"
      export https_proxy="$http_proxy"
      unset all_proxy
      ;;
    socks5|socks5h)
      # 用 socks5h 让代理端解析 DNS，避免 DNS 泄漏/解析失败
      [[ "$scheme" = "socks5" ]] && scheme="socks5h"
      export all_proxy="${scheme}://${host}:${port}"
      unset http_proxy https_proxy
      ;;
    *)
      echo "Unsupported scheme: $scheme (use: http|socks5h)" >&2
      return 1
      ;;
  esac

  # 大小写都设置，兼容更多程序
  export HTTP_PROXY="$http_proxy" HTTPS_PROXY="$https_proxy" ALL_PROXY="$all_proxy"

  # 直连名单：本机/内网/宿主机
  local np="localhost,127.0.0.1,::1,*.local,*.lan,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,${host}"
  export no_proxy="$np" NO_PROXY="$np"
}

# 清除代理变量
_unset_proxy_env() {
  unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY no_proxy NO_PROXY
}

# 端口连通性测试（不依赖 nc）
_port_check() {
  local host="$1" port="$2"
  timeout 3 bash -c ">/dev/tcp/${host}/${port}" 2>/dev/null
}

# 主命令：proxy [on|off|status|test] [http|socks5h] [port]
proxy() {
  local cmd="${1:-on}"
  local scheme="${2:-http}"          # 默认 http，如需 SOCKS5：socks5h
  local port="${3:-$PROXY_PORT}"     # 默认 7897，或用 PROXY_PORT 覆盖
  local host
  host="$(_get_host)"

  case "$cmd" in
    on)
      _set_proxy_env "$scheme" "$host" "$port" || return $?
      echo "Proxy ON -> scheme=${scheme} host=${host} port=${port}"
      echo "no_proxy=$no_proxy"
      ;;

    off)
      _unset_proxy_env
      echo "Proxy OFF"
      ;;

    status)
      echo "WSL: $(_is_wsl && echo yes || echo no)"
      echo "Host: $host"
      echo "Port: ${port}  Scheme: ${scheme}"
      env | grep -E '^(http|https|all|HTTP|HTTPS|ALL|no|NO)_proxy' | sort
      ;;

    test)
      # 先测端口，再用 curl 试一次外网
      if _port_check "$host" "$port"; then
        echo "Port reachable: ${host}:${port}"
      else
        echo "Port NOT reachable: ${host}:${port}"
        echo "提示：确保你的代理已开启“Allow LAN/允许局域网连接”，并放行 Windows 防火墙端口。"
      fi

      if command -v curl >/dev/null 2>&1; then
        if [[ "$scheme" = "http" || "$scheme" = "https" ]]; then
          curl -I -m 8 -x "http://${host}:${port}" https://www.google.com || true
        else
          curl -I -m 8 --socks5-hostname "${host}:${port}" https://www.google.com || true
        fi
      else
        echo "curl 未安装，跳过 HTTP 连通性验证。"
      fi
      ;;

    *)
      cat <<EOF
Usage: proxy [on|off|status|test] [http|socks5h] [port]
Examples:
  proxy on            # WSL: 用网关IP + 7897；非WSL: 127.0.0.1 + 7897
  proxy on http 7897  # 显式 http 代理
  proxy on socks5h 7891
  proxy off
  proxy status
  proxy test
Tip:
  - WSL NAT 模式下请在 Windows 代理程序里开启 "Allow LAN/允许局域网连接"
  - 可导出 PROXY_PORT 来更改默认端口（当前默认：$PROXY_PORT）
EOF
      ;;
  esac
}

# 方便手速的别名
proxy_on()  { proxy on  "${1:-http}"    "${2:-$PROXY_PORT}"; }
proxy_off() { proxy off; }