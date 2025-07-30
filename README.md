# WinBooster
Boost Windows 11 speed &amp; privacy

# ⚡ Network Boost for Windows 11

This script is a complete system and network optimizer for Windows 11. It focuses on:

- ⚙️ **Network performance** (faster DNS, reduced latency, increased throughput)
- 🔐 **Privacy & telemetry reduction**
- 🧹 **Removal of unnecessary services and apps**
- 🚀 **System performance tuning**

> 🛑 WARNING: This script is aggressive. Run it only on personal systems or non-critical environments. Some features like Xbox integration, Cortana, and certain background services will be disabled.

---

## ✅ Features

### 🔧 Network Optimizations
- Enables TCP AutoTuning
- Disables Windows TCP heuristics
- Enables ECN (Explicit Congestion Notification)
- Enables RSS (Receive-Side Scaling) and DCA
- Sets congestion control algorithm to `CTCP`
- Disables Nagle's Algorithm (via registry)
- Sets fast DNS (Cloudflare + Google)
- Flushes DNS cache
- Disables Delivery Optimization (P2P Windows updates)

### 🔒 Privacy & Telemetry
- Disables Microsoft Telemetry & Data Collection
- Disables DiagTrack and dmwappushservice
- Blocks Cortana and Web Search
- Disables PowerShell telemetry reporting

### 🗑️ Bloatware Removal
- Removes dozens of built-in UWP apps
- Disables low-priority services like `Fax`, `RemoteRegistry`, `WSearch`, `MapsBroker`, etc.

### ⚙️ System Tuning
- Enables Ultimate Performance power plan
- Reduces menu delay and UI animations
- Cleans temporary files

---

## 🧪 How to Use

1. Save the file as `network-boost.bat`
2. Right-click > Run as Administrator
3. Wait for the script to finish
4. Reboot your system to apply changes

---

## 🌀 Rollback / Undo

This version does not include a rollback script. To restore changes:
- Use a system restore point before applying
- Or ask for a `rollback.bat` version to reverse all actions

---

## 📘 License

MIT – Use freely, at your own risk.

---
