PROMPT_COLOR="\033[32m"
if [ "$(id -u)" -eq 0 ]; then
    PROMPT_COLOR="\033[31m"
fi

export PS1="\[$PROMPT_COLOR\]\u [ \[\033[37m\]\w \[$PROMPT_COLOR\]]\\$ \[\033[0m\]"

alias ls="ls -p"