# Changelog

All notable changes to SamPerformance will be documented here.

## [v1.1.0] - 2026-05-28

### Added
- 🌍 **Universal hardware detection** — auto-detects Qualcomm, MediaTek, Exynos, Unisoc, Tensor, Kirin
- 🎨 **GPU auto-detection** — Adreno, Mali, PowerVR all supported
- 📺 **Refresh rate auto-detection** — works on 60/90/120/144/165Hz displays
- 🔔 **Smart notifications** with mode + active game info
- 📱 **App-like WebUI** for MMRL with live stats
- 🎮 **50+ pre-loaded popular games** (Free Fire, PUBG, COD, Genshin, MLBB, etc.)
- 🔧 **Dynamic big core detection** for battery mode
- 📊 **Built-in diagnostic tool** (`scripts/diagnose.sh`)
- 🏷️ **Multi-ROM support** — MIUI, HyperOS, OneUI, ColorOS, Funtouch, RealmeUI, Pixel, AOSP

### Fixed
- ❌ MIUI/HyperOS 60Hz cap (smart_dfps now disabled)
- ❌ Root notification blocking (now runs as UID 2000)
- ❌ Wrong GPU paths on MediaTek devices

## [v1.0.0] - 2026-05-28

### Initial Release
- 🎮 Gaming mode (max FPS, BG app killing)
- ⚖️ Balance mode (default behavior)
- 🔋 Battery mode (screen off detection)
- 🎯 Auto mode switching daemon
