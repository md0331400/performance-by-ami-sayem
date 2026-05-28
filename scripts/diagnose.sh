#!/system/bin/sh
##############################################
# Diagnostic tool
# Run in terminal: sh /data/adb/modules/sam_performance/scripts/diagnose.sh
##############################################

echo "================================================"
echo "  SamPerformance - Diagnostic Report"
echo "================================================"
echo ""
echo "Device: $(getprop ro.product.model)"
echo "ROM: $(getprop ro.build.display.id)"
echo "Android: $(getprop ro.build.version.release)"
echo "MIUI: $(getprop ro.miui.ui.version.name)"
echo ""

echo "===== REFRESH RATE INFO ====="
echo "Available rates from display:"
dumpsys display 2>/dev/null | grep -oE '[0-9]+\.[0-9]+ fps' | sort -u
echo ""
echo "Current peak_refresh_rate: $(settings get system peak_refresh_rate 2>/dev/null)"
echo "Current min_refresh_rate: $(settings get system min_refresh_rate 2>/dev/null)"
echo "MIUI user_refresh_rate: $(settings get system user_refresh_rate 2>/dev/null)"
echo "MIUI smart_dfps: $(settings get secure smart_dfps 2>/dev/null)"
echo ""

echo "===== TESTING NOTIFICATION ====="
echo "Trying notification methods..."
echo ""

echo "[Test 1] Direct as root:"
cmd notification post -t "Test 1" "test1" "Root notification test" 2>&1
echo ""

echo "[Test 2] As shell user (UID 2000):"
su 2000 -c "cmd notification post -t 'Test 2' 'test2' 'Shell user test'" 2>&1
echo ""

echo "[Test 3] Via am broadcast:"
am broadcast -a android.intent.action.SHOW_TOAST --es msg "Test 3" 2>&1
echo ""

echo "===== Permission check ====="
ls -lZ /data/adb/modules/sam_performance/scripts/notify.sh 2>/dev/null
echo ""

echo "===== Current mode ====="
cat /data/adb/sam_performance/current_mode 2>/dev/null
echo ""

echo "===== Daemon status ====="
PID=$(cat /data/adb/sam_performance/daemon.pid 2>/dev/null)
if [ -n "$PID" ] && [ -d /proc/$PID ]; then
    echo "Daemon RUNNING (PID: $PID)"
else
    echo "Daemon NOT running!"
fi
echo ""

echo "===== Foreground app detection test ====="
dumpsys window 2>/dev/null | grep -E 'mCurrentFocus' | head -1
echo ""

echo "================================================"
echo "Send this output to Ami Sayem if issue persists"
echo "================================================"
