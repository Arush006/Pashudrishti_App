@echo off
REM Start PashuDrishti Flask AI Service
REM This script starts the Python Flask API for AI disease detection

color 0A
echo.
echo ═══════════════════════════════════════════════════════════
echo  🚀 PashuDrishti Flask AI Service Startup
echo ═══════════════════════════════════════════════════════════
echo.

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo ❌ ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8+ from https://www.python.org/
    pause
    exit /b 1
)

echo ✅ Python found
echo.

REM Check if Flask app exists
if not exist "%SCRIPT_DIR%ai_service\flask_app.py" (
    color 0C
    echo ❌ ERROR: Flask app not found at ai_service\flask_app.py
    echo.
    echo Current directory: %SCRIPT_DIR%
    echo Expected path: %SCRIPT_DIR%ai_service\flask_app.py
    echo.
    echo Please ensure you're in the correct directory:
    echo cd c:\xampp\htdocs\pashudrishti_2.0\PashuDrishiti_2.0\server
    echo.
    echo Then run setup: powershell -ExecutionPolicy Bypass -File setup_ai.ps1
    pause
    exit /b 1
)

echo ✅ Flask app found at: %SCRIPT_DIR%ai_service\flask_app.py

REM Check dependencies
echo.
echo Checking Python dependencies...
python -c "import flask, torch, torchvision" 2>nul
if %errorlevel% neq 0 (
    color 0E
    echo ⚠️  Installing required Python packages...
    echo.
    pip install -r "%SCRIPT_DIR%ai_service\requirements.txt"
    if %errorlevel% neq 0 (
        color 0C
        echo ❌ Failed to install dependencies
        pause
        exit /b 1
    )
)

echo ✅ Dependencies OK
echo.

REM Check if model files exist
if not exist "%SCRIPT_DIR%ai_service\model.pth" (
    color 0E
    echo ⚠️  WARNING: model.pth not found
    echo Please copy from: c:\xampp\htdocs\pashudrishti_ai\Pashudrishti_ai\model.pth
    echo.
)

if not exist "%SCRIPT_DIR%ai_service\encoder.pkl" (
    color 0E
    echo ⚠️  WARNING: encoder.pkl not found
    echo Please copy from: c:\xampp\htdocs\pashudrishti_ai\Pashudrishti_ai\encoder.pkl
    echo.
)

REM Start Flask service
color 0B
echo 🚀 Starting Flask AI Service on http://127.0.0.1:5001
echo.
echo Flask API will be available at:
echo   http://127.0.0.1:5001/health
echo.
echo Press Ctrl+C to stop the service
echo ═══════════════════════════════════════════════════════════
echo.

cd /d "%SCRIPT_DIR%"
python ai_service\flask_app.py

if %errorlevel% neq 0 (
    color 0C
    echo ❌ Flask service exited with error (code: %errorlevel%)
    pause
    exit /b %errorlevel%
)

pause
