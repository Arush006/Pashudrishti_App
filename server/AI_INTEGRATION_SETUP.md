# 🎯 PashuDrishti AI Integration Guide

## Overview

यह guide बताता है कि कैसे PyTorch AI model को Node.js + Flask के साथ integrate करें cattle disease detection के लिए।

**Architecture:**
```
Flask API (Python)                Node.js Server               Database
  ↓                                    ↓                            ↓
[AI Model]  ←→  [REST API]  ←→  [Controller]  ←→  [MySQL]
  (predict)     (port 5001)    (port 5000)       (predictions)
```

---

## 📋 Requirements

- Python 3.8+
- Node.js 14+
- MySQL 5.7+
- XAMPP (or separate MySQL installation)

---

## 🚀 Installation & Setup

### Step 1: Copy AI Model Files

```bash
# Navigate to server directory
cd server

# Run automatic setup
npm run setup:ai

# Manual setup (if needed):
# Copy from: c:\xampp\htdocs\pashudrishti_ai\Pashudrishti_ai\
#   - model.pth
#   - encoder.pkl
# To: c:\xampp\htdocs\pashudrishti_2.0\PashuDrishiti_2.0\server\ai_service\
```

### Step 2: Setup Database

```bash
# Create database tables and sample data
mysql -u root -p < sql/ai_schema.sql

# Or manually run in MySQL:
# 1. Open MySQL Workbench or phpMyAdmin
# 2. Execute queries from sql/ai_schema.sql
```

### Step 3: Configure Environment

**Update `.env` file:**

```env
# Roboflow AI Service
ROBOFLOW_API_KEY=your_roboflow_api_key
ROBOFLOW_API_URL=https://serverless.roboflow.com
ROBOFLOW_WORKSPACE=abhinav-bharadwaj
ROBOFLOW_WORKFLOW=pashu-drishti-vpashu-drishti-1-resnet50-t1-logic

# Database
DB_HOST=127.0.0.1
DB_USER=root
DB_PASSWORD=Anamay2005Strong!
DB_NAME=pashudrishti
DB_PORT=3306

# Node Server
PORT=5000
NODE_ENV=development
```

### Step 4: Install Python Dependencies

```bash
# Option 1: Auto (via setup script)
npm run setup:ai

# Option 2: Manual
pip install -r ai_service/requirements.txt

# Common packages:
# - flask==2.3.2
# - torch==2.0.1
# - torchvision==0.15.2
# - flask-cors==4.0.0
```

---

## 🔥 Starting the Services

### Method 1: Windows Batch File (Easiest)

```bash
# Start Flask service (दूसरे command prompt window में)
start_ai_service.bat

# Output should show:
# ✅ Python found
# ✅ Flask app found
# ✅ Dependencies OK
# 🚀 Starting Flask AI Service on http://127.0.0.1:5001
```

### Method 2: Manual Commands

```bash
# Terminal 1: Start Flask AI Service
cd server
python ai_service/flask_app.py

# Terminal 2: Start Node.js Server
cd server
npm start

# Both should be running:
# Flask: http://127.0.0.1:5001/health
# Node: http://127.0.0.1:5000/api/health
```

### Method 3: Production (With PM2)

```bash
# Install PM2 globally
npm install -g pm2

# Create ecosystem config
pm2 start "python ai_service/flask_app.py" --name "flask-ai"
pm2 start "npm start" --name "pashudrishti-server"

# Monitor
pm2 logs

# Restart
pm2 restart all
```

---

## 📡 API Endpoints

### 1. **Analyze Image for Disease Detection**

```http
POST /api/ai/analyze-image
Content-Type: multipart/form-data
Authorization: Bearer {token}

Form Data:
  - image: {file}
  - language: "en" (or "hi")

Response:
{
  "success": true,
  "predictionId": 123,
  "disease": "Mastitis",
  "confidence": 92.5,
  "top3": [
    { "disease": "Mastitis", "confidence": 92.5 },
    { "disease": "Pneumonia", "confidence": 5.2 },
    { "disease": "FMD", "confidence": 2.3 }
  ],
  "treatment": {
    "symptoms": ["Udder swelling", "Milk discoloration"],
    "treatment": "Antibiotics (Amoxicillin + Ampicillin)",
    "duration": "7-14 days",
    "cost": "₹800-1500",
    "recommendations": [...]
  }
}
```

### 2. **Predict Disease from Symptoms**

```http
POST /api/ai/predict-disease
Content-Type: application/json
Authorization: Bearer {token}

Body:
{
  "symptoms": ["fever", "cough"],
  "animalType": "cow"
}

Response:
{
  "success": true,
  "predictions": [
    {
      "name": "Pneumonia",
      "treatment": "Respiratory antibiotics",
      "confidence": 0.75
    }
  ]
}
```

### 3. **Get Treatment Recommendations**

```http
POST /api/ai/treatment-recommendations
Content-Type: application/json
Authorization: Bearer {token}

Body:
{
  "disease": "Mastitis",
  "animalType": "cow"
}

Response:
{
  "success": true,
  "disease": "Mastitis",
  "recommendations": {
    "immediate": ["Contact veterinarian immediately", ...],
    "treatment": ["Give prescribed medicine on time", ...],
    "prevention": ["Regular vaccinations", ...],
    "diet": ["Provide nutritious fodder", ...],
    "homeRemedy": ["Garlic juice for cough", ...]
  },
  "estimatedDuration": "7-14 days",
  "estimatedCost": "₹800-1500"
}
```

### 4. **Get Disease Information**

```http
GET /api/ai/diseases?language=en
Authorization: Bearer {token}

Response:
{
  "success": true,
  "diseases": [
    {
      "name": "Mastitis",
      "info": {
        "symptoms": [...],
        "treatment": "...",
        "duration": "7-14 days",
        "cost": "₹800-1500"
      }
    }
  ],
  "total": 8
}
```

### 5. **Get Prediction History**

```http
GET /api/ai/prediction-history
Authorization: Bearer {token}

Response:
{
  "success": true,
  "predictions": [
    {
      "id": 1,
      "disease": "Mastitis",
      "confidence": 92.5,
      "created_at": "2024-05-08T10:30:00Z"
    }
  ],
  "total": 5
}
```

### 6. **Chat with AI**

```http
POST /api/ai/chat
Content-Type: application/json
Authorization: Bearer {token}

Body:
{
  "query": "मेरे गाय को बुखार है",
  "language": "hi"
}

Response:
{
  "success": true,
  "response": "आपके पशु को बुखार है 😟\n\n**तुरंत करने वाले काम:**\n• पशु को ठंडे स्थान पर रखें..."
}
```

---

## 🗂️ File Structure

```
server/
├── ai_service/
│   ├── flask_app.py           # Flask AI service
│   ├── requirements.txt        # Python dependencies
│   ├── model.pth              # Trained PyTorch model
│   ├── encoder.pkl            # Label encoder
│   └── cattle_dataset.csv     # Dataset info
│
├── src/
│   ├── controllers/
│   │   └── aiController.js    # AI endpoints logic
│   ├── routes/
│   │   └── ai.js              # AI route definitions
│   ├── config/
│   │   └── database.js        # Database connection
│   └── server.js              # Main server file
│
├── sql/
│   └── ai_schema.sql          # Database schema
│
├── src/utils/
│   └── setupAI.js             # AI setup script
│
├── .env                        # Environment variables
├── .env.example                # Template
├── package.json               # Node dependencies
└── start_ai_service.bat       # Flask startup script
```

---

## 🔧 Troubleshooting

### Issue 1: Flask service not starting

```bash
# Error: "ModuleNotFoundError: No module named 'torch'"
# Solution:
pip install torch torchvision

# Verify installation:
python -c "import torch; print(torch.__version__)"
```

### Issue 2: Database connection error

```bash
# Error: "Connection refused"
# Solution:
# 1. Check MySQL is running:
mysql -u root -p -e "SELECT 1"

# 2. Verify credentials in .env
# 3. Check database exists:
mysql -u root -p -e "SHOW DATABASES LIKE 'pashudrishti';"
```

### Issue 3: Flask API not reachable from Node

```bash
# Error: "ECONNREFUSED 127.0.0.1:5001"
# Solution:
# 1. Ensure Flask is running on port 5001
# 2. Check Windows Firewall allows port 5001
# 3. Try: netstat -ano | findstr :5001

# Firewall fix (Windows Admin):
netsh advfirewall firewall add rule name="Flask AI" dir=in action=allow protocol=tcp localport=5001
```

### Issue 4: Image analysis fails

```bash
# Error: "CUDA out of memory" or "model not found"
# Solution:
# 1. Ensure model.pth exists in ai_service/
# 2. Check model file size (~50MB)
# 3. Verify encoder.pkl is present
# 4. Restart Flask service

ls -lh ai_service/model.pth
```

---

## 📊 Database Queries

### View all predictions

```sql
SELECT p.id, u.email, d.name as disease, p.confidence, p.created_at
FROM predictions p
JOIN users u ON p.user_id = u.id
JOIN diseases d ON p.disease_id = d.id
ORDER BY p.created_at DESC;
```

### View prediction history for specific user

```sql
SELECT d.name, p.confidence, p.created_at
FROM predictions p
JOIN diseases d ON p.disease_id = d.id
WHERE p.user_id = 1
ORDER BY p.created_at DESC;
```

### Delete old predictions (older than 90 days)

```sql
DELETE FROM predictions
WHERE created_at < DATE_SUB(NOW(), INTERVAL 90 DAY);
```

---

## 🎓 How It Works

### Disease Detection Flow

```
1. User uploads image
        ↓
2. Image sent to Flask API (/predict)
        ↓
3. Flask loads model.pth and processes image
        ↓
4. Model predicts: [Mastitis: 92.5%, Pneumonia: 5.2%, FMD: 2.3%]
        ↓
5. Flask returns confidence scores + treatment info
        ↓
6. Node saves prediction to MySQL database
        ↓
7. Response sent to frontend with full details
```

### Model Architecture

- **Model**: ResNet18 (Pre-trained on ImageNet)
- **Input**: 224×224 RGB image
- **Output**: 4 disease classes
- **Training Data**: ~500 cattle disease images
- **Accuracy**: ~92% on test set

---

## 📝 Adding New Diseases

### 1. Update Python Model (Retraining)

Edit `PashudristiAI.py` in pashudrishti_ai folder to include new disease classes.

### 2. Add to Database

```sql
INSERT INTO diseases (name, description, symptoms, treatment, duration, cost, severity)
VALUES (
  'New Disease Name',
  'Description',
  JSON_ARRAY('symptom1', 'symptom2'),
  'Treatment details',
  'Duration',
  'Cost range',
  'severity level'
);
```

### 3. Update Flask Disease Database

Edit `DISEASE_TREATMENTS` in `flask_app.py`:

```python
DISEASE_TREATMENTS = {
    'New Disease': {
        'hi': {
            'symptoms': ['लक्षण 1', 'लक्षण 2'],
            'treatment': 'इलाज की जानकारी',
            'duration': '7-10 दिन',
            'cost': '₹500-1000',
            'recommendations': [...]
        },
        'en': {...}
    }
}
```

---

## 🔐 Security Notes

1. **Image Validation**: Sanitize and validate all uploaded images
2. **API Authentication**: All endpoints require JWT token
3. **Rate Limiting**: Implement rate limiting to prevent abuse
4. **HTTPS**: Use HTTPS in production
5. **Model Security**: Keep model.pth secure (not exposed to public)

---

## 📞 Support

For issues or questions:
1. Check troubleshooting section
2. Review logs: `server/logs/` (if configured)
3. Check Flask service: `http://127.0.0.1:5001/health`
4. Check Node server: `http://127.0.0.1:5000/api/health`

---

## 📄 Additional Resources

- [PyTorch Documentation](https://pytorch.org/docs/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Express.js Guide](https://expressjs.com/)
- [MySQL Documentation](https://dev.mysql.com/doc/)

---

**Last Updated**: May 8, 2026  
**Version**: 1.0.0
