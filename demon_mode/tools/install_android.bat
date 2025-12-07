@echo off
setlocal
echo Installing Android SDK...

set SDK_ROOT=%~dp0..\sdk\android
if not exist "%SDK_ROOT%" mkdir "%SDK_ROOT%"

echo Extracting commandlinetools...
powershell -Command "Expand-Archive -Path sdk\commandlinetools.zip -DestinationPath sdk\temp -Force"

echo Restructuring SDK...
if not exist "%SDK_ROOT%\cmdline-tools" mkdir "%SDK_ROOT%\cmdline-tools"
move "sdk\temp\cmdline-tools" "%SDK_ROOT%\cmdline-tools\latest"
rd /s /q "sdk\temp"

echo Setting Environment...
set ANDROID_HOME=%SDK_ROOT%
set PATH=%ANDROID_HOME%\cmdline-tools\latest\bin;%PATH%

echo Accepting Licenses...
type "%~dp0yes.txt" | "%SDK_ROOT%\cmdline-tools\latest\bin\sdkmanager.bat" --licenses

echo Installing Platform Tools and Platform...
"%SDK_ROOT%\cmdline-tools\latest\bin\sdkmanager.bat" "platform-tools" "platforms;android-34" "build-tools;34.0.0"

echo Android SDK Setup Complete.
endlocal
