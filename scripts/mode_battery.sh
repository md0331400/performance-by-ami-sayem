#!/system/bin/sh
##############################################
# UNIVERSAL BATTERY SAVE MODE
##############################################

CONFIG_DIR=/data/adb/sam_performance
WHITELIST=$CONFIG_DIR/battery_whitelist.txt
[ -f $CONFIG_DIR/device_info ] && . $CONFIG_DIR/device_info

echo ">>> BATTERY SAVE MODE"

#######################################
# LOW REFRESH RATE
#######################################
settings put system peak_refresh_rate 60.0 2>/dev/null
settings put system min_refresh_rate 60.0 2>/dev/null
settings put system user_refresh_rate 60 2>/dev/null
settings put secure miui_refresh_rate 60 2>/dev/null
settings put global miui_refresh_rate 60 2>/dev/null
settings put global refresh_rate_mode 0 2>/dev/null

#######################################
# CPU POWERSAVE
#######################################
if [ "$CHIPSET" = "mediatek" ]; then
    echo 2 > /proc/cpufreq/cpufreq_power_mode 2>/dev/null
fi

for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    if [ -f "$cpu" ]; then
        echo "powersave" > "$cpu" 2>/dev/null || \
        echo "conservative" > "$cpu" 2>/dev/null
    fi
done

# Disable big cores (cores with highest max freq)
# Find big cores dynamically
BIG_CORES=$(for i in $(seq 0 15); do
    F=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/cpuinfo_max_freq 2>/dev/null)
    [ -n "$F" ] && echo "$i $F"
done | sort -k2 -n -r | head -2 | awk '{print $1}')

for core in $BIG_CORES; do
    [ -f /sys/devices/system/cpu/cpu$core/online ] && echo 0 > /sys/devices/system/cpu/cpu$core/online 2>/dev/null
done

#######################################
# GPU POWERSAVE
#######################################
# Adreno
for gpu in /sys/class/kgsl/kgsl-3d0; do
    if [ -d "$gpu" ]; then
        echo "powersave" > $gpu/devfreq/governor 2>/dev/null
    fi
done

# Mali
for mali in /sys/devices/platform/*.mali /sys/devices/platform/mali*; do
    if [ -d "$mali" ]; then
        echo "coarse_demand" > $mali/power_policy 2>/dev/null
        echo "powersave" > $mali/devfreq/governor 2>/dev/null
    fi
done

# Generic devfreq
for gpu in /sys/class/devfreq/*gpu*; do
    [ -d "$gpu" ] && echo "powersave" > $gpu/governor 2>/dev/null
done

#######################################
# KILL NON-WHITELISTED APPS
#######################################
ALL_APPS=$(pm list packages -3 2>/dev/null | sed 's/package://g')
for pkg in $ALL_APPS; do
    if grep -qx "$pkg" "$WHITELIST" 2>/dev/null; then
        continue
    fi
    case "$pkg" in
        com.android.*|*.systemui|*.phone|*.bluetooth|*.dialer|*.contacts|com.google.android.gms|com.google.android.gsf|com.mediatek.*|com.qualcomm.*|com.miui.core|com.samsung.android.*|me.weishu.*|com.topjohnwu.magisk)
            continue ;;
    esac
    am force-stop "$pkg" 2>/dev/null
done

#######################################
# DOZE + BATTERY SAVER
#######################################
dumpsys deviceidle enable all 2>/dev/null
dumpsys deviceidle force-idle 2>/dev/null
echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
sync
settings put global low_power 1 2>/dev/null
cmd power set-mode 1 2>/dev/null

echo ">>> Battery save mode applied"

# Notification
sh /data/adb/modules/sam_performance/scripts/notify.sh battery &
