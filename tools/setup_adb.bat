@echo off
set "ADB_PATH=%~dp0..\sdk\android\platform-tools"
set "PATH=%ADB_PATH%;%PATH%"
echo ADB added to PATH.
adb version
