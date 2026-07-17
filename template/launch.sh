
# Prevent multiple instances from being able to run
LOCKFILE="$OOD_STAGED_ROOT/igv.lock"
if [ -f "$LOCKFILE" ] && kill -0 "$(cat "$LOCKFILE")" 2>/dev/null; then
  exit 0
fi

# Command to launch app
module load igv
igv.sh > $OOD_STAGED_ROOT/igv.log 2>&1 &

echo $! > "$LOCKFILE"

# Wait for the app window to appear, then maximize it
(
  for i in $(seq 1 40); do
    # Check for window with app name
    WIN_ID=$(wmctrl -l | awk 'tolower($0) ~ /igv/ {print $1; exit}')
    if [ -n "$WIN_ID" ]; then
      wmctrl -i -r "$WIN_ID" -b add,fullscreen
      break
    fi
    sleep 0.5
  done
) &