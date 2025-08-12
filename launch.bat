@echo off
REM Usage: launch_and_block_cef.bat <SteamAppID> <GameExeName>

set "APPID=%~1"
set "GAMEEXE=%~2"

REM Absolute paths (hardcoded version; can be made dynamic via registry)
set "STEAM_PATH=C:\Program Files (x86)\Steam\steam.exe"
set "CEF1=C:\Program Files (x86)\Steam\bin\cef\cef.win7\steamwebhelper.exe"
set "CEF2=C:\Program Files (x86)\Steam\bin\cef\cef.win7x64\steamwebhelper.exe"
set "LOG=C:\logfile.txt"

REM Utility paths
set "TASKLIST=%SystemRoot%\System32\tasklist.exe"
set "TASKKILL=%SystemRoot%\System32\taskkill.exe"
set "FIND=%SystemRoot%\System32\find.exe"
set "FINDSTR=%SystemRoot%\System32\findstr.exe"
set "PING=%SystemRoot%\System32\ping.exe"

REM --- Restore any leftover .blocked helpers ---
for %%P in ("%CEF1%.blocked" "%CEF2%.blocked") do (
  if exist "%%~P" ren "%%~P" "steamwebhelper.exe"
)

REM --- Backup originals if needed ---
for %%P in ("%CEF1%" "%CEF2%") do (
  if exist "%%~P" if not exist "%%~P.bak" copy "%%~P" "%%~P.bak" >nul
)

REM --- Launch Steam ---
echo Launching Steam AppID %APPID%... >> "%LOG%"
start "" "%STEAM_PATH%" -applaunch %APPID% >> "%LOG%" 2>&1
if errorlevel 1 exit /b 1

REM --- Wait for game to start ---
:waitGame
"%TASKLIST%" | "%FINDSTR%" /I "%GAMEEXE%" >nul
if errorlevel 1 (
  "%PING%" 127.0.0.1 -n 5 >nul
  goto waitGame
)

echo Game detected; delaying 10s before blocking helpers... >> "%LOG%"
"%PING%" 127.0.0.1 -n 15 >nul

REM --- Block CEF helpers initially ---
call :renameCEF

REM --- Monitor loop ---
:monitorLoop

REM Try rename immediately
call :renameCEF
REM Very short delay to keep loop aggressive  
"%PING%" 127.0.0.1 -n 2 >nul
"%TASKLIST%" | "%FINDSTR%" /I steamwebhelper >nul
if errorlevel 1 (
   goto :end
)
goto :monitorLoop

:end
"%PING%" 127.0.0.1 -n 10 >nul
"%TASKLIST%" | "%FINDSTR%" /I steamwebhelper >nul
if errorlevel 1 (
   exit /b 0
)
goto :monitorLoop


:renameCEF
  :: Kill any helper still in memory
  "%TASKKILL%" /F /IM steamwebhelper.exe >nul 2>&1

  :: Attempt native rename first
  for %%P in ("%CEF1%" "%CEF2%") do (
    if exist "%%~P" (      
      "%TASKKILL%" /F /IM steamwebhelper.exe >nul 2>&1
      ren "%%~P" "steamwebhelper.exe.blocked" 2>nul
      del /f /q "%%~P" 2>nul
      if exist "%%~P.blocked" (
        echo Renamed via ren: %%~P >> "%LOG%"
      ) else (
        :: Fallback to Linux mv
        "%TASKKILL%" /F /IM steamwebhelper.exe >nul 2>&1
        bash -c "mv '%%~P' '%%~P.blocked'" 2>nul
        if exist "%%~P.blocked" (
          echo Renamed via mv: %%~P >> "%LOG%"
        ) else (
          echo Failed to rename: %%~P >> "%LOG%"
        )
      )
    )
  )

exit /b 0
