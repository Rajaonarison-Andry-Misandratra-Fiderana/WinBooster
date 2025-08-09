@echo off
title Windows 11 Ultra Optimizer - Advanced Interactive
color 0A
setlocal EnableDelayedExpansion

:: ==========================
:: Windows 11 Ultra Optimizer
:: Version: Advanced Interactive Complete
:: Language: English
:: ==========================

:: Initialize options (0=off, 1=on)
set opt_network=0
set opt_cpu=0
set opt_gpu=0
set opt_ssd=0
set opt_telemetry=0
set opt_apps=0
set opt_services=0
set opt_remove_bloat=0
set opt_cleaning=0
set opt_blocking=0

:: Define arrays for menu display
setlocal EnableDelayedExpansion
set options[1]=Network Optimization
set options[2]=CPU Optimization
set options[3]=GPU Optimization
set options[4]=SSD Optimization
set options[5]=Telemetry Reduction
set options[6]=UWP App Cleanup
set options[7]=Disable Unnecessary Services
set options[8]=Remove Cortana / OneDrive / Bing
set options[9]=Advanced System Cleaning
set options[10]=Ad/Tracker Host Blocking

:: Main loop
:main_menu
cls
echo ======================================================
echo        Windows 11 Ultra Optimizer - Main Menu
echo ======================================================
echo.
for /l %%i in (1,1,10) do (
    call :show_option %%i
)
echo.
echo [A] Select All Optimizations
echo [B] Basic Optimizations Only
echo [R] Reset All Selections
echo [S] Start Optimization
echo [Q] Quit
echo.
set /p "choice=Choose option number or letter: "

set choice=!choice:~0,1!
if /i "!choice!"=="Q" exit /b
if /i "!choice!"=="R" (
    call :reset_all
    goto main_menu
)
if /i "!choice!"=="A" (
    call :select_all
    goto main_menu
)
if /i "!choice!"=="B" (
    call :select_basic
    goto main_menu
)
if "!choice!" geq "1" if "!choice!" leq "10" (
    call :toggle_option !choice!
    goto main_menu
)
goto main_menu

:: -----------------------------------
:show_option
setlocal EnableDelayedExpansion
set idx=%1
set var=opt_!idx!
if !var! EQU 1 (
    echo [!idx!] [X] !options[%idx%]!
) else (
    echo [!idx!] [ ] !options[%idx%]!
)
endlocal & exit /b

:: -----------------------------------
:toggle_option
setlocal EnableDelayedExpansion
set idx=%1
set var=opt_!idx!
if !%var%! EQU 0 (
    set opt_%idx%=1
) else (
    set opt_%idx%=0
)
endlocal & exit /b

:: -----------------------------------
:reset_all
for /l %%i in (1,1,10) do set opt_%%i=0
exit /b

:: -----------------------------------
:select_all
for /l %%i in (1,1,10) do set opt_%%i=1
exit /b

:: -----------------------------------
:select_basic
:: Basic: Network, CPU, GPU, SSD, Cleaning only (options 1,2,3,4,9)
for /l %%i in (1,1,10) do set opt_%%i=0
set opt_1=1
set opt_2=1
set opt_3=1
set opt_4=1
set opt_9=1
exit /b

:: -----------------------------------
:start_optimization
cls
echo ======================================================
echo Starting Windows 11 Ultra Optimization...
echo ======================================================
set logfile=%~dp0optimizer_log.txt
echo Optimization started at %date% %time% > "%logfile%"
echo ---------------------------------------------- >> "%logfile%"

:: Check admin rights
net session >nul 2>&1
if errorlevel 1 (
    echo ERROR: This script must be run as Administrator.
    pause
    exit /b
)

:: Run selected modules
if %opt_1%==1 call :network_opt
if %opt_2%==1 call :cpu_opt
if %opt_3%==1 call :gpu_opt
if %opt_4%==1 call :ssd_opt
if %opt_5%==1 call :telemetry_opt
if %opt_6%==1 call :apps_opt
if %opt_7%==1 call :services_opt
if %opt_8%==1 call :remove_bloat
if %opt_9%==1 call :cleaning_opt
if %opt_10%==1 call :blocking_opt

echo. >> "%logfile%"
echo Optimization completed. >> "%logfile%"
echo Please restart your PC for all changes to take effect.
echo.
pause
exit /b

:: ===============================
:: MODULE FUNCTIONS START HERE
:: ===============================

:network_opt
echo [Network Optimization] >> "%logfile%"
echo Optimizing TCP/IP stack and DNS settings...
:: Set TCP autotuning
netsh interface tcp set global autotuninglevel=normal >> "%logfile%" 2>&1
:: Disable heuristics
netsh interface tcp set heuristics disabled >> "%logfile%" 2>&1
:: Enable ECN
netsh interface tcp set global ecncapability=enabled >> "%logfile%" 2>&1
:: Enable RSS & DCA
netsh interface tcp set global rss=enabled >> "%logfile%" 2>&1
netsh interface tcp set global dca=enabled >> "%logfile%" 2>&1
:: Set congestion provider to CTCP
netsh interface tcp set supplemental internet congestionprovider=ctcp >> "%logfile%" 2>&1

:: Disable Nagle & Delayed ACK on all interfaces
for /f "tokens=2 delims={}" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"') do (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{%%i}" /v TcpAckFrequency /t REG_DWORD /d 1 /f >> "%logfile%" 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{%%i}" /v TCPNoDelay /t REG_DWORD /d 1 /f >> "%logfile%" 2>&1
)

:: Set DNS to Cloudflare + Google fallback on all Ethernet and Wi-Fi interfaces
for /f "tokens=1,2 delims=:" %%a in ('netsh interface show interface ^| findstr /i "connected"') do (
    set "iface=%%b"
    set "iface=!iface:~1!"
    netsh interface ip set dns name="!iface!" static 1.1.1.1 validate=no >> "%logfile%" 2>&1
    netsh interface ip add dns name="!iface!" 8.8.8.8 index=2 >> "%logfile%" 2>&1
)

:: Flush DNS
ipconfig /flushdns >> "%logfile%" 2>&1

:: Disable Delivery Optimization (P2P updates)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v DODownloadMode /t REG_DWORD /d 0 /f >> "%logfile%" 2>&1

echo Network optimization done. >> "%logfile%"
exit /b

:cpu_opt
echo [CPU Optimization] >> "%logfile%"
echo Setting CPU and system scheduler optimizations...
:: Enable large system cache
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 1 /f >> "%logfile%" 2>&1
:: Disable CPU throttling and enable max performance for power plan
powercfg -setactive SCHEME_MIN >> "%logfile%" 2>&1
:: Disable core parking - aggressive via registry
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v ValueMax /t REG_DWORD /d 0 /f >> "%logfile%" 2>&1
echo CPU optimization done. >> "%logfile%"
exit /b

:gpu_opt
echo [GPU Optimization] >> "%logfile%"
echo Enabling hardware accelerated GPU scheduling and DirectX tweaks...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f >> "%logfile%" 2>&1
:: Set GPU priority for games (example)
reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v GpuPriorityGaming /t REG_DWORD /d 1 /f >> "%logfile%" 2>&1
echo GPU optimization done. >> "%logfile%"
exit /b

:ssd_opt
echo [SSD Optimization] >> "%logfile%"
echo Enabling TRIM and disabling Superfetch / Prefetch...
:: Enable TRIM
fsutil behavior set DisableDeleteNotify 0 >> "%logfile%" 2>&1
:: Disable Superfetch / SysMain
sc stop SysMain >> "%logfile%" 2>&1
sc config SysMain start= disabled >> "%logfile%" 2>&1
:: Disable Prefetch (registry)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 0 /f >> "%logfile%" 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableSuperfetch /t REG_DWORD /d 0 /f >> "%logfile%" 2>&1
echo SSD optimization done. >> "%logfile%"
exit /b

:telemetry_opt
echo [Telemetry Reduction] >> "%logfile%"
echo Disabling telemetry and diagnostics...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >> "%logfile%" 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >> "%logfile%" 2>&1
sc stop DiagTrack >> "%logfile%" 2>&1
sc config DiagTrack start= disabled >> "%logfile%" 2>&1
sc stop dmwappushservice >> "%logfile%" 2>&1
sc config dmwappushservice start= disabled >> "%logfile%" 2>&1
echo Telemetry disabled. >> "%logfile%"
exit /b

:apps_opt
echo [UWP App Cleanup] >> "%logfile%"
echo Removing unnecessary UWP apps...
powershell -command "Get-AppxPackage -Name Microsoft.XboxApp | Remove-AppxPackage -ErrorAction SilentlyContinue" >> "%logfile%" 2>&1
powershell -command "Get-AppxPackage -Name Microsoft.3DBuilder | Remove-AppxPackage -ErrorAction SilentlyContinue" >> "%logfile%" 2>&1
powershell -command "Get-AppxPackage -Name Microsoft.BingNews | Remove-AppxPackage -ErrorAction SilentlyContinue" >> "%logfile%" 2>&1
powershell -command "Get-AppxPackage -Name Microsoft.GetHelp | Remove-AppxPackage -ErrorAction SilentlyContinue" >> "%logfile%" 2>&1
powershell -command "Get-AppxPackage -Name Microsoft.Getstarted | Remove-AppxPackage -ErrorAction SilentlyContinue" >> "%logfile%" 2>&1
powershell -command "Get-AppxPackage -Name Microsoft.MixedReality.Portal | Remove-AppxPackage -ErrorAction SilentlyContinue" >> "%logfile%" 2>&1
powershell -command "Get-AppxPackage -Name Microsoft.SkypeApp | Remove-AppxPackage -ErrorAction SilentlyContinue" >> "%logfile%" 2>&1
powershell -command "Get-AppxPackage -Name Microsoft.WindowsAlarms | Remove-AppxPackage -ErrorAction SilentlyContinue" >> "%logfile%" 2>&1
powershell -command "Get-AppxPackage -Name Microsoft.WindowsFeedbackHub | Remove-AppxPackage -ErrorAction SilentlyContinue" >> "%logfile%" 2>&1
powershell -command "Get-AppxPackage -Name Microsoft.WindowsMaps | Remove-AppxPackage -ErrorAction SilentlyContinue" >> "%logfile%" 2>&1
powershell -command "Get-AppxPackage -Name Microsoft.WindowsSoundRecorder | Remove-AppxPackage -ErrorAction SilentlyContinue" >> "%logfile%" 2>&1
powershell -command "Get-AppxPackage -Name Microsoft.YourPhone | Remove-AppxPackage -ErrorAction SilentlyContinue" >> "%logfile%" 2>&1
echo UWP apps removed. >> "%logfile%"
exit /b

:services_opt
echo [Disable Unnecessary Services] >> "%logfile%"
echo Disabling unnecessary services...
for %%s in (
    SysMain WSearch Fax WMPNetworkSvc RemoteRegistry XboxGipSvc XboxNetApiSvc MapsBroker
) do (
    sc stop %%s >> "%logfile%" 2>&1
    sc config %%s start= disabled >> "%logfile%" 2>&1
)
echo Services disabled. >> "%logfile%"
exit /b

:remove_bloat
echo [Remove Cortana / OneDrive / Bing] >> "%logfile%"
echo Removing Cortana, OneDrive, Bing integration...
:: Disable Cortana
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f >> "%logfile%" 2>&1
:: Disable Bing Search
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f >> "%logfile%" 2>&1
:: Uninstall OneDrive
taskkill /f /im OneDrive.exe >> "%logfile%" 2>&1
start /wait %SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall >> "%logfile%" 2>&1
echo Bloat removed. >> "%logfile%"
exit /b

:cleaning_opt
echo [Advanced System Cleaning] >> "%logfile%"
echo Cleaning temporary files and caches...
del /q /f "%TEMP%\*" >nul 2>&1
del /q /f "C:\Windows\Temp\*" >nul 2>&1
del /s /q /f "%SystemRoot%\SoftwareDistribution\Download\*" >nul 2>&1
echo Cleaning done. >> "%logfile%"
exit /b

:blocking_opt
echo [Ad/Tracker Host Blocking] >> "%logfile%"
echo Blocking common ad and telemetry domains in hosts file...
set hostsfile=%windir%\System32\drivers\etc\hosts
>> "%hostsfile%" (
    echo 0.0.0.0 ad.doubleclick.net
    echo 0.0.0.0 ads.microsoft.com
    echo 0.0.0.0 ads.yahoo.com
    echo 0.0.0.0 bing.com
    echo 0.0.0.0 bingads.microsoft.com
    echo 0.0.0.0 facebook.com
    echo 0.0.0.0 graph.facebook.com
    echo 0.0.0.0 msnbot-157-55-39-30.search.msn.com
    echo 0.0.0.0 spynet2.microsoft.com
    echo 0.0.0.0 statsfe2.ws.microsoft.com
    echo 0.0.0.0 vortex.data.microsoft.com
)
echo Hosts file updated. >> "%logfile%"
exit /b
