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

function my_last_commits {
  git log -1000 --pretty=format:"%ad | %an | %s | %h" --date=iso |
    grep "Aleksander" |
    while IFS= read -r line; do
      format_commit_line "$line"
    done
}

# Color helpers
green()  { echo -n "\033[32m$1\033[0m"; }
yellow() { echo -n "\033[33m$1\033[0m"; }
cyan()   { echo -n "\033[96m$1\033[0m"; }
gray()   { echo -n "\033[90m$1\033[0m"; }

format_commit_line() {
  local line="$1"
  local URL_BASE="https://bugs.opera.com/browse/"

  local date name message hash
  IFS='|' read -r date name message hash <<< "$line"

  # Clean and isolate ISO date
  date="${date%% *}"  # Remove time
  local yyyy="${date:0:4}"
  local mm="${date:5:2}"
  local dd="${date:8:2}"

  # Convert month number to name
  local month
  case "$mm" in
    "01") month="Jan" ;;
    "02") month="Feb" ;;
    "03") month="Mar" ;;
    "04") month="Apr" ;;
    "05") month="May" ;;
    "06") month="Jun" ;;
    "07") month="Jul" ;;
    "08") month="Aug" ;;
    "09") month="Sep" ;;
    "10") month="Oct" ;;
    "11") month="Nov" ;;
    "12") month="Dec" ;;
  esac

  local formatted_date="$dd $month $yyyy"

  # Trim whitespace from fields
  name="${name#"${name%%[![:space:]]*}"}"
  name="${name%"${name##*[![:space:]]}"}"
  message="${message#"${message%%[![:space:]]*}"}"
  message="${message%"${message##*[![:space:]]}"}"
  hash="${hash#"${hash%%[![:space:]]*}"}"
  hash="${hash%"${hash##*[![:space:]]}"}"

  # Extract issue ID and commit message
  local id=""
  local msg="$message"
  local link=""
  if [[ "$message" =~ ^([A-Z]+\-[0-9]+):[[:space:]]*(.*)$ ]]; then
    id="${match[1]}"
    msg="${match[2]}"
    link=$'\e]8;;'"${URL_BASE}${id}"$'\a'"$(cyan "$id")"$'\e]8;;\a'
  fi

  # Final output
  echo -e "$(gray "==>") $formatted_date $(gray "-") $link: $msg $(gray "-") $(yellow "$hash") "
}

function commit_with_msg() {
  local msg="$1"
  shift
  echo "git commit -m '$(work_package): $msg' $@"
}

alias gfsu='cd chromium/src/ && gaa && git reset --hard && cd ... && gsu'
alias cpwp='echo $(work_package) | tr -d "\n" | pbcopy'
alias gcobn='git checkout -b $(next_branch)'
alias gcop='git checkout $(prev_branch)'
alias gcon='git checkout $(next_branch)'
alias grin='git rebase -i $(latest_nightly_build)'
alias grins='git rebase -i --autosquash $(latest_nightly_build)'

alias glc='my_last_commits'

alias jira='$(echo "open https://bugs.opera.com/browse/$(work_package)")'

function gcobwp() {
  # $1 is the passed task ID
  local task_id="$1"

  # Call your existing function to retrieve current branch name
  local cur_branch
  cur_branch=$(current_branch)  # or however you implement current_branch

  # Check if current branch starts with "desktop-stable" or "gx-stable"
  if [[ "$cur_branch" == desktop-stable* || "$cur_branch" == gx-stable* ]]; then
    git checkout -b "wp/${task_id}/${cur_branch}/1"
  else
    git checkout -b "wp/${task_id}/1"
  fi
}

function gcwp() {
  echo "$(commit_with_msg "$@")" | zsh
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

alias gfast='sudo sysctl kern.maxvnodes=$((512*1024))'
