function work_package() {
 echo $(echo $(current_branch) | cut -d'/' -f 2)
}

function prev_branch() {
  ordinal=$(echo $(current_branch) | cut -d'/' -f 3)
  echo 'wp/'$(work_package)'/'$(($ordinal - 1))
}

function next_branch() {
  ordinal=$(echo $(current_branch) | cut -d'/' -f 3)
  echo 'wp/'$(work_package)'/'$(($ordinal + 1))
}

function latest_nightly_build() {
  echo $(git log origin/master -50 --pretty=format:"%s○%H" | grep 'buildbot: update nightly version number' | cut -d'○' -f 2 | head -1)
}

function latest_wp_branch() {
  echo $(git branch -a | grep $1 | grep -v remotes | tail -r | head -1)
}

function commit_with_msg() {
  echo "git commit -m '$(work_package): $1'"
}

alias gcobn='git checkout -b $(next_branch)'
alias gcop='git checkout $(prev_branch)'
alias gcon='git checkout $(next_branch)'
alias grin='git rebase -i $(latest_nightly_build)'
alias grins='git rebase -i --autosquash $(latest_nightly_build)'

function gcwp() {
  echo $(commit_with_msg $1) | zsh
}

function gcobwp() {
  echo "git checkout -b 'wp/$1/1'" | zsh
}

function gcowp() {
  local branch=$(latest_wp_branch $1)
  if ! [ -z $branch ]
  then
    echo "git checkout $branch" | zsh
  else
    echo "No branch found"
  fi
}
