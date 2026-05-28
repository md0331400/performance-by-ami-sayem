#!/system/bin/sh
##############################################
# UNIVERSAL BALANCE MODE
# Restore default behavior across all devices
##############################################

CONFIG_DIR=/data/adb/sam_performance
[ -f $CONFIG_DIR/device_info ] && . $CONFIG_DIR/device_info

echo ">>> BALANCE MODE"

#######################################
# RESTORE REFRESH RATE (let system decide)
#######################################
settings delete system peak_refresh_rate 2>/dev/null
settings delete system min_refresh_rate 2>/dev/null
settings delete secure peak_refresh_rate 2>/dev/null
settings delete secure min_refresh_rate 2>/dev/null

# Re-enable adaptive refresh rate
settings put secure smart_dfps 1 2>/dev/null
settings put global miui_dynamic_fps 1 2>/dev/null
settings put secure adaptive_refresh_rate_disabled 0 2>/dev/null
settings put secure game_booster_enable 1 2>/dev/null

#######################################
# CPU - Back to default
#######################################
if [ "$CHIPSET" = "mediatek" ]; then
    echo 0 > /proc/cpufreq/cpufreq_power_mode 2>/dev/null
fi

# Restore default governor (schedutil is modern default, interactive is older)
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    if [ -f "$cpu" ]; then
        # Try in order of preference
        echo "schedutil" > "$cpu" 2>/dev/null || \
        echo "interactive" > "$cpu" 2>/dev/null || \
        echo "ondemand" > "$cpu" 2>/dev/null
    fi
done

# Reset CPU min freq
for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
    if [ -d "$cpu" ]; then
        MIN=$(cat $cpu/cpuinfo_min_freq 2>/dev/null)
        [ -n "$MIN" ] && echo "$MIN" > $cpu/scaling_min_freq 2>/dev/null
    fi
done

# Re-enable CPU idle
for state in /sys/devices/system/cpu/cpu*/cpuidle/state*/disable; do
    [ -f "$state" ] && echo "0" > "$state" 2>/dev/null
done

#######################################
# GPU - Back to default
#######################################
# Adreno
for gpu in /sys/class/kgsl/kgsl-3d0; do
    if [ -d "$gpu" ]; then
        echo "msm-adreno-tz" > $gpu/devfreq/governor 2>/dev/null
        echo "0" > $gpu/force_clk_on 2>/dev/null
        echo "0" > $gpu/force_bus_on 2>/dev/null
        echo "0" > $gpu/force_rail_on 2>/dev/null
        echo "80" > $gpu/idle_timer 2>/dev/null
    fi
done

# Mali / MediaTek
echo -1 > /proc/gpufreq/gpufreq_opp_freq 2>/dev/null
echo -1 > /proc/gpufreqv2/fix_target_opp_index 2>/dev/null
for mali in /sys/devices/platform/*.mali /sys/devices/platform/mali*; do
    if [ -d "$mali" ]; then
        echo "coarse_demand" > $mali/power_policy 2>/dev/null
        echo "simple_ondemand" > $mali/devfreq/governor 2>/dev/null
    fi
done
echo 1 > /proc/mali/dvfs_enable 2>/dev/null

# Generic devfreq
for gpu in /sys/class/devfreq/*gpu* /sys/class/devfreq/*.gpu; do
    if [ -d "$gpu" ]; then
        echo "simple_ondemand" > $gpu/governor 2>/dev/null
    fi
done

# Reset I/O scheduler
for block in /sys/block/sd*/queue/scheduler /sys/block/mmcblk*/queue/scheduler; do
    if [ -f "$block" ]; then
        echo "cfq" > "$block" 2>/dev/null || \
        echo "bfq" > "$block" 2>/dev/null || \
        echo "mq-deadline" > "$block" 2>/dev/null
    fi
done

echo ">>> Balance mode applied"

# Notification
sh /data/adb/modules/sam_performance/scripts/notify.sh balance &
