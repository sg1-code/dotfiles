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
setopt hist_verify           # show command with history expansion to user before running it
setopt inc_append_history    # add commands to HISTFILE in order of execution
setopt share_history         # share command history data

# Zsh options equivalent to bash shopt settings
setopt no_case_glob         # Case insensitive globbing
setopt auto_cd             # Auto cd into directory by just typing its name
setopt extended_glob       # Extended globbing. Allows using regular expressions with *

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
