# Windows 11 Ultra Optimizer

**Ultimate interactive batch script to optimize your Windows 11 system for maximum performance, privacy, and cleanliness.**

---

## Description

Windows 11 Ultra Optimizer is a powerful, modular batch script designed to fine-tune your system by applying advanced tweaks in networking, CPU, GPU, SSD, privacy, system cleaning, and more.

It offers a fully interactive menu allowing you to selectively enable or disable each optimization module before applying changes, making it suitable both for casual users and power users.

---

## Features

* **Interactive menu with toggles:** Enable or disable each optimization module individually.
* **Select All / Basic Optimization:** Quickly select all tweaks or just essential/basic ones.
* **Network tweaks:** Improve TCP/IP stack, reduce latency, optimize DNS, and disable peer-to-peer updates.
* **CPU tweaks:** Disable CPU throttling, enable max performance power plan, disable core parking.
* **GPU tweaks:** Enable hardware accelerated GPU scheduling and gaming-related optimizations.
* **SSD optimizations:** Enable TRIM, disable Superfetch and Prefetch to enhance SSD responsiveness.
* **Telemetry and diagnostics:** Disable Windows telemetry, diagnostics tracking, and related services.
* **UWP app cleanup:** Remove unwanted built-in apps like Xbox, 3D Builder, and more.
* **Disable unnecessary services:** Stop and disable background services like SysMain, Fax, Xbox services.
* **Remove Cortana, OneDrive, Bing integration:** Disable and uninstall common bloat features.
* **Advanced system cleaning:** Delete temporary files, Windows Update caches, and logs.
* **Ad and tracker blocking:** Add common ad and telemetry domains to the hosts file to block them.

---

## How to Use

1. **Run as Administrator:** Right-click the batch file and choose “Run as Administrator”. This is mandatory for the script to work properly.
2. **Menu navigation:**

   * Enter the **number** of the option to toggle it ON or OFF (shows `[X]` or `[ ]`).
   * Press **A** to select all optimizations.
   * Press **B** to select only the basic optimizations (network, CPU, GPU, SSD, cleaning).
   * Press **R** to reset all selections (uncheck all).
   * Press **S** to start applying the selected optimizations.
   * Press **Q** to quit without making changes.
3. After the script finishes running, **restart your computer** to ensure all changes take effect.
4. A detailed log of all changes is saved as `optimizer_log.txt` in the same folder as the script.

---

## Important Notes

* **Create a system restore point** before running the script. Some tweaks are aggressive and may affect system behavior.
* This script was tested on Windows 11 (22H2 and later). Compatibility with earlier versions or Windows 10 is not guaranteed.
* Some optimizations disable features you might use (Xbox services, Cortana, etc.). You can skip those modules by toggling them off.
* Running without Administrator rights will abort the script.

---

## Module Overview

| Option Number | Module Name                  | Description                                            |
| ------------- | ---------------------------- | ------------------------------------------------------ |
| 1             | Network Optimization         | Optimize TCP/IP, DNS, disable Delivery Optimization    |
| 2             | CPU Optimization             | Disable CPU throttling, core parking, enable max power |
| 3             | GPU Optimization             | Enable hardware GPU scheduling and gaming tweaks       |
| 4             | SSD Optimization             | Enable TRIM, disable Superfetch & Prefetch             |
| 5             | Telemetry Reduction          | Disable telemetry and diagnostic tracking              |
| 6             | UWP App Cleanup              | Remove unwanted preinstalled UWP apps                  |
| 7             | Disable Unnecessary Services | Stop & disable non-essential Windows services          |
| 8             | Remove Cortana/OneDrive/Bing | Disable Cortana, uninstall OneDrive, block Bing search |
| 9             | Advanced System Cleaning     | Delete temp files, Windows Update caches               |
| 10            | Ad/Tracker Host Blocking     | Block common ad and telemetry domains in hosts file    |

