@echo off
echo ===============================================
echo    TaskMasture Distribution Preparation
echo ===============================================
echo.

:: Check if build exists
if not exist "build\windows\x64\runner\Release\taskmasture_clean.exe" (
    echo ERROR: Release build not found!
    echo Please run: flutter build windows --release
    echo.
    pause
    exit /b 1
)

:: Create distribution directory
echo Creating distribution directory...
if exist "TaskMasture_Distribution" rmdir /s /q "TaskMasture_Distribution"
mkdir "TaskMasture_Distribution"

:: Copy main executable
echo Copying main executable...
copy "build\windows\x64\runner\Release\taskmasture_clean.exe" "TaskMasture_Distribution\"

:: Copy Flutter DLL
echo Copying Flutter runtime...
copy "build\windows\x64\runner\Release\flutter_windows.dll" "TaskMasture_Distribution\"

:: Copy plugin DLLs
echo Copying plugin libraries...
for %%f in (build\windows\x64\runner\Release\*_plugin.dll) do (
    copy "%%f" "TaskMasture_Distribution\"
)

:: Copy data folder
echo Copying application data...
if exist "build\windows\x64\runner\Release\data" (
    xcopy "build\windows\x64\runner\Release\data" "TaskMasture_Distribution\data\" /s /i /y
)

:: Copy assets folder
echo Copying assets...
if exist "assets" (
    xcopy "assets" "TaskMasture_Distribution\assets\" /s /i /y
)

:: Copy documentation
echo Copying documentation files...
copy "README.txt" "TaskMasture_Distribution\" 2>nul
copy "LICENSE.txt" "TaskMasture_Distribution\" 2>nul
copy "CHANGELOG.txt" "TaskMasture_Distribution\" 2>nul

:: Copy icons if they exist
echo Copying icon files...
if exist "app_icon.ico" copy "app_icon.ico" "TaskMasture_Distribution\"
if exist "app_icon.jpg" copy "app_icon.jpg" "TaskMasture_Distribution\"

:: Copy installer script
echo Copying installer script...
copy "taskmasture_setup.iss" "TaskMasture_Distribution\" 2>nul

:: Create version info file
echo Creating version info...
echo TaskMasture v1.0.0 > "TaskMasture_Distribution\VERSION.txt"
echo Build Date: %date% %time% >> "TaskMasture_Distribution\VERSION.txt"
echo Built on: %COMPUTERNAME% >> "TaskMasture_Distribution\VERSION.txt"

:: Test the executable
echo.
echo Testing executable...
"TaskMasture_Distribution\taskmasture_clean.exe" --help >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: Executable might have missing dependencies
) else (
    echo Executable test passed!
)

:: Show summary
echo.
echo ===============================================
echo           Distribution Ready!
echo ===============================================
echo.
echo Files copied to: TaskMasture_Distribution\
echo.
dir "TaskMasture_Distribution" /b
echo.
echo Next steps:
echo 1. Test run TaskMasture_Distribution\taskmasture_clean.exe
echo 2. Compile installer with Inno Setup
echo 3. Test installer on clean Windows machine
echo 4. Distribute TaskMasture_Setup_v1.0.0.exe
echo.
echo Distribution package size:
for /f "tokens=3" %%a in ('dir "TaskMasture_Distribution" /-c ^| find "File(s)"') do echo %%a bytes
echo.
pause