#!/sbin/sh
##########################################################################
# SamPerformance - Universal Magisk Module
# Created by: Ami Sayem
##########################################################################

SKIPUNZIP=0

ui_print " "
ui_print "*****************************************"
ui_print "       SAMPERFORMANCE  v1.1.0"
ui_print "         Created by: Ami Sayem"
ui_print "         Universal Edition"
ui_print "*****************************************"
ui_print " "

# Extract files
unzip -o "$ZIPFILE" 'scripts/*' -d "$MODPATH" >&2
unzip -o "$ZIPFILE" 'webroot/*' -d "$MODPATH" >&2

ui_print "- Detecting your device..."

#######################################
# Live hardware detection during install
#######################################
DEVICE=$(getprop ro.product.model)
BRAND=$(getprop ro.product.brand)
HW=$(getprop ro.hardware)$(getprop ro.board.platform)

CHIPSET="Unknown"
echo "$HW" | grep -qiE "qcom|qualcomm|msm|sdm|sm[0-9]" && CHIPSET="Qualcomm Snapdragon"
echo "$HW" | grep -qiE "mt[0-9]|mediatek|mtk" && CHIPSET="MediaTek"
echo "$HW" | grep -qiE "exynos|universal" && CHIPSET="Samsung Exynos"
echo "$HW" | grep -qiE "unisoc|spreadtrum" && CHIPSET="Unisoc"
echo "$HW" | grep -qiE "tensor" && CHIPSET="Google Tensor"
echo "$HW" | grep -qiE "kirin" && CHIPSET="HiSilicon Kirin"

GPU="Unknown"
[ -d /sys/class/kgsl/kgsl-3d0 ] && GPU="Adreno"
[ -d /proc/gpufreq ] && GPU="Mali (MediaTek)"
[ -d /proc/gpufreqv2 ] && GPU="Mali (MediaTek v2)"
ls /sys/devices/platform/*.mali 2>/dev/null | grep -q . && GPU="Mali"

MAX_HZ=$(dumpsys display 2>/dev/null | grep -oE '[0-9]+\.[0-9]+ fps' | grep -oE '^[0-9]+' | sort -nr | head -1)
[ -z "$MAX_HZ" ] && MAX_HZ="60 (default)"

ui_print "  Device:  $BRAND $DEVICE"
ui_print "  Chipset: $CHIPSET"
ui_print "  GPU:     $GPU"
ui_print "  Display: ${MAX_HZ}Hz"
ui_print "  Android: $(getprop ro.build.version.release)"
ui_print " "

ui_print "- Setting permissions..."
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive "$MODPATH/scripts" 0 0 0755 0755
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/action.sh" 0 0 0755

# Create config
mkdir -p /data/adb/sam_performance
echo "balance" > /data/adb/sam_performance/current_mode
echo "1" > /data/adb/sam_performance/enabled
echo "2" > /data/adb/sam_performance/max_bg_apps

# Battery whitelist (universal social apps)
cat > /data/adb/sam_performance/battery_whitelist.txt <<EOF
com.facebook.katana
com.facebook.orca
com.facebook.lite
com.whatsapp
com.whatsapp.w4b
com.instagram.android
com.instagram.lite
com.zhiliaoapp.musically
com.ss.android.ugc.trill
org.telegram.messenger
org.telegram.plus
com.discord
com.snapchat.android
com.twitter.android
com.google.android.gm
com.google.android.apps.messaging
com.android.systemui
com.android.phone
com.android.bluetooth
EOF

# Games list (50+ popular games worldwide)
cat > /data/adb/sam_performance/games.txt <<EOF
com.dts.freefireth
com.dts.freefiremax
com.tencent.ig
com.pubg.imobile
com.pubg.krmobile
com.pubg.newstate
com.rekoo.pubgm
com.vng.pubgmobile
com.activision.callofduty.shooter
com.garena.game.codm
com.garena.game.kgth
com.mobile.legends
com.miHoYo.GenshinImpact
com.miHoYo.bh3.global
com.HoYoverse.hkrpgoversea
com.HoYoverse.Nap
com.epicgames.fortnite
com.epicgames.portal
com.supercell.clashofclans
com.supercell.clashroyale
com.supercell.brawlstars
com.king.candycrushsaga
com.king.candycrushsodasaga
com.ea.gp.fifamobile
com.ea.gp.apexlegendsmobilefps
com.gameloft.android.ANMP.GloftA9HM
com.netease.lztgglobal
com.netease.idv.googleplay
com.roblox.client
com.mojang.minecraftpe
com.innersloth.spacemafia
com.riotgames.league.wildrift
com.riotgames.league.teamfighttactics
com.nintendo.zaaa
com.nintendo.zara
com.mihoyo.hyperion
com.tencent.tmgp.cod
com.tencent.tmgp.pubgmhd
com.tencent.tmgp.sgame
com.tencent.tmgp.speedmobile
com.activision.tonyhawk
com.gamedevltd.modernstrike
com.feralinteractive.tropico
com.handygames.airattack2
com.imangi.templerun2
com.kiloo.subwaysurf
com.gameloft.android.ANMP.GloftPOHM
com.dreamsky.gameworld
com.aiming.mlbb
EOF

chmod 755 /data/adb/sam_performance
chmod 644 /data/adb/sam_performance/*.txt /data/adb/sam_performance/current_mode /data/adb/sam_performance/enabled /data/adb/sam_performance/max_bg_apps

ui_print "- Config created at: /data/adb/sam_performance/"
ui_print " "
ui_print "- Features:"
ui_print "  [GAMING]  Auto-on when game opens"
ui_print "  [BALANCE] Default phone behavior"
ui_print "  [BATTERY] When screen off / locked"
ui_print " "
ui_print "- Universal support:"
ui_print "  • Snapdragon / MediaTek / Exynos / Unisoc / Tensor"
ui_print "  • Adreno / Mali / PowerVR GPUs"
ui_print "  • MIUI / HyperOS / OneUI / ColorOS / Pixel / AOSP"
ui_print " "
ui_print "- Optional: Install MMRL for app-like UI"
ui_print " "
ui_print "*** REBOOT REQUIRED ***"
ui_print " "
