#!/usr/bin/env powershell
<#
.SYNOPSIS
    PashuDrishti AI Integration Setup Script (Windows PowerShell)
    
.DESCRIPTION
    Automatically copies model files, installs dependencies, and sets up the AI service
    
.EXAMPLE
    .\setup_ai.ps1
#>

# Color output helper
$Colors = @{
    Green = "Green"
    Red = "Red"
    Yellow = "Yellow"
    Blue = "Cyan"
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Type = "Info"
    )
    
    switch ($Type) {
        "Success" { Write-Host "✅ $Message" -ForegroundColor $Colors.Green }
        "Error" { Write-Host "❌ $Message" -ForegroundColor $Colors.Red }
        "Warning" { Write-Host "⚠️  $Message" -ForegroundColor $Colors.Yellow }
        "Info" { Write-Host "ℹ️  $Message" -ForegroundColor $Colors.Blue }
    }
}

# Get current directory
$ServerDir = Get-Location
$AIServiceDir = Join-Path $ServerDir "ai_service"
$RootDir = Join-Path (Split-Path $ServerDir -Parent) ".." ".."
$PashudrishtiAIDir = Join-Path $RootDir "pashudrishti_ai" "Pashudrishti_ai"

Write-Host "`n"
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor $Colors.Blue
Write-Host "🚀 PashuDrishti AI Integration Setup (Windows PowerShell)" -ForegroundColor $Colors.Blue
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor $Colors.Blue
Write-Host ""

# Step 1: Verify directories
Write-Log "Step 1: Verifying directory structure..." "Info"
Write-Log "Server Directory: $ServerDir" "Info"
Write-Log "AI Service Directory: $AIServiceDir" "Info"
Write-Log "PashuDrishti AI Source: $PashudrishtiAIDir" "Info"

if (-not (Test-Path $AIServiceDir)) {
    Write-Log "Creating AI service directory..." "Info"
    New-Item -ItemType Directory -Path $AIServiceDir -Force | Out-Null
    Write-Log "AI service directory created" "Success"
}

if (-not (Test-Path $PashudrishtiAIDir)) {
    Write-Log "WARNING: PashuDrishti AI directory not found at: $PashudrishtiAIDir" "Warning"
    Write-Log "Trying alternate path..." "Info"
    
    # Try alternate path
    $PashudrishtiAIDir = "c:\xampp\htdocs\pashudrishti_ai\Pashudrishti_ai"
    if (Test-Path $PashudrishtiAIDir) {
        Write-Log "Found at: $PashudrishtiAIDir" "Success"
    } else {
        Write-Log "ERROR: Could not find pashudrishti_ai directory" "Error"
        Write-Log "Please manually copy model files:" "Info"
        Write-Log "  1. Copy model.pth to: $AIServiceDir\" "Info"
        Write-Log "  2. Copy encoder.pkl to: $AIServiceDir\" "Info"
        Read-Host "Press Enter to continue anyway..."
    }
}

# Step 2: Copy model files
Write-Log "`nStep 2: Copying AI model files..." "Info"

$ModelFiles = @("model.pth", "encoder.pkl")
$CopiedCount = 0

foreach ($file in $ModelFiles) {
    $Source = Join-Path $PashudrishtiAIDir $file
    $Dest = Join-Path $AIServiceDir $file
    
    if (Test-Path $Source) {
        Copy-Item -Path $Source -Destination $Dest -Force
        Write-Log "Copied: $file" "Success"
        $CopiedCount++
    } else {
        Write-Log "File not found: $file at $Source" "Warning"
    }
}

Write-Log "Copied $CopiedCount model files" "Info"

# Step 3: Check Python installation
Write-Log "`nStep 3: Checking Python installation..." "Info"
$PythonVersion = python --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Log "Python found: $PythonVersion" "Success"
} else {
    Write-Log "ERROR: Python not found or not in PATH" "Error"
    Write-Log "Please install Python 3.8+ from https://www.python.org/" "Info"
    exit 1
}

# Step 4: Install Python dependencies
Write-Log "`nStep 4: Installing Python dependencies..." "Info"
$ReqFile = Join-Path $AIServiceDir "requirements.txt"

if (Test-Path $ReqFile) {
    Write-Log "Installing packages from requirements.txt..." "Info"
    python -m pip install --upgrade pip | Out-Null
    pip install -r $ReqFile
    
    if ($LASTEXITCODE -eq 0) {
        Write-Log "Python dependencies installed successfully" "Success"
    } else {
        Write-Log "Some dependencies may have failed to install" "Warning"
    }
} else {
    Write-Log "requirements.txt not found" "Error"
}

# Step 5: Verify Flask app
Write-Log "`nStep 5: Verifying Flask application..." "Info"
$FlaskApp = Join-Path $AIServiceDir "flask_app.py"

if (Test-Path $FlaskApp) {
    Write-Log "Flask app found" "Success"
} else {
    Write-Log "ERROR: Flask app not found at $FlaskApp" "Error"
}

# Step 6: Check environment file
Write-Log "`nStep 6: Checking environment configuration..." "Info"
$EnvFile = Join-Path $ServerDir ".env"

if (Test-Path $EnvFile) {
    $EnvContent = Get-Content $EnvFile -Raw
    if ($EnvContent -match "ROBOFLOW_API_KEY") {
        Write-Log ".env file configured with ROBOFLOW_API_KEY" "Success"
    } else {
        Write-Log "WARNING: ROBOFLOW_API_KEY not found in .env" "Warning"
    }
} else {
    Write-Log "WARNING: .env file not found" "Warning"
    Write-Log "Copy from .env.example and configure" "Info"
}

# Step 7: Summary
Write-Host "`n"
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor $Colors.Green
Write-Host "✅ Setup Complete!" -ForegroundColor $Colors.Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor $Colors.Green
Write-Host ""

Write-Log "📋 Next Steps:" "Info"
Write-Host "1. Ensure model.pth exists in: $AIServiceDir"
Write-Host "2. Ensure encoder.pkl exists in: $AIServiceDir"
Write-Host "3. Configure .env with ROBOFLOW_API_KEY=your_roboflow_api_key"
Write-Host "4. Start Flask service: python ai_service/flask_app.py"
Write-Host "5. Start Node server: npm start"
Write-Host ""

# Ask to continue
$Continue = Read-Host "Setup complete. Press Enter to close or 'Y' to start Flask service now"

if ($Continue -eq "Y" -or $Continue -eq "y") {
    Write-Log "Starting Flask service..." "Info"
    Set-Location $AIServiceDir
    python flask_app.py
}
