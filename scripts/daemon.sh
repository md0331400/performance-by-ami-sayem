#!/system/bin/sh
##############################################
# SamPerformance - Main Detection Daemon
# Detects: foreground app, screen state
# Switches modes: gaming / balance / battery
# Created by: Ami Sayem
##############################################

MODDIR=/data/adb/modules/sam_performance
CONFIG_DIR=/data/adb/sam_performance
GAMES_LIST=$CONFIG_DIR/games.txt
WHITELIST=$CONFIG_DIR/battery_whitelist.txt
MODE_FILE=$CONFIG_DIR/current_mode
ENABLED_FILE=$CONFIG_DIR/enabled
LOG=$CONFIG_DIR/daemon.log

CURRENT_MODE="balance"
LAST_FG_APP=""
LAST_SCREEN_STATE="on"

log() {
    echo "[$(date '+%H:%M:%S')] $1" >> $LOG
    # keep log small
    [ $(wc -l < $LOG 2>/dev/null || echo 0) -gt 500 ] && tail -200 $LOG > $LOG.tmp && mv $LOG.tmp $LOG
}

get_foreground_app() {
    # Try multiple methods (different Android versions)
    local pkg=""
    pkg=$(dumpsys window 2>/dev/null | grep -E 'mCurrentFocus|mFocusedApp' | head -1 | grep -oE '[a-zA-Z0-9._]+/[a-zA-Z0-9._]+' | cut -d'/' -f1)
    [ -z "$pkg" ] && pkg=$(dumpsys activity activities 2>/dev/null | grep -E 'topResumedActivity|ResumedActivity' | head -1 | grep -oE '[a-zA-Z0-9._]+/[a-zA-Z0-9._]+' | head -1 | cut -d'/' -f1)
    echo "$pkg"
}

is_screen_on() {
    local state=$(dumpsys power 2>/dev/null | grep -E 'mWakefulness=|Display Power: state=' | head -1)
    echo "$state" | grep -qiE 'Awake|state=ON' && echo "on" || echo "off"
}

is_game() {
    local pkg="$1"
    [ -z "$pkg" ] && return 1
    grep -qx "$pkg" "$GAMES_LIST" 2>/dev/null && return 0
    # Also check if app is in "GAME" category (Android 8+)
    dumpsys package "$pkg" 2>/dev/null | grep -qE 'categoryHint=2|FLAG_IS_GAME' && return 0
    return 1
}

switch_mode() {
    local new_mode="$1"
    [ "$new_mode" = "$CURRENT_MODE" ] && return
    log "Switching mode: $CURRENT_MODE -> $new_mode"
    CURRENT_MODE="$new_mode"
    echo "$new_mode" > $MODE_FILE
    sh $MODDIR/scripts/mode_$new_mode.sh "$LAST_FG_APP" >> $LOG 2>&1
}

log "===== Daemon started ====="

# Main loop
while true; do
    # Check if module is enabled
    if [ "$(cat $ENABLED_FILE 2>/dev/null)" != "1" ]; then
        sleep 10
        continue
    fi

    SCREEN=$(is_screen_on)
    FG_APP=$(get_foreground_app)

    # Screen off -> Battery save mode
    if [ "$SCREEN" = "off" ]; then
        switch_mode "battery"
    else
        # Screen on -> check foreground app
        if is_game "$FG_APP"; then
            LAST_FG_APP="$FG_APP"
            switch_mode "gaming"
        else
            # Not in game -> balance mode
            switch_mode "balance"
        fi
    fi

    sleep 5
done
