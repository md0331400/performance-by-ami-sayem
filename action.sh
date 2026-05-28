#!/system/bin/sh
# Action button in Magisk Manager - toggle module on/off
CONFIG_DIR=/data/adb/sam_performance
ENABLED_FILE=$CONFIG_DIR/enabled
MODDIR=/data/adb/modules/sam_performance

CURRENT=$(cat $ENABLED_FILE 2>/dev/null || echo 1)
if [ "$CURRENT" = "1" ]; then
    echo "0" > $ENABLED_FILE
    echo "SamPerformance: DISABLED"
    cmd notification post -t "⏸️ SamPerformance" "want_perf" "Module disabled" 2>/dev/null
    sh $MODDIR/scripts/mode_balance.sh
else
    echo "1" > $ENABLED_FILE
    echo "SamPerformance: ENABLED"
    cmd notification post -t "▶️ SamPerformance" "want_perf" "Module enabled - auto-detecting..." 2>/dev/null
fi
