# ~/.config/fish/functions/switch_proxy.fish

function switch_proxy --description "Enable or disable HTTP/HTTPS/SOCKS proxy"
    if test "$argv[1]" = "on"
        # 定义代理地址和端口
        set -gx HTTP_PROXY "http://127.0.0.1:10808"
        set -gx HTTPS_PROXY "http://127.0.0.1:10808"
        set -gx ALL_PROXY "socks5://127.0.0.1:10808" # SOCKS5 代理通常用于 ALL_PROXY
        set -gx NO_PROXY "localhost,127.0.0.1,::1" # 排除本地地址

        # 为了兼容一些老旧或特定的程序，也设置小写形式
        set -gx http_proxy "$HTTP_PROXY"
        set -gx https_proxy "$HTTPS_PROXY"
        set -gx all_proxy "$ALL_PROXY"
        set -gx no_proxy "$NO_PROXY"

        echo "代理已启用：" (set_color green) "ON" (set_color normal)
        echo "  HTTP_PROXY: "$HTTP_PROXY
        echo "  HTTPS_PROXY: "$HTTPS_PROXY
        echo "  ALL_PROXY: "$ALL_PROXY
        echo "  NO_PROXY: "$NO_PROXY
    else if test "$argv[1]" = "off"
        # 清除所有代理环境变量
        set -e HTTP_PROXY
        set -e HTTPS_PROXY
        set -e ALL_PROXY
        set -e NO_PROXY
        set -e http_proxy
        set -e https_proxy
        set -e all_proxy
        set -e no_proxy

        echo "代理已禁用：" (set_color red) "OFF" (set_color normal)
    else
        # 显示当前代理状态
        echo "用法: switch_proxy [on|off]"
        echo ""
        if set -q HTTP_PROXY
            echo "当前代理状态：" (set_color green) "ON" (set_color normal)
            echo "  HTTP_PROXY: "$HTTP_PROXY
            echo "  HTTPS_PROXY: "$HTTPS_PROXY
            echo "  ALL_PROXY: "$ALL_PROXY
            echo "  NO_PROXY: "$NO_PROXY
        else
            echo "当前代理状态：" (set_color red) "OFF" (set_color normal)
        end
    end
end
