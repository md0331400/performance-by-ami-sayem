#!/system/bin/sh
# post-fs-data - early setup
MODDIR=${0%/*}
LOG=/data/adb/sam_performance/boot.log

mkdir -p /data/adb/sam_performance
echo "[$(date)] post-fs-data" > $LOG

# Ensure config files exist
[ ! -f /data/adb/sam_performance/current_mode ] && echo "balance" > /data/adb/sam_performance/current_mode
[ ! -f /data/adb/sam_performance/enabled ] && echo "1" > /data/adb/sam_performance/enabled
[ ! -f /data/adb/sam_performance/max_bg_apps ] && echo "2" > /data/adb/sam_performance/max_bg_apps

chmod 755 $MODDIR/scripts/*.sh 2>/dev/null
