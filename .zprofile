# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH"

# Load the shell dotfiles
for file in ~/.{zsh_prompt,path,exports,aliases,functions,extra}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt inc_append_history     # add commands to HISTFILE in order of execution
setopt share_history          # share command history data

# Zsh options equivalent to bash shopt settings
setopt no_case_glob           # Case insensitive globbing
setopt auto_cd                # Auto cd into directory by just typing its name
setopt extended_glob          # Extended globbing. Allows using regular expressions with *

# Load completion system
autoload -Uz compinit
compinit

# Completion options
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"   # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                        # automatically find new executables in path
zstyle ':completion:*' menu select                        # Enable menu-style completion
# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Homebrew completion
if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
    autoload -Uz compinit
    compinit
fi

# Git completion
if type git &>/dev/null; then
    alias g='git'
    compdef g=git
fi

# SSH completion based on ~/.ssh/config
if [[ -f ~/.ssh/config ]]; then
    zstyle ':completion:*:ssh:*' hosts $(grep '^Host' ~/.ssh/config | grep -v '[?*]' | cut -d ' ' -f2)
fi

# killall completion
compdef '_values "Running Applications" $(ps -u $USER -o comm= | sort -u)' killall
#!/usr/bin/env zsh

### Similar to .zlogin but sourced before .zshrc
### Note: .zprofile & .zshrc skipped in non-login non-interactive shells
### Tip: Declare envars in .zprofile > source in .zshenv > loaded in all shells

# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh"
# Q pre block. Keep at the top of this file.

## add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH"

export ZSH_THEME="powerlevel10k/powerlevel10k"

### brew
eval "$(/opt/homebrew/bin/brew shellenv)"

## load dotfiles
for file in ~/.{zsh_prompt,path,exports,aliases,functions,extra}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

## docs
autoload run-help
HELPDIR=/usr/share/zsh/"${ZSH_VERSION}"/help

# Completion options
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"   # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                        # automatically find new executables in path
zstyle ':completion:*' menu select                        # Enable menu-style completion
# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache


## load completion system
### dir: /opt/homebrew/share/zsh/site-functions

# SSH completion based on ~/.ssh/config
if [[ -f ~/.ssh/config ]]; then
    zstyle ':completion:*:ssh:*' hosts $(grep '^Host' ~/.ssh/config | grep -v '[?*]' | cut -d ' ' -f2)
fi

# Homebrew completion
if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
    autoload -Uz compinit
    compinit
fi

# Git completion
if type git &>/dev/null; then
    alias g='git'
    compdef g=git
fi

# killall completion
# compdef '_values "Running Applications" $(ps -u $USER -o comm= | sort -u)'=killall

# pip zsh completion
# compdef -P pip[0-9.]#
__pip() {
  compadd $( COMP_WORDS="$words[*]" \
             COMP_CWORD=$((CURRENT-1)) \
             PIP_AUTO_COMPLETE=1 $words[1] 2>/dev/null )
}
if [[ $zsh_eval_context[-1] == loadautofunc ]]; then
  # autoload from fpath, call function directly
  __pip "$@"
else
  # eval/source/. command, register function for later
  compdef __pip -P 'pip[0-9.]#'
fi

### Tools

# GNU Make path
PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba shell init' !!
export MAMBA_EXE='/opt/homebrew/opt/micromamba/bin/mamba';
export MAMBA_ROOT_PREFIX='/Users/Sami/.micromamba';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias mamba="$MAMBA_EXE"  # fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<

# pnpm
export PNPM_HOME="/Users/Sami/.pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh"
