@echo off
title ⚡ Windows 11 - Network & Privacy Premium Boost
color 0C

:: ====== Vérification Admin ======
net session >nul 2>&1 || (
  echo [ERREUR] Exécutez ce script en tant qu'administrateur.
  pause
  exit /b
)

echo.
echo ====[ 🌐 Optimisation Réseau Avancée ]====
netsh interface tcp set global autotuninglevel=normal
netsh interface tcp set heuristics disabled
netsh interface tcp set global ecncapability=enabled
netsh interface tcp set global rss=enabled
netsh interface tcp set global dca=enabled
netsh interface tcp set supplemental internet congestionprovider=ctcp

:: Désactive Nagle sur toutes interfaces
for /f "tokens=2 delims={}" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"') do (
  reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{%%i}" /v TcpAckFrequency /t REG_DWORD /d 1 /f
  reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{%%i}" /v TCPNoDelay /t REG_DWORD /d 1 /f
)

:: DNS rapides
set "IFACE=Ethernet"
netsh interface ip set dns name="%IFACE%" static 1.1.1.1 >nul 2>&1
netsh interface ip add dns name="%IFACE%" 8.8.8.8 index=2 >nul 2>&1
ipconfig /flushdns

:: Désactive Delivery Optimization
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v DODownloadMode /t REG_DWORD /d 0 /f >nul

echo.
echo ====[ 🔒 Télémetrie & Services ]====
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul
sc stop DiagTrack >nul 2>&1
sc config DiagTrack start= disabled >nul
sc stop dmwappushservice >nul 2>&1
sc config dmwappushservice start= disabled >nul

:: Services inutiles
for %%s in (SysMain WSearch Fax WMPNetworkSvc RemoteRegistry XboxGipSvc XboxNetApiSvc MapsBroker) do (
  sc stop %%s 2>nul
  sc config %%s start= disabled >nul
)

:: Suppression Apps par défaut
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

echo.
echo ====[ 🚀 Performance Max ]====
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f >nul
reg add "HKCU\Control Panel\Desktop" /v ForegroundLockTimeout /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61 >nul

:: Désactive Cortana
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f >nul

:: Nettoyage
del /q /f "%TEMP%\*" >nul 2>&1
del /q /f "C:\Windows\Temp\*" >nul 2>&1
setx POWERSHELL_TELEMETRY_OPTOUT 1 /m >nul

echo.
echo ✅ Optimisations Premium appliquées. Redémarrage recommandé.
pause
