@echo off
echo Setting up Demon Mode Protocol Environment...

:: Set Flutter SDK Path
set FLUTTER_ROOT=%~dp0..\sdk\flutter
set PATH=%FLUTTER_ROOT%\bin;%PATH%

echo Flutter SDK added to PATH for this session.
echo.
echo Checking Flutter Version...
call flutter --version

echo.
echo Setup Complete. You can now run 'flutter pub get' or 'flutter run'.
cmd /k
