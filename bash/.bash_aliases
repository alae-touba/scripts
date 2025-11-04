# Docker shortcuts
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs -f'
alias dcu='docker compose up -d'
alias dcd='docker compose down'


# Git shortcuts
alias gs='git status'
alias gpush='git push'
alias gpull='git pull'
alias gd='git diff'
alias gb='git branch'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias glog='git log --oneline --graph --decorate'


# Maven shortcuts
alias mc='mvn clean'
alias mci='mvn clean install'
alias mcis='mvn clean install -DskipTests'
alias mcp='mvn clean package'
alias mcv='mvn clean verify'
alias mct='mvn clean test'
alias mrun='mvn spring-boot:run'
alias mtree='mvn dependency:tree'

# system
alias update='sudo apt update && sudo apt upgrade -y'
alias h='history'
alias reload='source ~/.bashrc'
alias c='clear'
alias timestamp='date +%Y-%m-%dT%H-%M-%S'
alias hg='history | grep'

# files & Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ls='eza --group-directories-first'
alias ll='eza -l -h --header --git --group-directories-first'
alias la='eza -la -h --header --git --group-directories-first'
alias tree='eza --tree'
alias tree2='eza --tree --level=2'
alias tree3='eza --tree --level=3'
alias cat='batcat'

# personal & work
alias work='cd ~/work'
alias github='cd ~/work/github'
alias scripts='cd ~/work/github/scripts'
alias dev='cd ~/work/dev'
alias dai='cd ~/work/dev/DAI'
alias cash='cd ~/work/dev/cash'
alias dev-env='cd ~/work/dev/dev-env'

