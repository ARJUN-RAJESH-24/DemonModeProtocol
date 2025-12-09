@echo off
echo Building Demon Mode APK...

:: Set Java 21 Path
set JAVA_HOME=%~dp0..\sdk\java\jdk-21.0.4+7
set PATH=%JAVA_HOME%\bin;%PATH%

:: Run Build
cd ..
call sdk\flutter\bin\flutter.bat build apk --debug
if %errorlevel% neq 0 (
    echo Build failed. Trying direct Gradle...
    cd android
    call gradlew.bat assembleDebug
    cd ..
)

echo.
echo Build Complete.
pause
