#!/system/bin/sh
##############################################
# Universal Notification helper
# Works on: AOSP, MIUI/HyperOS, OneUI, ColorOS, Funtouch, etc.
##############################################

MODE="$1"
EXTRA="$2"
CONFIG_DIR=/data/adb/sam_performance
LOG=$CONFIG_DIR/notify.log

# Load device info for refresh rate
[ -f $CONFIG_DIR/device_info ] && . $CONFIG_DIR/device_info
[ -z "$MAX_HZ" ] && MAX_HZ="?"

case "$MODE" in
    gaming)
        TITLE="🎮 Gaming Mode ON  ${MAX_HZ}Hz"
        MSG="Max FPS • Background apps killed"
        [ -n "$EXTRA" ] && MSG="Playing: $EXTRA at ${MAX_HZ}Hz"
        ;;
    balance)
        TITLE="⚖️ Balance Mode"
        MSG="Default phone behavior"
        ;;
    battery)
        TITLE="🔋 Battery Save Mode"
        MSG="Background apps restricted • 60Hz"
        ;;
    *)
        TITLE="⚡ SamPerformance"
        MSG="$EXTRA"
        ;;
esac

echo "[$(date)] $TITLE - $MSG" >> $LOG

# Try multiple methods in order of compatibility
SUCCESS=0

# Method 1: Run as shell user (UID 2000) - best for MIUI/HyperOS
R1=$(su -lp 2000 -c "cmd notification post -S bigtext -t '$TITLE' SamPerf '$MSG'" 2>&1)
[ -z "$R1" ] || echo "$R1" | grep -qi "posted" && SUCCESS=1

# Method 2: Direct root (works on AOSP, Pixel, OneUI)
if [ $SUCCESS -eq 0 ]; then
    R2=$(cmd notification post -S bigtext -t "$TITLE" "SamPerf" "$MSG" 2>&1)
    [ -z "$R2" ] || echo "$R2" | grep -qi "posted" && SUCCESS=1
fi

# Method 3: Alternative shell context
if [ $SUCCESS -eq 0 ]; then
    su -c "su shell -c \"cmd notification post -S bigtext -t '$TITLE' SamPerf '$MSG'\"" 2>/dev/null
fi

# Keep log small
[ "$(wc -l < $LOG 2>/dev/null)" -gt 100 ] && tail -50 $LOG > ${LOG}.t && mv ${LOG}.t $LOG

exit 0
