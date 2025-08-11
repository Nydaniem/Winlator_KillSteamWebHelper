REM @echo off
REM Usage: launch_and_block_cef.bat <SteamAppID> <GameExeName>
::if "%~2"=="" (
::  echo Usage: %~nx0 ^<SteamAppID^> ^<GameExeName^>
::  exit /b 1
::)

set "APPID=%~1"
set "GAMEEXE=%~2"

REM Absolute paths
set "STEAM_PATH=C:\Program Files (x86)\Steam\steam.exe"
set "CEF1=C:\Program Files (x86)\Steam\bin\cef\cef.win7\steamwebhelper.exe"
set "CEF2=C:\Program Files (x86)\Steam\bin\cef\cef.win7x64\steamwebhelper.exe"
set "LOG=C:\logfile.txt"

REM Utility paths
set "TASKLIST=%SystemRoot%\System32\tasklist.exe"
set "TASKKILL=%SystemRoot%\System32\taskkill.exe"
set "FINDSTR=%SystemRoot%\System32\findstr.exe"
set "PING=%SystemRoot%\System32\ping.exe"

REM Restore any leftover .blocked helpers
for %%P in ("%CEF1%.blocked" "%CEF2%.blocked") do (
  if exist "%%~P" ren "%%~P" "steamwebhelper.exe"
)

REM Backup originals if needed
for %%P in ("%CEF1%" "%CEF2%") do (
  if exist "%%~P" if not exist "%%~P.bak" copy "%%~P" "%%~P.bak" >nul
)

REM Launch Steam
echo Launching Steam AppID %APPID%... >> "%LOG%"
& start "" "%STEAM_PATH%" -applaunch %APPID% >> "%LOG%" 2>&1
if errorlevel 1 exit /b 1

REM Wait for game to start (poll every 5s)
:waitGame
"%TASKLIST%" | "%FINDSTR%" /I "%GAMEEXE%" >nul
if errorlevel 1 (
  "%PING%" 127.0.0.1 -n 6 >nul
  goto waitGame
)

echo Game detected delaying 10s before blocking... >> "%LOG%"
"%PING%" 127.0.0.1 -n 15 >nul

REM Block CEF helpers
echo Blocking steamwebhelper.exe... >> "%LOG%"
for %%P in ("%CEF1%" "%CEF2%") do (
  "%TASKKILL%" /F /IM steamwebhelper.exe >nul 2>&1
  if exist "%%~P" ren "%%~P" "steamwebhelper.exe.blocked"
)

REM Remove HERE REM _LOOP

REM _LOOP :monitorLoop - IF NEEDED TO KILL STEAMWEBHELPER IF RENAME DOESN'T WORK
REM 3a. Check if game is still running
"%TASKLIST%" | "%FINDSTR%" /I "%GAMEEXE%" >nul
REM _LOOP if errorlevel 1 goto restoreHelpers

REM 3b. Kill steamwebhelper.exe
"%TASKKILL%" /F /IM steamwebhelper.exe >nul 2>&1

REM 3c. Wait ~1 second
REM _LOOP "%PING%" 127.0.0.1 -n 30 >nul

REM _LOOP goto monitorLoop

rem _LOOP :restoreHelpers
rem _LOOP echo Game exited restoring helpers... >> "%LOG%"
rem _LOOP for %%P in ("%CEF1%.blocked" "%CEF2%.blocked") do (
rem _LOOP if exist "%%~P" ren "%%~P" "steamwebhelper.exe"
rem _LOOP )
exit /b 0
