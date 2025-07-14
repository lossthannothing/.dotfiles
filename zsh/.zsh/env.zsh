# dotfiles/zsh/env.zsh
# 加载 .env 文件中的私密变量
if [ -f ~/.env ]; then
    source ~/.env
fi
