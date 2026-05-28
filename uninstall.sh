#!/system/bin/sh
# Cleanup on uninstall
CONFIG_DIR=/data/adb/sam_performance

# Kill daemon
if [ -f $CONFIG_DIR/daemon.pid ]; then
    kill -9 $(cat $CONFIG_DIR/daemon.pid) 2>/dev/null
fi

# Reset settings to default
settings delete system peak_refresh_rate 2>/dev/null
settings delete system min_refresh_rate 2>/dev/null
settings put global low_power 0 2>/dev/null
settings put global show_fps_overlay 0 2>/dev/null

# Reset CPU
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [ -f "$cpu" ] && echo "schedutil" > "$cpu" 2>/dev/null
done

# Remove config (keep user lists optionally)
# rm -rf $CONFIG_DIR
