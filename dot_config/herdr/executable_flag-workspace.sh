#!/bin/sh
# Toggle a "come back to this" flag on the active workspace's sidebar row.
# The flag is the $flag workspace token shown in [ui.sidebar.spaces] rows.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:${PATH:-}"
H="${HERDR_BIN_PATH:-herdr}"
ws="${HERDR_ACTIVE_WORKSPACE_ID:?run from a herdr keybinding}"

flag=$("$H" workspace get "$ws" | jq -r '.result.workspace.tokens.flag // empty')
if [ -n "$flag" ]; then
  exec "$H" workspace report-metadata "$ws" --source jesse.flag --clear-token flag >/dev/null
fi
exec "$H" workspace report-metadata "$ws" --source jesse.flag --token flag=⚑ >/dev/null
