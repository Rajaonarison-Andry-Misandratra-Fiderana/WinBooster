@echo off
title ⚡ Win11Booster Aggressive - Max Performance & Privacy
color 0A

echo ====[ 🔐 Checking admin rights ]====
net session >nul 2>&1 || (
  echo Please run this script as Administrator.
  pause
  exit /b
)

:: ----------------------------
:: 🔧 NETWORK OPTIMIZATIONS
:: Enable TCP autotuning, disable heuristics,
:: enable ECN, RSS, DCA,
:: set congestion provider to CTCP.
:: Disable Nagle's algorithm & delayed ACK.
:: Set DNS to Cloudflare and Google.
:: Flush DNS cache.
:: Disable Delivery Optimization.
:: ----------------------------
echo ====[ ⚙️ Network Optimizations ]====

netsh interface tcp set global autotuninglevel=normal
netsh interface tcp set heuristics disabled
netsh interface tcp set global ecncapability=enabled
netsh interface tcp set global rss=enabled
netsh interface tcp set global dca=enabled
netsh interface tcp set supplemental internet congestionprovider=ctcp

for /f "tokens=2 delims={}" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"') do (
  reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{%%i}" /v TcpAckFrequency /t REG_DWORD /d 1 /f
  reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{%%i}" /v TCPNoDelay /t REG_DWORD /d 1 /f
)

netsh interface ip set dns name="Ethernet" static 1.1.1.1
netsh interface ip add dns name="Ethernet" 8.8.8.8 index=2
ipconfig /flushdns

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v DODownloadMode /t REG_DWORD /d 0 /f

:: ----------------------------
:: 🚫 AGGRESSIVE PRIVACY & TELEMETRY REMOVAL
:: Disable telemetry, diagnostics, and tracking services.
:: ----------------------------
echo ====[ 🔒 Aggressive Privacy & Telemetry Removal ]====

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v ShowedToastAtFirstLogon /t REG_DWORD /d 1 /f

sc stop DiagTrack
sc config DiagTrack start= disabled
sc stop dmwappushservice
sc config dmwappushservice start= disabled

sc stop WSearch
sc config WSearch start= disabled

sc stop "Connected Devices Platform Service"
sc config "Connected Devices Platform Service" start= disabled

sc stop "Retail Demo Service"
sc config "Retail Demo Service" start= disabled

:: ----------------------------
:: 🚫 DISABLE ADS & START MENU SUGGESTIONS
:: Disable Advertising ID, Start Menu ads, tips, lock screen suggestions,
:: Windows tips, and notifications.
:: ----------------------------
echo ====[ 🚫 Disable Ads and Start Menu Suggestions ]====

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338388Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SilentInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v RotatingLockScreenEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v RotatingLockScreenOverlayEnabled /t REG_DWORD /d 0 /f

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v ToastEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v NOC_GLOBAL_SETTING_TOASTS_ENABLED /t REG_DWORD /d 0 /f

:: ----------------------------
:: 🗑️ REMOVE BLOATWARE & SERVICES
:: Stop & disable unnecessary services.
:: Remove built-in UWP apps.
:: ----------------------------
echo ====[ 🧹 Aggressive removal of services and apps ]====

for %%s in (
  SysMain Fax WMPNetworkSvc RemoteRegistry XboxGipSvc XboxNetApiSvc MapsBroker
  XboxApp MicrosoftEdgeUpdateSvc DiagTrack dmwappushservice
  RetailDemo WSearch "Connected Devices Platform Service"
) do (
  sc stop %%s 2>nul
  sc config %%s start= disabled
)

for %%p in (
  Microsoft.3DBuilder Microsoft.XboxApp Microsoft.XboxGameOverlay
  Microsoft.XboxGamingOverlay Microsoft.BingNews Microsoft.GetHelp
  Microsoft.Getstarted Microsoft.MixedReality.Portal Microsoft.SkypeApp
  Microsoft.WindowsAlarms Microsoft.WindowsFeedbackHub Microsoft.WindowsMaps
  Microsoft.WindowsSoundRecorder Microsoft.YourPhone Microsoft.MicrosoftEdge
) do (
  powershell -Command "Get-AppxPackage -Name %%p | Remove-AppxPackage -ErrorAction SilentlyContinue"
  powershell -Command "Get-AppxProvisionedPackage -Online | Where Name -EQ '%%p' | Remove-AppxProvisionedPackage -Online"
)

:: ----------------------------
:: ⚙️ SYSTEM TWEAKS FOR MAX PERFORMANCE
:: Reduce UI delays, disable animations.
:: Enable Ultimate Performance power plan.
:: Disable Cortana & web search integration.
:: Clean temp files.
:: Disable PowerShell telemetry.
:: ----------------------------
echo ====[ 🚀 System tweaks for max speed ]====

reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Desktop" /v ForegroundLockTimeout /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f

powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f

del /q /f "%TEMP%\*" >nul 2>&1
del /q /f "C:\Windows\Temp\*" >nul 2>&1

setx POWERSHELL_TELEMETRY_OPTOUT 1 /m

echo.
echo ✅ Aggressive boost complete. Please reboot your PC.
pause
