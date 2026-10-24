#!/bin/bash
# Claude Code statusline with powerline style and git status
# Uses nerd fonts and ANSI colors for rainbow effect

# Keep process spawns to a minimum (one jq, one git, one date): every spawn
# is slow under endpoint security, and the herdr-agent-usage wrapper blanks
# the status line when this script runs longer than 2 seconds.

# Validate JSON and extract all fields in one pass, one field per line:
# cwd, directory name, model, context percentage
# - model could be string or object with .id field
# - clean up model name: remove claude- prefix and date suffix, truncate
if ! fields=$(jq -er '
  (.workspace.current_dir // "") as $cwd
  | $cwd,
    ($cwd | if test("^/+$") then "/" else sub("/+$"; "") | split("/") | last // "" end),
    (if .model | type == "object" then .model.id // .model.name // "claude"
     elif .model | type == "string" then .model
     else "claude"
     end
     | if . == "" or . == "null" then "claude" else . end
     | sub("claude-"; "") | sub("-[0-9]*$"; "") | .[0:10]),
    (.context_window.used_percentage | if . == null or . == false then "" else tojson end)
' 2>/dev/null); then
    echo "⚠ invalid input"
    exit 0
fi
{ IFS= read -r cwd; IFS= read -r dir_name; IFS= read -r model; IFS= read -r pct; } <<< "$fields"

# ANSI color codes (using $'...' for proper escape handling)
RESET=$'\033[0m'
BG_BLUE=$'\033[44m'
FG_BLUE=$'\033[34m'
BG_GREEN=$'\033[42m'
FG_GREEN=$'\033[32m'
BG_YELLOW=$'\033[43m'
FG_YELLOW=$'\033[33m'
BG_CYAN=$'\033[46m'
FG_CYAN=$'\033[36m'
BG_RED=$'\033[41m'
FG_RED=$'\033[31m'
BG_ORANGE=$'\033[48;5;208m'
FG_ORANGE=$'\033[38;5;208m'
BG_MAGENTA=$'\033[45m'
FG_MAGENTA=$'\033[35m'
FG_BLACK=$'\033[30m'
FG_WHITE=$'\033[97m'
BOLD=$'\033[1m'
BLINK=$'\033[5m'

# Powerline separator and icons
SEP=""
BRANCH_ICON=""
FOLDER_ICON=""

# Git info
git_segment=""
model_bg=$BG_MAGENTA
model_fg=$FG_MAGENTA
# Untracked files are skipped: scanning for them takes seconds in large repos
# because GIT_OPTIONAL_LOCKS=0 (Claude Code env) stops git saving its cache.
if status=$(git -C "$cwd" status --porcelain=v2 --branch --show-stash --untracked-files=no 2>/dev/null); then
    # One status call gives branch, ahead/behind, stashes, and file entries
    branch=""
    ahead=0 behind=0 stashes=0
    staged=0 modified=0 conflicted=0
    while IFS= read -r line; do
        case "$line" in
            "# branch.head "*) branch=${line#"# branch.head "} ;;
            "# branch.ab "*)
                ab=${line#"# branch.ab +"}
                ahead=${ab%% -*}
                behind=${ab##* -}
                ;;
            "# stash "*) stashes=${line#"# stash "} ;;
            [12u]" "*)
                xy=${line:2:2}
                case "$xy" in [MADRC]?) staged=$((staged + 1)) ;; esac
                case "$xy" in ?[MD]) modified=$((modified + 1)) ;; esac
                case "$xy" in [UDA][UDA]) conflicted=$((conflicted + 1)) ;; esac
                ;;
        esac
    done <<< "$status"
    [ "$branch" = "(detached)" ] && branch=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

    # Build compact git status (p10k style)
    git_status=""
    [ "$ahead" -gt 0 ] 2>/dev/null && git_status+="⇡$ahead"
    [ "$behind" -gt 0 ] 2>/dev/null && git_status+="⇣$behind"
    [ "$stashes" -gt 0 ] 2>/dev/null && git_status+="*$stashes"
    [ "$conflicted" -gt 0 ] && git_status+="~$conflicted"
    [ "$staged" -gt 0 ] && git_status+="+$staged"
    [ "$modified" -gt 0 ] && git_status+="!$modified"

    # Choose git segment color based on repo state (like p10k)
    if [ -n "$git_status" ]; then
        git_bg=$BG_YELLOW
        git_fg=$FG_YELLOW
        git_content=" ${BRANCH_ICON} $branch $git_status "
    else
        git_bg=$BG_GREEN
        git_fg=$FG_GREEN
        git_content=" ${BRANCH_ICON} $branch "
    fi
    git_segment="${FG_BLUE}${git_bg}${SEP}${FG_BLACK}${git_content}"
    next_fg=$git_fg
    next_bg=$BG_CYAN
else
    next_fg=$FG_BLUE
    next_bg=$BG_CYAN
fi

# Context progress bar (uses built-in used_percentage from Claude Code 2.1.6+)
context_segment=""
if [ -n "$pct" ] && [ "$pct" != "null" ] && [ "$pct" -ge 0 ] 2>/dev/null; then
    # Build progress bar (10 chars wide)
    bar_width=10
    filled=$((pct * bar_width / 100))
    [ "$filled" -gt "$bar_width" ] && filled=$bar_width
    empty=$((bar_width - filled))

    # Colors for filled portion based on level
    if [ "$pct" -gt 95 ]; then
        fill_color=$'\033[38;5;196m'  # bright red
        bar_blink=$BLINK
    elif [ "$pct" -gt 85 ]; then
        fill_color=$'\033[38;5;208m'  # orange
        bar_blink=""
    elif [ "$pct" -gt 70 ]; then
        fill_color=$'\033[38;5;220m'  # yellow
        bar_blink=""
    else
        fill_color=$'\033[38;5;29m'   # forest green
        bar_blink=""
    fi
    empty_color=$'\033[38;5;240m'     # dark gray

    # Build the bar string
    filled_bar=""
    empty_bar=""
    for ((i=0; i<filled; i++)); do filled_bar+="█"; done
    for ((i=0; i<empty; i++)); do empty_bar+="░"; done

    # Segment with dark background
    BG_DARK=$'\033[48;5;236m'
    FG_DARK=$'\033[38;5;236m'
    context_segment="${next_fg}${BG_DARK}${SEP}${bar_blink}${fill_color}${filled_bar}${RESET}${BG_DARK}${empty_color}${empty_bar}${FG_WHITE} ${pct}%${RESET}"
    next_fg=$FG_DARK
fi

# Fallback if no context data
if [ -z "$context_segment" ]; then
    BG_DARK=$'\033[48;5;236m'
    FG_DARK=$'\033[38;5;236m'
    context_segment="${next_fg}${BG_DARK}${SEP}${FG_WHITE} --%${RESET}"
    next_fg=$FG_DARK
fi

# Date and time
current_datetime=$(date +"%Y/%m/%d %H:%M")

# Build output with powerline style
echo -n "${model_bg}${FG_WHITE}${BOLD} 󰚩 $model ${RESET}"
echo -n "${model_fg}${BG_BLUE}${SEP}${FG_WHITE} ${FOLDER_ICON} $dir_name ${RESET}"
echo -n "$git_segment"
echo -n "$context_segment"
echo -n "${next_fg}${RESET}${SEP} ${current_datetime}"
