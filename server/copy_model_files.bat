@echo off
REM Copy model files from pashudrishti_ai to server\ai_service

color 0A
echo.
echo ═══════════════════════════════════════════════════════════
echo  📋 Copying AI Model Files
echo ═══════════════════════════════════════════════════════════
echo.

REM Define source and destination
set SOURCE_DIR=c:\xampp\htdocs\pashudrishti_ai\Pashudrishti_ai
set DEST_DIR=%~dp0ai_service

echo Source Directory: %SOURCE_DIR%
echo Destination: %DEST_DIR%
echo.

REM Check if source directory exists
if not exist "%SOURCE_DIR%" (
    color 0C
    echo ❌ ERROR: Source directory not found
    echo %SOURCE_DIR%
    pause
    exit /b 1
)

echo ✅ Source directory found
echo.

REM Create destination if it doesn't exist
if not exist "%DEST_DIR%" (
    echo Creating destination directory...
    mkdir "%DEST_DIR%"
    echo ✅ Created: %DEST_DIR%
)

REM Copy model.pth
echo Copying model.pth...
if exist "%SOURCE_DIR%\model.pth" (
    copy "%SOURCE_DIR%\model.pth" "%DEST_DIR%\model.pth"
    if %errorlevel% equ 0 (
        echo ✅ Copied: model.pth
    ) else (
        color 0C
        echo ❌ Failed to copy model.pth
        pause
        exit /b 1
    )
) else (
    color 0C
    echo ❌ File not found: model.pth
    echo Expected at: %SOURCE_DIR%\model.pth
    pause
    exit /b 1
)

REM Copy encoder.pkl
echo.
echo Copying encoder.pkl...
if exist "%SOURCE_DIR%\encoder.pkl" (
    copy "%SOURCE_DIR%\encoder.pkl" "%DEST_DIR%\encoder.pkl"
    if %errorlevel% equ 0 (
        echo ✅ Copied: encoder.pkl
    ) else (
        color 0C
        echo ❌ Failed to copy encoder.pkl
        pause
        exit /b 1
    )
) else (
    color 0C
    echo ❌ File not found: encoder.pkl
    echo Expected at: %SOURCE_DIR%\encoder.pkl
    pause
    exit /b 1
)

echo.
color 0B
echo ═══════════════════════════════════════════════════════════
echo ✅ All files copied successfully!
echo ═══════════════════════════════════════════════════════════
echo.

REM Verify files
echo Verifying files in destination:
echo.
dir "%DEST_DIR%\model.pth" 2>nul
if %errorlevel% equ 0 (
    echo ✅ model.pth: OK
) else (
    echo ❌ model.pth: NOT FOUND
)

dir "%DEST_DIR%\encoder.pkl" 2>nul
if %errorlevel% equ 0 (
    echo ✅ encoder.pkl: OK
) else (
    echo ❌ encoder.pkl: NOT FOUND
)

echo.
pause
