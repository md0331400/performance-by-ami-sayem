#!/system/bin/sh
# SamPerformance - main service
# Created by: Ami Sayem

MODDIR=${0%/*}
CONFIG_DIR=/data/adb/sam_performance
LOG=$CONFIG_DIR/service.log

until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 5
done
sleep 30

mkdir -p $CONFIG_DIR
echo "[$(date)] Service started" > $LOG

# UNIVERSAL: Detect hardware first (always re-detect on boot)
sh $MODDIR/scripts/detect.sh >> $LOG 2>&1

# Welcome notification
sleep 2
sh $MODDIR/scripts/notify.sh boot "Module loaded - device detected" &

# Start the main daemon
nohup sh $MODDIR/scripts/daemon.sh >> $LOG 2>&1 &
echo $! > $CONFIG_DIR/daemon.pid

echo "[$(date)] Daemon PID: $(cat $CONFIG_DIR/daemon.pid)" >> $LOG
