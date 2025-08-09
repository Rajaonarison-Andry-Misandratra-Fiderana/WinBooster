@echo off
title ⚡ Windows 11 - Network Boost & Privacy Light
color 0A

:: ====== Vérification Admin ======
net session >nul 2>&1 || (
  echo [ERREUR] Exécutez ce script en tant qu'administrateur.
  pause
  exit /b
)

echo.
echo ====[ 🌐 Optimisation Réseau Légère ]====
netsh interface tcp set global autotuninglevel=normal
netsh interface tcp set heuristics disabled
netsh interface tcp set global rss=enabled

:: DNS Cloudflare + Google
set "IFACE=Ethernet"
netsh interface ip set dns name="%IFACE%" static 1.1.1.1 >nul 2>&1
netsh interface ip add dns name="%IFACE%" 8.8.8.8 index=2 >nul 2>&1
ipconfig /flushdns

echo.
echo ====[ 🔒 Réduction Télémetrie ]====
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul
sc stop DiagTrack >nul 2>&1
sc config DiagTrack start= disabled >nul

echo.
echo ====[ 🚀 Performance Légère ]====
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f >nul
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61 >nul

echo.
echo ✅ Optimisations légères appliquées.
pause
