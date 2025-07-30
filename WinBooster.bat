@echo off
title ⚡ Windows 11 - Network Boost & Privacy Optimization
color 0A

echo ====[ 🔐 Checking administrator privileges ]====
net session >nul 2>&1 || (
  echo This script must be run as administrator.
  pause
  exit /b
)

:: ----------------------------
:: 🔧 NETWORK OPTIMIZATION (TCP/IP)
:: ----------------------------
echo ====[ ⚙️ TCP/IP Network Optimization ]====

netsh interface tcp set global autotuninglevel=normal
netsh interface tcp set heuristics disabled
netsh interface tcp set global ecncapability=enabled
netsh interface tcp set global rss=enabled
netsh interface tcp set global dca=enabled

:: Set TCP congestion algorithm to CTCP (good for high-speed networks)
netsh interface tcp set supplemental internet congestionprovider=ctcp

:: Disable Nagle's Algorithm & Delayed ACK for each network interface
for /f "tokens=2 delims={}" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"') do (
  reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{%%i}" /v TcpAckFrequency /t REG_DWORD /d 1 /f
  reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{%%i}" /v TCPNoDelay /t REG_DWORD /d 1 /f
)

:: Force fast public DNS (Cloudflare + Google fallback)
netsh interface ip set dns name="Ethernet" static 1.1.1.1
netsh interface ip add dns name="Ethernet" 8.8.8.8 index=2

:: Flush DNS cache
ipconfig /flushdns

:: Disable Delivery Optimization (peer-to-peer updates)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v DODownloadMode /t REG_DWORD /d 0 /f

:: ----------------------------
:: 🚫 PRIVACY & TELEMETRY REDUCTION
:: ----------------------------
echo ====[ 🔒 Privacy – Disabling Telemetry ]====

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v ShowedToastAtFirstLogon /t REG_DWORD /d 1 /f

sc stop DiagTrack
sc config DiagTrack start= disabled
sc stop dmwappushservice
sc config dmwappushservice start= disabled

:: ----------------------------
:: 🗑️ REMOVE UNNEEDED SERVICES & UWP APPS
:: ----------------------------
echo ====[ 🧹 Disabling unneeded services & removing default apps ]====

for %%s in (
  SysMain WSearch Fax WMPNetworkSvc RemoteRegistry XboxGipSvc XboxNetApiSvc MapsBroker
) do (
  sc stop %%s 2>nul
  sc config %%s start= disabled
)

for %%p in (
  Microsoft.3DBuilder Microsoft.XboxApp Microsoft.XboxGameOverlay
  Microsoft.XboxGamingOverlay Microsoft.BingNews Microsoft.GetHelp
  Microsoft.Getstarted Microsoft.MixedReality.Portal Microsoft.SkypeApp
  Microsoft.WindowsAlarms Microsoft.WindowsFeedbackHub Microsoft.WindowsMaps
  Microsoft.WindowsSoundRecorder Microsoft.YourPhone
) do (
  powershell -Command "Get-AppxPackage -Name %%p | Remove-AppxPackage -ErrorAction SilentlyContinue"
  powershell -Command "Get-AppxProvisionedPackage -Online | Where Name -EQ '%%p' | Remove-AppxProvisionedPackage -Online"
)

:: ----------------------------
:: ⚙️ SYSTEM PERFORMANCE SETTINGS
:: ----------------------------
echo ====[ 🚀 System performance tuning ]====

reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Desktop" /v ForegroundLockTimeout /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f

:: Enable Ultimate Performance Power Plan
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61

:: Disable Cortana and web search integration
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f

:: Clean temporary files
del /q /f "%TEMP%\*" >nul 2>&1
del /q /f "C:\Windows\Temp\*" >nul 2>&1

:: Disable PowerShell telemetry
setx POWERSHELL_TELEMETRY_OPTOUT 1 /m

echo.
echo ✅ Network and system performance boost applied. Reboot recommended.
pause
