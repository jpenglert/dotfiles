#!/bin/sh
# Toggle reviewr in its own tab and switch to that tab when the toggle opens it.
# reviewr's tab placement opens the tab without switching to it, so focus it here.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:${PATH:-}"
H="${HERDR_BIN_PATH:-herdr}"
ws="${HERDR_ACTIVE_WORKSPACE_ID:?run from a herdr keybinding}"

reviewr_tab() {
  "$H" tab list | jq -r --arg ws "$ws" \
    'first(.result.tabs[] | select(.workspace_id == $ws and .label == "reviewr") | .tab_id) // empty'
}

# An existing reviewr tab means this toggle closes it, so there is nothing to focus.
opening=1
[ -n "$(reviewr_tab)" ] && opening=0

"$H" plugin action invoke toggle --plugin persiyanov.reviewr >/dev/null || exit 1
[ "$opening" -eq 1 ] || exit 0

# The action runs asynchronously; wait for its tab to appear and be labeled.
i=0
while [ "$i" -lt 50 ]; do
  tab=$(reviewr_tab)
  if [ -n "$tab" ]; then
    exec "$H" tab focus "$tab" >/dev/null
  fi
  sleep 0.1
  i=$((i + 1))
done
