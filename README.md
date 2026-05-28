<div align="center">

# ⚡ SamPerformance

### Smart Gaming & Battery Optimizer for Android

**Universal Magisk / KernelSU / APatch Module**

[![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](https://github.com/YOUR_USERNAME/SamPerformance/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Magisk](https://img.shields.io/badge/Magisk-20.4%2B-orange.svg)](https://github.com/topjohnwu/Magisk)
[![KernelSU](https://img.shields.io/badge/KernelSU-supported-purple.svg)](https://kernelsu.org/)
[![Android](https://img.shields.io/badge/Android-7.0%2B-brightgreen.svg)](https://www.android.com/)

*Auto-switches between Gaming, Balance, and Battery modes based on what you're doing.*

[**📥 Download**](#-installation) • [**🎮 Features**](#-features) • [**🔧 Configuration**](#%EF%B8%8F-configuration) • [**🐛 Troubleshooting**](#-troubleshooting)

</div>

---

## 🎯 What is SamPerformance?

SamPerformance is a **smart, fully automatic** Android performance manager that runs as a root module. It watches what you're doing and switches your phone between three modes — no manual toggling needed.

- 🎮 **Open a game?** → Maximum FPS, kills background apps
- ⚖️ **Browsing normally?** → Default phone behavior
- 🔋 **Screen off / locked?** → Battery saver, kills drainers

---

## ✨ Features

### 🎮 Gaming Mode (auto-activates when a game opens)
- ✅ Forces **maximum supported refresh rate** (60/90/120/144/165Hz)
- ✅ CPU governor → `performance` (max clocks)
- ✅ GPU forced to max performance (Adreno / Mali / PowerVR)
- ✅ Kills all background apps **except the game + 2 user apps**
- ✅ Clears RAM cache
- ✅ Disables CPU idle states for zero latency
- ✅ Bypasses MIUI/HyperOS smart DFPS that caps to 60Hz
- ✅ Disables thermal throttling (briefly, use with care)

### ⚖️ Balance Mode (default state)
- ✅ All settings reset to phone defaults
- ✅ Adaptive refresh rate restored
- ✅ Schedutil/interactive CPU governor
- ✅ Re-enables battery optimizations

### 🔋 Battery Save Mode (auto when screen off / locked)
- ✅ Refresh rate → 60Hz
- ✅ CPU → `powersave` governor
- ✅ **Disables big cores** (only little cores stay active)
- ✅ Kills all apps **except whitelisted** social/messaging apps
- ✅ Forces aggressive Doze mode
- ✅ Enables Android battery saver

### 🔔 Smart Notifications
Mode changes show as system notifications — you'll always know what mode is active.

### 📱 App-like UI (via [MMRL](https://github.com/MMRLApp/MMRL))
A beautiful WebUI with live mode display, quick switches, and stats.

<div align="center">
  <img src="screenshots/webui.jpg" alt="WebUI" width="300"/>
</div>

---

## 🌍 Universal Compatibility

Auto-detects your hardware and applies the correct optimizations:

| Brand | Chipset | GPU | Tested |
|-------|---------|-----|--------|
| Xiaomi / Redmi / Poco | Snapdragon / MediaTek | Adreno / Mali | ✅ |
| Samsung Galaxy | Snapdragon / Exynos | Adreno / Mali | ✅ |
| OnePlus / Realme / Oppo | Snapdragon / MediaTek | Adreno / Mali | ✅ |
| Vivo / iQOO | Snapdragon / MediaTek | Adreno / Mali | ✅ |
| Google Pixel | Tensor | Mali | ✅ |
| Motorola / Nokia / Asus | Snapdragon / MediaTek | Adreno / Mali | ✅ |
| Huawei / Honor (old) | HiSilicon Kirin | Mali | ✅ |
| Infinix / Tecno / Itel | Unisoc / MediaTek | Mali / PowerVR | ✅ |

**Supported ROMs:** MIUI, HyperOS, OneUI, ColorOS, Funtouch, OriginOS, RealmeUI, OxygenOS, Pixel, LineageOS, AOSP

---

## 📥 Installation

### Requirements
- Rooted Android 7.0+ (API 24+)
- One of: **Magisk 20.4+** / **KernelSU** / **APatch**

### Steps
1. **Download** [`SamPerformance.zip`](https://github.com/YOUR_USERNAME/SamPerformance/releases/latest) from Releases
2. Open **Magisk Manager** (or KernelSU / APatch)
3. Go to **Modules → Install from storage**
4. Select the downloaded zip
5. **Reboot** your phone
6. Done! The module starts working automatically.

### Optional: Install MMRL for App-like UI
Get [MMRL](https://github.com/MMRLApp/MMRL) from Play Store / GitHub. It will detect SamPerformance and show the beautiful WebUI.

---

## ⚙️ Configuration

All config files live at `/data/adb/sam_performance/` (use a root file manager):

| File | Purpose |
|------|---------|
| `games.txt` | Game package names (one per line) — 50+ games pre-loaded |
| `battery_whitelist.txt` | Apps allowed to run in battery mode |
| `max_bg_apps` | How many bg apps to keep in game mode (default: `2`) |
| `enabled` | `1` = active, `0` = disabled |
| `current_mode` | Currently active mode |
| `device_info` | Auto-detected hardware info |

### Adding More Games
Open `/data/adb/sam_performance/games.txt` and add the package name:
```
com.example.yourgame
```
Save → module picks it up immediately (no reboot needed).

### Find a Package Name
- Use [App Inspector](https://play.google.com/store/apps/details?id=com.ghosty.appinfo) from Play Store
- Or: `pm list packages | grep gamename` in terminal

---

## ⚠️ Important Setup (for MIUI / HyperOS users)

If you're on Xiaomi/Redmi, do these manually for best results:

1. **Settings → Display → Refresh rate** → Set to **Custom** or **High** (not "Default"!)
2. **Settings → Battery** → Battery Saver: **OFF**
3. **Settings → Special features → Game Turbo** → For your game, choose **"Performance mode"**
4. **Settings → Apps → Manage apps → KernelSU/Magisk** → Battery saver: **No restrictions**

These are MIUI-level caps that even root can't override; you must change them manually once.

---

## 🐛 Troubleshooting

### Module not switching modes?
Run the diagnostic in a root terminal:
```bash
sh /data/adb/modules/sam_performance/scripts/diagnose.sh
```
Share the output in [Issues](https://github.com/YOUR_USERNAME/SamPerformance/issues).

### Notifications not showing?
- MIUI/HyperOS: Settings → Notifications → System UI → **Allow all**
- Some ROMs block root notifications entirely — that's a ROM limitation, not the module.

### FPS still capped at 60?
- Check **Display → Refresh rate** in system settings is set to high
- Disable battery saver
- For MIUI: Disable "Smart DFPS" if available

### Logs to check
```
/data/adb/sam_performance/daemon.log    ← Main detection
/data/adb/sam_performance/service.log   ← Boot service
/data/adb/sam_performance/notify.log    ← Notifications
/data/adb/sam_performance/device_info   ← Detected hardware
```

---

## ❌ Limitations (Honest Disclosure)

- **In-game FPS overlay**: Magisk can't draw on top of games. Use apps like *Scene 5*, *GameBench*, or your ROM's built-in Game Mode for that.
- **Per-game graphics control**: This module does system-wide GPU boost only. Use *GFX Tool* type apps for individual game graphics tweaking.
- **Some ROMs override settings**: HyperOS, OneUI, ColorOS have system-level managers that may re-cap refresh rate. Always check your ROM's display settings.
- **Thermal**: Performance mode disables some thermal limits temporarily. Don't game for hours on a hot phone.

---

## 🛠️ How It Works (Tech Stack)

- **Pure shell scripts** — no compiled binaries, fully auditable
- **Hardware detection** via `getprop`, `/proc/`, `/sys/`
- **Foreground app detection** via `dumpsys window`
- **Mode switching** via direct kernel sysfs writes + `settings put`
- **Daemon loop** polls every 5 seconds (configurable)
- **Notifications** via `cmd notification post` as shell user (UID 2000)
- **WebUI** — single HTML file with KSU/MMRL exec bridge

---

## 📂 Project Structure

```
SamPerformance/
├── META-INF/                      # Magisk installer scripts
├── module.prop                    # Module metadata
├── customize.sh                   # Install-time setup
├── post-fs-data.sh                # Early boot
├── service.sh                     # Late boot - starts daemon
├── action.sh                      # Magisk "Run Action" button
├── uninstall.sh                   # Cleanup
├── scripts/
│   ├── daemon.sh                  # Main detection loop
│   ├── detect.sh                  # Hardware auto-detection
│   ├── mode_gaming.sh             # Gaming mode logic
│   ├── mode_balance.sh            # Balance mode logic
│   ├── mode_battery.sh            # Battery mode logic
│   ├── notify.sh                  # Notification sender
│   └── diagnose.sh                # User-runnable diagnostic
├── webroot/
│   └── index.html                 # MMRL WebUI
└── README.md
```

---

## 🤝 Contributing

Pull requests welcome! If you find optimizations for a specific chipset or ROM, please share:

1. Fork the repo
2. Create a branch (`git checkout -b feature/your-feature`)
3. Commit your changes
4. Push and open a PR

### Adding a Chipset
Edit `scripts/detect.sh` and `scripts/mode_gaming.sh` — add your detection pattern and corresponding sysfs paths.

---

## 📜 License

MIT License — see [LICENSE](LICENSE) for details. Free to use, modify, redistribute.

---

## 👨‍💻 Credits

**Created by [Ami Sayem](https://github.com/YOUR_USERNAME)**

Special thanks to:
- [Magisk](https://github.com/topjohnwu/Magisk) — topjohnwu
- [KernelSU](https://github.com/tiann/KernelSU) — tiann
- [MMRL](https://github.com/MMRLApp/MMRL) — for WebUI support

---

<div align="center">

**⭐ If this helped you, please star the repo!**

Made with ♥ for the Android root community

[Report Bug](https://github.com/YOUR_USERNAME/SamPerformance/issues) • [Request Feature](https://github.com/YOUR_USERNAME/SamPerformance/issues) • [Releases](https://github.com/YOUR_USERNAME/SamPerformance/releases)

</div>
