# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
# 初始化 Zsh 的补全系统
#    这必须在加载任何使用 `compdef` 的插件 (通过 sheldon) 之前完成。
autoload -U compinit
compinit
if command -v sheldon &> /dev/null; then
  eval "$(sheldon source)"
fi
eval "$(fnm env)"
export PATH=$HOME/.local/bin:$PATH