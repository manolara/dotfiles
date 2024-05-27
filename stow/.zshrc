
fpath=(~/.oh-my-zsh/custom/completions $fpath)
#                                   kubectl
################################################################################j
export KUBECONFIG=$HOME/.kube/config
for file in $HOME/.kube/configs/*.yaml; do
  export KUBECONFIG=$KUBECONFIG:$file
done

################################################################################
#                                 zsh-vi-mode
################################################################################
function zvm_yank_to_clipboard() {
  zvm_yank
	printf "%s" "$CUTBUFFER" | perl -pe 'chomp if eof' | tmux load-buffer -w -
  zvm_exit_visual_mode
}
function zvm_config() {
  ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
}
function zvm_after_init() {
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
  bindkey -M viins '^ ' autosuggest-accept
  bindkey -M viins '^x^e' zvm_vi_edit_command_line
}
function zvm_after_lazy_keybindings() {
  zvm_define_widget zvm_yank_to_clipboard
  bindkey -M visual 'y' zvm_yank_to_clipboard
  bindkey -M menuselect 'h' vi-backward-char
  bindkey -M menuselect 'k' vi-up-line-or-history
  bindkey -M menuselect 'l' vi-forward-char
  bindkey -M menuselect 'j' vi-down-line-or-history
}

export ZVM_VI_HIGHLIGHT_FOREGROUND=#cdd6f4
export ZVM_VI_HIGHLIGHT_BACKGROUND=#45475a
export ZVM_VI_HIGHLIGHT_EXTRASTYLE=bold
################################################################################
#                                  oh my zsh
################################################################################
autoload -U compinit && compinit
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(
	git
	kube-ps1
	kubectl
	please
        zsh-autosuggestions
        fast-syntax-highlighting
##        zsh-vi-mode
        forgit
)

source $ZSH/oh-my-zsh.sh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source ~/.zsh_aliases

################################################################################
#                                    prompt
################################################################################
export PROMPT="%B%F{blue}%c%b%f"


################################################################################
#                                  git prompt
################################################################################
export ZSH_THEME_GIT_PROMPT_PREFIX="%B(%F{216}"
export ZSH_THEME_GIT_PROMPT_SUFFIX="%f)%b "

export PROMPT="$PROMPT"' $(git_prompt_info)'

################################################################################
#                                   kube-ps1
################################################################################
if kubectl config current-context >/dev/null 2>&1; then
  export KUBE_PS1_SYMBOL_ENABLE=false
  export PROMPT='%B$(kube_ps1)%b'" $PROMPT"
fi

################################################################################
#                                     fzf
################################################################################
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Use fd for find instead of default find
export FZF_DEFAULT_COMMAND="fd --follow --type f --exclude .git --strip-cwd-prefix"

# Use ~~ for completion trigger instead of **
export FZF_COMPLETION_TRIGGER='~~'

# Use fd instead of the default find
_fzf_compgen_path() {
    fd --hidden --follow --exclude .git --strip-cwd-prefix .
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude .git --strip-cwd-prefix .
}

# Use ctrl + t to fuzzy search all files/directories (excluding .git) with preview in current directory
export FZF_CTRL_T_COMMAND='fd --follow --strip-cwd-prefix'
export FZF_CTRL_T_OPTS="--preview 'if [ ! -d {} ]; then bat --color always --wrap never --pager never {}; else eza --classify --all --tree --level=2 --color always {}; fi'"

# Catppuccin theme
# Allow selecting / deselecting of all options
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#000000,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
-m --bind ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all"

################################################################################
#                                random-scripts
################################################################################
aw() {
    # Combine all arguments with spaces and pass them to hyph script
    hyphened_arg=$(~/scripts/hyphen_case.py "$@")
    # Run the 'arc work' command with the output of hyph script
    arc work "$hyphened_arg"
}

################################################################################
#                                 mettle
################################################################################
mettle () {
        local METTLE_CACHE='~/.cache/please/build-metadata-store/mettle_lofi/'
        if [[ $* == "on" ]]
        then
                export PLZ_CONFIG_PROFILE=remote
        elif [[ $* == "off" ]]
        then
                export PLZ_CONFIG_PROFILE=noremote
        elif [[ $* == "clear" ]]
        then
                echo "rm -rf $METTLE_CACHE"
                rm -rf $METTLE_CACHE
        elif [[ $* == "status" ]]
        then
                if [[ "$PLZ_CONFIG_PROFILE" == "noremote" ]]
                then
                        echo "disabled"
                else
                        echo "enabled"
                fi
        else
                echo 'Usage: mettle [on|off|clear|status]'
                return 1
        fi
}

################################################################################
#                                 general
################################################################################

export EDITOR=nvim
export PATH=$HOME/.local/bin:$PATH
##bindkey "^P" history-search-backward
##bindkey "^N" down-line-or-search
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^P" up-line-or-beginning-search
bindkey "^N" down-line-or-beginning-search

export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket

[[ $commands[kubectl] ]] && source <(kubectl completion zsh)



