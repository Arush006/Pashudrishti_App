# 🚀 PashuDrishti AI Integration - Windows Quick Start

## ⚡ Super Quick Setup (5 Minutes)

### Step 1: Copy Model Files (Easy!)

**Just double-click this file:**
```
copy_model_files.bat
```

It will automatically copy:
- ✅ `model.pth` 
- ✅ `encoder.pkl`

From: `c:\xampp\htdocs\pashudrishti_ai\Pashudrishti_ai\`  
To: `server\ai_service\`

---

### Step 2: Install Python Dependencies

**Open PowerShell and run:**
```powershell
# Make sure you're in the server directory
cd "c:\xampp\htdocs\pashudrishti_2.0\PashuDrishiti_2.0\server"

# Run setup (one command!)
powershell -ExecutionPolicy Bypass -File setup_ai.ps1
```

This will:
- ✅ Verify Python installation
- ✅ Copy remaining files
- ✅ Install Flask, PyTorch, etc.
- ✅ Check database config

---

### Step 3: Setup Database

**Open Command Prompt and run:**
```bash
# Navigate to server directory
cd "c:\xampp\htdocs\pashudrishti_2.0\PashuDrishiti_2.0\server"

# Setup database
mysql -u root -p < sql/ai_schema.sql

# When prompted for password, enter:
# Anamay2005Strong!
```

Or use MySQL Workbench:
1. Open MySQL Workbench
2. Open File → Open SQL Script
3. Select: `server\sql\ai_schema.sql`
4. Execute

---

### Step 4: Start Flask AI Service

**Double-click this file:**
```
start_ai_service.bat
```

You should see:
```
✅ Python found
✅ Flask app found
✅ Dependencies OK
🚀 Starting Flask AI Service on http://127.0.0.1:5001
```

**Keep this window open!**

---

### Step 5: Start Node.js Server

**Open a NEW Command Prompt and run:**
```bash
cd "c:\xampp\htdocs\pashudrishti_2.0\PashuDrishiti_2.0\server"

npm start
```

You should see:
```
✅ MySQL Connected Successfully
Server running on port 5000
```

**Keep this window open too!**

---

## ✅ Verify Everything Works

### Test Flask Service:
```
http://127.0.0.1:5001/health
```

Should show:
```json
{
  "status": "AI Service is running",
  "model_loaded": true,
  "encoder_loaded": true
}
```

### Test Node Server:
```
http://127.0.0.1:5000/api/health
```

Should show:
```json
{
  "status": "Server is running"
}
```

---

## 🐛 Troubleshooting

### Issue: `copy_model_files.bat` says "source not found"

**Solution:**
Manually copy the files:
1. Open File Explorer
2. Navigate to: `c:\xampp\htdocs\pashudrishti_ai\Pashudrishti_ai\`
3. Copy `model.pth` and `encoder.pkl`
4. Paste into: `c:\xampp\htdocs\pashudrishti_2.0\PashuDrishiti_2.0\server\ai_service\`

---

### Issue: "Python not found"

**Solution:**
1. Download Python from https://www.python.org/downloads/
2. Install with: **✅ Add Python to PATH** (important!)
3. Restart Command Prompt
4. Verify: `python --version`

---

### Issue: "Flask app not found"

**Solution:**
Make sure you're in correct directory:
```bash
# CORRECT:
cd "c:\xampp\htdocs\pashudrishti_2.0\PashuDrishiti_2.0\server"

# Then run:
start_ai_service.bat
```

---

### Issue: Port 5001 already in use

**Solution:**
```bash
# Find what's using port 5001
netstat -ano | findstr :5001

# Kill the process (replace PID with number from above)
taskkill /PID <PID> /F
```

---

### Issue: MySQL connection error

**Solution:**
1. Make sure XAMPP/MySQL is running
2. Verify credentials in `.env`:
   ```
   DB_HOST=127.0.0.1
   DB_USER=root
   DB_PASSWORD=Anamay2005Strong!
   DB_NAME=pashudrishti
   ```
3. Test connection:
   ```bash
   mysql -u root -p -e "SELECT 1"
   ```

---

### Issue: "requirements.txt not found"

**Solution:**
Make sure you're in server directory:
```bash
cd "c:\xampp\htdocs\pashudrishti_2.0\PashuDrishiti_2.0\server"
pip install -r ai_service/requirements.txt
```

---

## 📋 File Checklist

After setup, you should have these files:

```
server/
├── ai_service/
│   ├── flask_app.py          ✅ Created
│   ├── requirements.txt       ✅ Created
│   ├── model.pth             ✅ MUST COPY
│   ├── encoder.pkl           ✅ MUST COPY
│   └── (other files)
├── copy_model_files.bat       ✅ Created
├── start_ai_service.bat       ✅ Created (fixed)
├── setup_ai.ps1              ✅ Created
├── sql/ai_schema.sql         ✅ Created
├── .env                       ⚠️ Copy from .env.example
├── package.json              ✅ Updated
└── (other files)
```

---

## 🎯 Usage Example

Once everything is running:

### Upload Image for Disease Detection:
```bash
curl -X POST http://127.0.0.1:5000/api/ai/analyze-image \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "image=@disease_image.jpg" \
  -F "language=en"
```

Response:
```json
{
  "success": true,
  "disease": "Mastitis",
  "confidence": 92.5,
  "top3": [
    {"disease": "Mastitis", "confidence": 92.5},
    {"disease": "Pneumonia", "confidence": 5.2},
    {"disease": "FMD", "confidence": 2.3}
  ],
  "treatment": {
    "symptoms": ["Udder swelling", "Milk discoloration"],
    "treatment": "Antibiotics (Amoxicillin + Ampicillin)",
    "duration": "7-14 days",
    "cost": "₹800-1500"
  }
}
```

---

## 📚 Complete Setup Reference

| Step | Command | Time | Status |
|------|---------|------|--------|
| 1 | `copy_model_files.bat` | 1 min | ⚠️ Required |
| 2 | `setup_ai.ps1` | 2-3 min | ✅ Auto handles |
| 3 | `mysql < sql/ai_schema.sql` | 1 min | ⚠️ Required |
| 4 | `start_ai_service.bat` | Instant | ✅ Keep running |
| 5 | `npm start` | Instant | ✅ Keep running |

**Total Time**: ~5-10 minutes first time

---

## 🆘 Need Help?

1. **Check logs**: Look at terminal output
2. **Verify paths**: Make sure all directories exist
3. **Check ports**: `netstat -ano | findstr :5000` and `:5001`
4. **Restart**: Close all terminals and start fresh

---

**Last Updated**: May 8, 2026  
**Windows Tested**: Windows 10/11  
**Python**: 3.8+  
**Node**: 14+
