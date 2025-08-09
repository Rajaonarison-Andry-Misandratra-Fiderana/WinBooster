@echo off
title ⚡ Windows 11 - Optimizer (Batch interactif)
color 0A
setlocal enabledelayedexpansion

:: -------------------------
:: Pré-check: admin
:: -------------------------
net session >nul 2>&1 || (
  echo [ERREUR] Ce script doit etre lance en tant qu'administrateur.
  pause
  exit /b
)

:: -------------------------
:: Variables & defaults
:: -------------------------
set "BASEDIR=%~dp0"
set "BACKUPDIR=%BASEDIR%backup"
if not exist "%BACKUPDIR%" md "%BACKUPDIR%"

:: Modules toggles 0=off 1=on
for /l %%i in (1,1,10) do set "M%%i=0"

:: Module list (FR)
set "MOD1=Optimisation reseau (TCP, DNS, Nagle off)"
set "MOD2=Optimisation CPU (power throttling, IRQ, core schedule)"
set "MOD3=Optimisation GPU (HW scheduling, DirectX prefs)"
set "MOD4=Optimisation SSD (TRIM, Prefetch/Superfetch off)"
set "MOD5=Reduction telemetrie (DiagTrack, DataCollection)"
set "MOD6=Suppression Appx UWP inutiles"
set "MOD7=Desactivation services inutiles"
set "MOD8=Suppr Cortana / OneDrive / Bing Search"
set "MOD9=Nettoyage (temp, SoftwareDistribution, logs)"
set "MOD10=Blocage tracking via HOSTS (liste de base)"

:: -------------------------
:: Helpers
:: -------------------------
:pause_and_return
  echo.
  pause
  goto :menu

:: Detecte l'interface reseau active (nom)
:get_iface
  set "IFACE="
  for /f "tokens=1,2,* skip=3" %%a in ('netsh interface show interface') do (
    rem lignes: Admin State   State    Type     Interface Name
    if /i "%%a"=="Enabled" (
      set "IFACE=%%c"
      goto :got_iface
    )
  )
:got_iface
  if "%IFACE%"=="" set "IFACE=Ethernet"
  exit /b

:: -------------------------
:: Sauvegarde des parametres (DNS + TCP globals)
:: -------------------------
:backup_settings
  call :get_iface
  echo -> Sauvegarde parametres dans "%BACKUPDIR%"
  rem save DNS
  (echo :: DNS backup for interface "%IFACE%")>"%BACKUPDIR%\dns_backup.txt"
  netsh interface ip show dns name="%IFACE%" >> "%BACKUPDIR%\dns_backup.txt" 2>&1
  rem save netsh tcp global
  netsh interface tcp show global > "%BACKUPDIR%\tcp_global_backup.txt" 2>&1
  rem create rollback script header
  (
    echo @echo off
    echo rem Rollback script generated %date% %time%
    echo setlocal enabledelayedexpansion
  ) > "%BACKUPDIR%\rollback_restore.bat"
  rem generate DNS restore commands (try to parse IPv4 addresses)
  for /f "tokens:*" %%L in ('type "%BACKUPDIR%\dns_backup.txt" ^| findstr /R /C:"Statically configured DNS Servers" /C:"DNS Servers configured through DHCP" /C:"DNS servers configured"') do (
    rem we simply append a note; parsing is messy - user may edit script
    echo rem DNS info: %%L >> "%BACKUPDIR%\rollback_restore.bat"
  )
  echo rem NOTE: rollback tries to restore TCP globals where possible >> "%BACKUPDIR%\rollback_restore.bat"
  echo echo Restauration partielle : verifiez "%BACKUPDIR%" pour details. >> "%BACKUPDIR%\rollback_restore.bat"
  echo pause >> "%BACKUPDIR%\rollback_restore.bat"
  echo Backup complete.
  exit /b

:: -------------------------
:: Rollback basic (DNS & tcp) - tente de restaurer en lisant backup (best-effort)
:: -------------------------
:do_rollback
  if not exist "%BACKUPDIR%\dns_backup.txt" (
    echo Aucun backup trouve (%BACKUPDIR%\dns_backup.txt manquant).
    pause
    goto :menu
  )
  echo Tentative de restauration (effort limite: DNS & TCP globals)...
  call :get_iface
  rem Attempt: read lines that look like IPv4 and set them back
  set "dnsservers="
  for /f "delims=" %%L in ('type "%BACKUPDIR%\dns_backup.txt"') do (
    for /f "tokens=1" %%a in ("%%L") do (
      rem simple IPv4 pattern check: contain a dot and digits
      echo %%a | findstr /R "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+" >nul 2>&1
      if not errorlevel 1 (
        if "!dnsservers!"=="" (set "dnsservers=%%a") else (set "dnsservers=!dnsservers!,%%a")
      )
    )
  )
  if defined dnsservers (
    rem set first as static, add the rest
    for /f "tokens=1 delims=," %%A in ("!dnsservers!") do (
      netsh interface ip set dns name="%IFACE%" static %%A >nul 2>&1
      rem add rest
      for %%B in (!dnsservers!) do (
        if "%%B"=="%%A" ( ) else netsh interface ip add dns name="%IFACE%" %%B index=2 >nul 2>&1
      )
    )
    echo DNS restores attempted for interface "%IFACE%".
  ) else (
    echo Aucun serveur DNS identifie dans le backup.
  )

  rem Attempt to restore some TCP settings (best-effort parsing)
  if exist "%BACKUPDIR%\tcp_global_backup.txt" (
    for /f "delims=" %%L in ('type "%BACKUPDIR%\tcp_global_backup.txt"') do (
      rem ex: "Receive Window Auto-Tuning Level : normal"
      echo %%L | findstr /R /C:"Auto-Tuning Level" >nul 2>&1
      if not errorlevel 1 (
        for /f "tokens=6" %%v in ("%%L") do (
          netsh interface tcp set global autotuninglevel=%%v >nul 2>&1
        )
      )
      echo %%L | findstr /R /C:"ECN Capability" >nul 2>&1
      if not errorlevel 1 (
        for /f "tokens=3" %%v in ("%%L") do (
          if /i "%%v"=="enabled" (netsh interface tcp set global ecncapability=enabled >nul 2>&1) else (netsh interface tcp set global ecncapability=disabled >nul 2>&1)
        )
      )
    )
    echo Tentative restauration TCP globals terminee.
  )
  echo Rollback termine (vérifications manuelles recommandées).
  pause
  goto :menu

:: -------------------------
:: Menu principal
:: -------------------------
:menu
  cls
  echo ================================================
  echo   ⚡ Windows 11 - Optimizer (Batch interactif)
  echo ================================================
  echo Modules disponibles (tape le numero pour cocher/decocher) :
  echo.
  for /l %%i in (1,1,10) do (
    call :show_mod %%i
  )
  echo.
  echo [a] Select all    [n] None    [b] Backup settings    [r] Rollback (attempt)    [0] Lancer optimisation    [q] Quitter
  echo.
  set /p "CHOIX=> "
  if /i "%CHOIX%"=="q" exit /b
  if /i "%CHOIX%"=="a" (
    for /l %%i in (1,1,10) do set "M%%i=1"
    goto menu
  )
  if /i "%CHOIX%"=="n" (
    for /l %%i in (1,1,10) do set "M%%i=0"
    goto menu
  )
  if /i "%CHOIX%"=="b" (
    call :backup_settings
    pause
    goto menu
  )
  if /i "%CHOIX%"=="r" (
    call :do_rollback
    goto menu
  )
  if "%CHOIX%"=="0" goto :execute_selected
  rem toggle individual
  for /f "tokens=1" %%c in ("%CHOIX%") do set "IDX=%%c"
  for /f "delims=0123456789" %%x in ("%IDX%") do set "IDX=%%x"
  rem verify number 1-10
  echo %IDX% | findstr /R "^[1-9]$" >nul 2>&1
  if errorlevel 1 (
    echo %IDX% | findstr /R "^10$" >nul 2>&1
    if errorlevel 1 goto menu
  )
  if defined IDX (
    if "!M%IDX%!"=="1" (set "M%IDX%=0") else (set "M%IDX%=1")
  )
  goto menu

:: helper to display module state
:show_mod
  set "i=%~1"
  call set "state=%%M%i%%%"
  call set "name=%%MOD%i%%%"
  if "%state%"=="1" (set "mark=[X]") else (set "mark=[ ]")
  echo  %i% %mark%  %name%
  exit /b

:: -------------------------
:: Execution modules selected
:: -------------------------
:execute_selected
  cls
  echo === Application des modules selectionnes ===
  echo Backup automatique (DNS/TCP) avant modifications...
  call :backup_settings

  rem MODULE 1: Reseau
  if "%M1%"=="1" (
    echo.
    echo -> Module 1: Optimisation reseau
    call :get_iface
    echo Interface detectee: "%IFACE%"
    netsh interface tcp set global autotuninglevel=normal
    netsh interface tcp set heuristics disabled
    netsh interface tcp set global ecncapability=enabled
    netsh interface tcp set global rss=enabled
    for /f "tokens=2 delims={}" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" 2^>nul') do (
      reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{%%i}" /v TcpAckFrequency /t REG_DWORD /d 1 /f >nul 2>&1
      reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{%%i}" /v TCPNoDelay /t REG_DWORD /d 1 /f >nul 2>&1
    )
    rem set DNS primary + fallback (best-effort)
    netsh interface ip set dns name="%IFACE%" static 1.1.1.1 >nul 2>&1
    netsh interface ip add dns name="%IFACE%" 8.8.8.8 index=2 >nul 2>&1
    ipconfig /flushdns
    echo Reseau: OK
  )

  rem MODULE 2: CPU
  if "%M2%"=="1" (
    echo.
    echo -> Module 2: Optimisation CPU
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v IRQ8Priority /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 1 /f >nul 2>&1
    echo CPU: OK
  )

  rem MODULE 3: GPU
  if "%M3%"=="1" (
    echo.
    echo -> Module 3: Optimisation GPU
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v DirectXUserMode /t REG_SZ /d "Hardware" /f >nul 2>&1
    echo GPU: OK
  )

  rem MODULE 4: SSD
  if "%M4%"=="1" (
    echo.
    echo -> Module 4: Optimisation SSD/HDD
    fsutil behavior set DisableDeleteNotify 0 >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableSuperfetch /t REG_DWORD /d 0 /f >nul 2>&1
    echo SSD: OK
  )

  rem MODULE 5: Telemetry
  if "%M5%"=="1" (
    echo.
    echo -> Module 5: Reduction telemetrie
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
    sc stop DiagTrack >nul 2>&1
    sc config DiagTrack start= disabled >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v DODownloadMode /t REG_DWORD /d 0 /f >nul 2>&1
    echo Telemetry: OK
  )

  rem MODULE 6: Appx removal
  if "%M6%"=="1" (
    echo.
    echo -> Module 6: Suppression Appx UWP (irreversible)
    for %%p in (
      Microsoft.3DBuilder Microsoft.XboxApp Microsoft.XboxGameOverlay
      Microsoft.XboxGamingOverlay Microsoft.BingNews Microsoft.GetHelp
      Microsoft.Getstarted Microsoft.MixedReality.Portal Microsoft.SkypeApp
      Microsoft.WindowsAlarms Microsoft.WindowsFeedbackHub Microsoft.WindowsMaps
      Microsoft.WindowsSoundRecorder Microsoft.YourPhone
    ) do (
      powershell -Command "Get-AppxPackage -Name '%%p' | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
      powershell -Command "Get-AppxProvisionedPackage -Online | Where-Object Name -EQ '%%p' | Remove-AppxProvisionedPackage -Online" >nul 2>&1
    )
    echo Appx removal: OK
  )

  rem MODULE 7: Services disable
  if "%M7%"=="1" (
    echo.
    echo -> Module 7: Desactivation services inutiles
    for %%s in (SysMain WSearch Fax WMPNetworkSvc RemoteRegistry XboxGipSvc XboxNetApiSvc MapsBroker) do (
      sc stop %%s 2>nul
      sc config %%s start= disabled >nul 2>&1
    )
    echo Services: OK
  )

  rem MODULE 8: Cortana OneDrive Bing
  if "%M8%"=="1" (
    echo.
    echo -> Module 8: Suppr Cortana / OneDrive / Bing
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f >nul 2>&1
    taskkill /f /im OneDrive.exe >nul 2>&1
    %SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall >nul 2>&1
    echo Cortana/OneDrive/Bing: OK
  )

  rem MODULE 9: Nettoyage
  if "%M9%"=="1" (
    echo.
    echo -> Module 9: Nettoyage avance
    del /q /f "%TEMP%\*" >nul 2>&1
    del /q /f "C:\Windows\Temp\*" >nul 2>&1
    if exist "C:\Windows\SoftwareDistribution" (
      rd /s /q "C:\Windows\SoftwareDistribution" >nul 2>&1
    )
    wevtutil cl System >nul 2>&1
    wevtutil cl Application >nul 2>&1
    setx POWERSHELL_TELEMETRY_OPTOUT 1 /m >nul 2>&1
    echo Nettoyage: OK
  )

  rem MODULE 10: HOSTS blocking
  if "%M10%"=="1" (
    echo.
    echo -> Module 10: Blocage tracking via HOSTS (ajout liste basique)
    set "HOSTSFILE=%windir%\system32\drivers\etc\hosts"
    rem backup hosts
    copy "%HOSTSFILE%" "%BACKUPDIR%\hosts_backup_%date:~6,4%-%date:~3,2%-%date:~0,2%.bak" >nul 2>&1
    (
      echo # Windows11 Optimizer blocked hosts - generated %date% %time%
      echo 0.0.0.0 vortex.data.microsoft.com
      echo 0.0.0.0 watson.telemetry.microsoft.com
      echo 0.0.0.0 settings-win.data.microsoft.com
      echo 0.0.0.0 telemetry.microsoft.com
      echo 0.0.0.0 diagnostics.support.microsoft.com
      echo 0.0.0.0 ads.example.com
    ) >> "%HOSTSFILE%"
    echo Hosts updated (backup in %BACKUPDIR%)
  )

  echo.
  echo === Fin des modules selectionnes ===
  echo Verifications finales...
  ipconfig /flushdns >nul 2>&1
  echo.
  rem petit test ping
  echo Test ping 1.1.1.1 (Cloudflare) : 
  ping -n 4 1.1.1.1

  echo.
  set /p "REBOOT=Souhaites-tu redemarrer maintenant ? (o/N) : "
  if /i "%REBOOT%"=="o" (shutdown /r /t 10) else echo Pense a redemarrer pour appliquer toutes les modifications.

  pause
  goto :menu
