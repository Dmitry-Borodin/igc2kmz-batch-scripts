@echo off

setlocal enabledelayedexpansion

set targetfolder=%1
cd /d %targetfolder% 


for /f "usebackq delims=|" %%F in (`dir /s /b %targetdir%*.igc`) do (
for %%a in ("%%F") do for %%b in ("%%~dpa\.") do set "pname=%%~nxb"

set kmz_name=%%F.kmz
 
if not exist "kmz_name" (
   if exist "%%~dpFcolor.txt" (set /p col=<"%%~dpFcolor.txt") else (set col="ffffffff") 
   
   echo "%%F" to "!kmz_name!" color "!col!"    
   c:\Python3\python.exe c:\igc\igc2kmz\bin\igc2kmz.py -i "%%F" -o "!kmz_name!" -c "!col!" -n "!pname!"
) 
)

pause
