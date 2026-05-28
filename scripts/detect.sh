#!/system/bin/sh
##############################################
# Universal Hardware Detection
# Detects: chipset, GPU type, max refresh rate, OS variant
# Saves to: /data/adb/sam_performance/device_info
##############################################

CONFIG_DIR=/data/adb/sam_performance
INFO=$CONFIG_DIR/device_info

#######################################
# CHIPSET DETECTION
#######################################
CHIPSET="unknown"
HW=$(getprop ro.hardware)$(getprop ro.board.platform)$(getprop ro.product.board)$(getprop ro.soc.manufacturer)

# Qualcomm Snapdragon
if echo "$HW" | grep -qiE "qcom|qualcomm|msm|sdm|sm[0-9]|kona|lahaina|taro|pineapple"; then
    CHIPSET="qualcomm"
# MediaTek
elif echo "$HW" | grep -qiE "mt[0-9]|mediatek|mtk|dimensity|helio"; then
    CHIPSET="mediatek"
# Samsung Exynos
elif echo "$HW" | grep -qiE "exynos|universal|samsung"; then
    CHIPSET="exynos"
# Unisoc / Spreadtrum
elif echo "$HW" | grep -qiE "unisoc|spreadtrum|sc[0-9]|ums[0-9]|tiger"; then
    CHIPSET="unisoc"
# Google Tensor
elif echo "$HW" | grep -qiE "tensor|gs[0-9]+"; then
    CHIPSET="tensor"
# Kirin (HiSilicon)
elif echo "$HW" | grep -qiE "kirin|hisilicon|hi[0-9]"; then
    CHIPSET="kirin"
fi

#######################################
# GPU DETECTION
#######################################
GPU="unknown"
GPU_RENDERER=$(dumpsys SurfaceFlinger 2>/dev/null | grep -i "GLES" | head -1)

if [ -d /sys/class/kgsl/kgsl-3d0 ]; then
    GPU="adreno"
elif [ -d /proc/gpufreq ] || [ -d /proc/gpufreqv2 ] || ls /sys/devices/platform/*.mali 2>/dev/null | grep -q .; then
    GPU="mali"
elif [ -d /sys/class/devfreq/gpufreq ]; then
    GPU="mali"
elif echo "$GPU_RENDERER" | grep -qi "adreno"; then
    GPU="adreno"
elif echo "$GPU_RENDERER" | grep -qi "mali"; then
    GPU="mali"
elif echo "$GPU_RENDERER" | grep -qi "powervr"; then
    GPU="powervr"
fi

#######################################
# MAX REFRESH RATE DETECTION
#######################################
MAX_HZ=$(dumpsys display 2>/dev/null | grep -oE '[0-9]+\.[0-9]+ fps' | grep -oE '^[0-9]+' | sort -nr | head -1)
[ -z "$MAX_HZ" ] && MAX_HZ=$(dumpsys SurfaceFlinger 2>/dev/null | grep -oE '[0-9]+\.[0-9]+ Hz' | grep -oE '^[0-9]+' | sort -nr | head -1)
[ -z "$MAX_HZ" ] && MAX_HZ=$(dumpsys display 2>/dev/null | grep -oE 'fps=[0-9]+' | grep -oE '[0-9]+' | sort -nr | head -1)
[ -z "$MAX_HZ" ] && MAX_HZ=60

#######################################
# OS / ROM DETECTION
#######################################
ROM="aosp"
if [ -n "$(getprop ro.miui.ui.version.name)" ] || [ -n "$(getprop ro.mi.os.version.name)" ]; then
    ROM="miui_hyperos"
elif [ -n "$(getprop ro.build.version.oneui)" ] || getprop ro.build.PDA | grep -q "."; then
    ROM="oneui"
elif [ -n "$(getprop ro.build.version.oplusrom)" ] || [ -n "$(getprop ro.build.version.opporom)" ]; then
    ROM="coloros"
elif [ -n "$(getprop ro.vivo.os.name)" ] || [ -n "$(getprop ro.vivo.os.version)" ]; then
    ROM="funtouch"
elif [ -n "$(getprop ro.build.version.realmeui)" ]; then
    ROM="realmeui"
elif getprop ro.build.host | grep -qi "pixel"; then
    ROM="pixel"
fi

#######################################
# BIG CORE DETECTION (for tri-cluster)
#######################################
TOTAL_CORES=$(nproc 2>/dev/null || grep -c processor /proc/cpuinfo)
BIG_CORES=""
PRIME_CORE=""
for i in $(seq 0 $((TOTAL_CORES - 1))); do
    MAX=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/cpuinfo_max_freq 2>/dev/null)
    echo "$i:$MAX"
done | sort -t: -k2 -n -r > /tmp/cpu_freqs 2>/dev/null

#######################################
# SAVE DETECTED INFO
#######################################
mkdir -p $CONFIG_DIR
cat > $INFO <<EOF
DEVICE=$(getprop ro.product.model)
BRAND=$(getprop ro.product.brand)
CHIPSET=$CHIPSET
GPU=$GPU
MAX_HZ=$MAX_HZ
ROM=$ROM
TOTAL_CORES=$TOTAL_CORES
ANDROID_VER=$(getprop ro.build.version.release)
SDK=$(getprop ro.build.version.sdk)
DETECTED_AT=$(date)
EOF

echo "Device detection complete:"
cat $INFO
