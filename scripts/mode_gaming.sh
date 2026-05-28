#!/system/bin/sh
##############################################
# UNIVERSAL GAMING MODE
# Works on: Snapdragon/MediaTek/Exynos/Unisoc/Tensor/Kirin
# GPU: Adreno/Mali/PowerVR
# Auto-detects max refresh rate
##############################################

GAME_PKG="$1"
CONFIG_DIR=/data/adb/sam_performance
MAX_BG=$(cat $CONFIG_DIR/max_bg_apps 2>/dev/null || echo 2)

# Load device info
[ -f $CONFIG_DIR/device_info ] && . $CONFIG_DIR/device_info
[ -z "$CHIPSET" ] && CHIPSET="unknown"
[ -z "$GPU" ] && GPU="unknown"
[ -z "$MAX_HZ" ] && MAX_HZ=60

echo ">>> GAMING MODE [$GAME_PKG] | $CHIPSET | $GPU | ${MAX_HZ}Hz"

#######################################
# 1. FORCE MAX REFRESH RATE (UNIVERSAL)
#######################################
# Standard AOSP (works on all)
settings put system peak_refresh_rate ${MAX_HZ}.0 2>/dev/null
settings put system min_refresh_rate ${MAX_HZ}.0 2>/dev/null
settings put secure peak_refresh_rate ${MAX_HZ}.0 2>/dev/null
settings put secure min_refresh_rate ${MAX_HZ}.0 2>/dev/null

# MIUI / HyperOS
settings put system user_refresh_rate $MAX_HZ 2>/dev/null
settings put secure miui_refresh_rate $MAX_HZ 2>/dev/null
settings put global miui_refresh_rate $MAX_HZ 2>/dev/null
settings put secure smart_dfps 0 2>/dev/null
settings put global miui_dynamic_fps 0 2>/dev/null
settings put secure game_booster_enable 0 2>/dev/null
settings put secure adaptive_refresh_rate_disabled 1 2>/dev/null

# One UI (Samsung)
settings put global refresh_rate_mode 1 2>/dev/null
settings put secure refresh_rate_mode 1 2>/dev/null

# ColorOS / OxygenOS / RealmeUI
settings put secure oneplus_screen_refresh_rate 0 2>/dev/null
settings put system oppo_display_refresh_rate $MAX_HZ 2>/dev/null

# Funtouch / OriginOS (Vivo)
settings put secure vivo_screen_refresh_rate $MAX_HZ 2>/dev/null

# Generic system override
settings put system screen_refresh_rate $MAX_HZ 2>/dev/null

# Force via SurfaceFlinger (universal)
service call SurfaceFlinger 1035 i32 0 >/dev/null 2>&1
setprop debug.sf.disable_backpressure 1 2>/dev/null
setprop debug.sf.latch_unsignaled 1 2>/dev/null

# Disable battery saver (caps refresh rate)
settings put global low_power 0 2>/dev/null
cmd power set-mode 0 2>/dev/null

#######################################
# 2. CPU PERFORMANCE (UNIVERSAL)
#######################################
# MediaTek specific power mode
if [ "$CHIPSET" = "mediatek" ]; then
    echo 1 > /proc/cpufreq/cpufreq_power_mode 2>/dev/null
    echo "1" > /proc/perfmgr/boost_ctrl/cpu_ctrl/policy_boot_boost 2>/dev/null
    echo "1" > /sys/module/mtk_fpsgo/parameters/perfmgr_enable 2>/dev/null
fi

# Qualcomm specific
if [ "$CHIPSET" = "qualcomm" ]; then
    # Boost via msm performance
    echo "1" > /sys/module/msm_performance/parameters/touchboost 2>/dev/null
fi

# Universal CPU governor (works for all)
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [ -f "$cpu" ] && echo "performance" > "$cpu" 2>/dev/null
done

# Lock to max frequency
for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
    if [ -d "$cpu" ]; then
        MAX=$(cat $cpu/cpuinfo_max_freq 2>/dev/null)
        [ -n "$MAX" ] && echo "$MAX" > $cpu/scaling_min_freq 2>/dev/null
    fi
done

# Enable all cores
for i in $(seq 0 15); do
    [ -f /sys/devices/system/cpu/cpu$i/online ] && echo 1 > /sys/devices/system/cpu/cpu$i/online 2>/dev/null
done

# Disable CPU idle states for max perf
for state in /sys/devices/system/cpu/cpu*/cpuidle/state*/disable; do
    [ -f "$state" ] && echo "1" > "$state" 2>/dev/null
done

#######################################
# 3. GPU MAX PERFORMANCE (UNIVERSAL)
#######################################

# === Adreno (Qualcomm) ===
if [ "$GPU" = "adreno" ] || [ -d /sys/class/kgsl/kgsl-3d0 ]; then
    for gpu in /sys/class/kgsl/kgsl-3d0; do
        if [ -d "$gpu" ]; then
            echo "performance" > $gpu/devfreq/governor 2>/dev/null
            MAX_GPU=$(cat $gpu/max_gpuclk 2>/dev/null || cat $gpu/devfreq/max_freq 2>/dev/null)
            [ -n "$MAX_GPU" ] && echo "$MAX_GPU" > $gpu/devfreq/min_freq 2>/dev/null
            echo "1" > $gpu/force_clk_on 2>/dev/null
            echo "1" > $gpu/force_bus_on 2>/dev/null
            echo "1" > $gpu/force_rail_on 2>/dev/null
            echo "0" > $gpu/idle_timer 2>/dev/null
        fi
    done
fi

# === Mali (MediaTek / Exynos / Kirin) ===
if [ "$GPU" = "mali" ] || [ -d /proc/gpufreq ] || [ -d /proc/gpufreqv2 ]; then
    # MediaTek GPUFreq v1
    echo 0 > /proc/gpufreq/gpufreq_opp_freq 2>/dev/null
    # MediaTek GPUFreq v2
    MAX_OPP=$(cat /proc/gpufreqv2/gpu_working_opp_table 2>/dev/null | head -1 | awk '{print $4}')
    [ -n "$MAX_OPP" ] && echo $MAX_OPP > /proc/gpufreqv2/fix_target_opp_index 2>/dev/null

    # Mali sysfs (Exynos / generic)
    for mali in /sys/devices/platform/*.mali /sys/devices/platform/mali* /sys/devices/platform/13040000.mali; do
        if [ -d "$mali" ]; then
            echo "always_on" > $mali/power_policy 2>/dev/null
            echo "performance" > $mali/devfreq/governor 2>/dev/null
            MAX=$(cat $mali/devfreq/available_frequencies 2>/dev/null | tr ' ' '\n' | sort -nr | head -1)
            [ -n "$MAX" ] && echo "$MAX" > $mali/devfreq/min_freq 2>/dev/null
        fi
    done

    # Disable GPU DVFS for max
    echo 0 > /proc/mali/dvfs_enable 2>/dev/null
fi

# === PowerVR (older Unisoc) ===
if [ "$GPU" = "powervr" ]; then
    for pvr in /sys/devices/platform/pvrsrvkm /proc/pvr; do
        [ -d "$pvr" ] && echo "performance" > $pvr/governor 2>/dev/null
    done
fi

# Generic devfreq GPU
for gpu in /sys/class/devfreq/*gpu* /sys/class/devfreq/*.gpu; do
    if [ -d "$gpu" ]; then
        echo "performance" > $gpu/governor 2>/dev/null
    fi
done

#######################################
# 4. KILL BACKGROUND APPS
#######################################
RUNNING=$(dumpsys activity processes 2>/dev/null | grep -oE 'ProcessRecord\{[^}]+\}' | grep -oE '[a-zA-Z0-9._]+/[0-9]+' | cut -d'/' -f1 | sort -u)

KEEP=0
for pkg in $RUNNING; do
    case "$pkg" in
        android|com.android.*|com.google.android.gms|com.google.android.gsf|com.google.android.gms.*|*.systemui|*.phone|*.bluetooth|*.nfc|com.mediatek.*|com.qualcomm.*|com.miui.core|com.miui.system|com.miui.securitycore|com.xiaomi.misettings|com.samsung.android.*|com.sec.android.*|com.oppo.*|com.coloros.*|com.vivo.*|com.realme.*|com.heytap.*|com.oneplus.*|com.huawei.*|com.honor.*|me.weishu.*|com.dergoogler.*|io.github.huskydg.magisk|com.topjohnwu.magisk)
            continue ;;
    esac
    [ "$pkg" = "$GAME_PKG" ] && continue
    if [ $KEEP -lt $MAX_BG ]; then
        KEEP=$((KEEP + 1))
        continue
    fi
    am force-stop "$pkg" 2>/dev/null
done

#######################################
# 5. RAM + I/O TWEAKS
#######################################
echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
sync
echo 1 > /proc/sys/net/ipv4/tcp_low_latency 2>/dev/null

# I/O scheduler (best effort for both UFS and eMMC)
for block in /sys/block/sd*/queue/scheduler /sys/block/mmcblk*/queue/scheduler /sys/block/nvme*/queue/scheduler; do
    if [ -f "$block" ]; then
        # Try modern then fallback
        echo "none" > "$block" 2>/dev/null || echo "noop" > "$block" 2>/dev/null
    fi
done

echo ">>> Gaming mode applied (${MAX_HZ}Hz)"

# Send notification
sh /data/adb/modules/sam_performance/scripts/notify.sh gaming "$GAME_PKG" &
