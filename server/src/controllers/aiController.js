import { executeQuery } from '../config/database.js';
import { uploadImageBuffer } from '../config/cloudinary.js';

let extractResNetPredictions = null;
let runResNet = null;

try {
  const aiModule = await import('../../../Pashudrishti_Ai_2.0-main/PashuDrishti_AI_Deployment_Package_V1_JS_Fetch/integration/pashudrishti_ai.js');
  extractResNetPredictions = aiModule.extractResNetPredictions;
  runResNet = aiModule.runResNet;
} catch (error) {
  console.warn('AI integration module not found. AI features will be disabled until the external model package is added.');
  console.warn(error.message);
}

const ensureAiModuleAvailable = () => {
  if (!runResNet || !extractResNetPredictions) {
    throw new Error('AI model package is not available. Please add the external PashuDrishti AI integration folder or disable AI routes.');
  }
};

// ===================================
// 🔹 DATABASE HELPERS
// ===================================

// Save prediction to database
const savePrediction = async (userId, diseaseName, confidence, imageUrl, treatment) => {
  try {
    const query = `
      INSERT INTO ai_predictions (user_id, primary_disease, confidence, treatment, outcome, created_at)
      VALUES (?, ?, ?, ?, ?, NOW())
    `;

    const result = await executeQuery(query, [
      userId,
      diseaseName,
      confidence,
      JSON.stringify(treatment),
      'pending',
    ]);
    return result.insertId;
  } catch (error) {
    console.error('Error saving prediction:', error);
    throw error;
  }
};

// Get disease by name
const getDiseaseByName = async (diseaseName) => {
  try {
    const normalizedName = String(diseaseName).toLowerCase();
    const names = [diseaseName];

    if (normalizedName.includes('foot') && normalizedName.includes('mouth') || normalizedName === 'fmd') {
      names.push('FMD', 'Foot and Mouth Disease');
    }

    const placeholders = names.map(() => '?').join(', ');
    const query = `SELECT * FROM diseases WHERE name IN (${placeholders}) LIMIT 1`;
    const result = await executeQuery(query, names);
    return result.length > 0 ? result[0] : null;
  } catch (error) {
    console.error('Error fetching disease:', error);
    throw error;
  }
};

// Get user predictions history
const getUserPredictions = async (userId) => {
  try {
    const query = `
      SELECT id, user_id, primary_disease as disease_name, confidence, treatment, created_at
      FROM ai_predictions
      WHERE user_id = ?
      ORDER BY created_at DESC
      LIMIT 10
    `;

    const result = await executeQuery(query, [userId]);
    return result;
  } catch (error) {
    console.error('Error fetching predictions:', error);
    throw error;
  }
};



// ===================================
// 🔹 AI CHAT RESPONSE
// ===================================
export const getChatResponse = async (req, res) => {
  try {
    const { query, conversationHistory = [] } = req.body;
    const language = req.query.lang || 'en';

    // Real AI integration would require OpenAI API or similar service
    // For now, this endpoint requires proper AI service implementation
    return res.status(501).json({ 
      error: language === 'hi' ? 'AI चैट सेवा अभी उपलब्ध नहीं है' : 'AI Chat service is not yet available. Please contact a veterinarian.',
      message: language === 'hi' ? 'कृपया एक पशु चिकित्सक से संपर्क करें' : 'AI service requires proper implementation'
    });
  } catch (error) {
    console.error('Error in getChatResponse:', error);
    res.status(500).json({ 
      error: req.query.lang === 'hi' ? 'जवाब नहीं मिल सका' : 'Failed to get AI response' 
    });
  }
};

// ===================================
// 🔹 ANALYZE IMAGE FOR DISEASE
// ===================================
export const analyzeImage = async (req, res) => {
  try {
    const userId = req.user?.id || req.body.userId;
    const language = req.query.lang || 'en';

    if (!req.file) {
      return res.status(400).json({ 
        error: language === 'hi' ? 'कोई छवि नहीं' : 'No image provided' 
      });
    }

    ensureAiModuleAvailable();

    const imageUrl = await uploadImageBuffer(req.file.buffer, req.file.originalname);
    const rawResNetResult = await runResNet(imageUrl);
    const imagePredictions = extractResNetPredictions(rawResNetResult);

    if (imagePredictions.length === 0) {
      return res.status(502).json({
        error: language === 'hi'
          ? 'AI से कोई रोग पूर्वानुमान नहीं मिला'
          : 'The AI returned no disease predictions'
      });
    }

    const primaryPrediction = imagePredictions[0];
    const confidence = primaryPrediction.confidence <= 1
      ? primaryPrediction.confidence * 100
      : primaryPrediction.confidence;

    // Get disease info from database
    const disease = await getDiseaseByName(primaryPrediction.label);
    
    // Save prediction to database
    let predictionId = null;
    if (userId && disease) {
      predictionId = await savePrediction(
        userId,
        primaryPrediction.label,
        confidence,
        imageUrl,
        JSON.stringify(disease?.treatment || null)
      );
    }

    res.json({
      success: true,
      predictionId,
      analysis: `Disease Detection: ${primaryPrediction.label} (${confidence.toFixed(2)}% confidence)`,
      disease: primaryPrediction.label,
      confidence,
      top3: imagePredictions.slice(0, 3).map(prediction => ({
        disease: prediction.label,
        confidence: prediction.confidence <= 1
          ? prediction.confidence * 100
          : prediction.confidence
      })),
      treatment: disease?.treatment || null,
      knowledgeBase: disease ? {
        name: disease.name,
        description: disease.description,
        symptoms: typeof disease.symptoms === 'string'
          ? JSON.parse(disease.symptoms)
          : disease.symptoms,
        treatment: disease.treatment,
        duration: disease.duration,
        severity: disease.severity
      } : null,
      imageUrl,
      recommendation: language === 'hi' 
        ? 'तुरंत पशु चिकित्सक से संपर्क करें' 
        : 'Seek veterinary consultation immediately'
    });
  } catch (error) {
    console.error('Error in analyzeImage:', error);
    res.status(503).json({ 
      error: req.query.lang === 'hi' ? 'छवि विश्लेषण विफल' : 'Failed to analyze image',
      details: error.message,
      note: 'AI model package is not available in this environment. Add the external AI integration folder to enable image analysis.'
    });
  }
};

// ===================================
// 🔹 PREDICT DISEASE FROM SYMPTOMS
// ===================================
export const predictDisease = async (req, res) => {
  try {
    const { symptoms = [], animalType = 'cow' } = req.body;
    const language = req.query.lang || 'en';

    if (!symptoms || symptoms.length === 0) {
      return res.status(400).json({
        error: language === 'hi' ? 'कृपया लक्षण प्रदान करें' : 'Please provide symptoms'
      });
    }

    // Get all diseases from database - only return real data
    const diseaseQuery = 'SELECT id, name, description, treatment FROM diseases WHERE treatment IS NOT NULL AND treatment != "" LIMIT 20';
    const diseases = await executeQuery(diseaseQuery);

    if (diseases.length === 0) {
      return res.json({
        success: true,
        predictions: [],
        message: language === 'hi'
          ? 'कोई रोग डेटा उपलब्ध नहीं है। कृपया पशु चिकित्सक से संपर्क करें।'
          : 'No disease data available. Please consult a veterinarian.',
        note: language === 'hi' ? 'व्यक्तिगत निदान के लिए डॉक्टर से मिलें' : 'Contact a veterinarian for proper diagnosis'
      });
    }

    const predictions = diseases.map(disease => ({
      id: disease.id,
      name: disease.name,
      description: disease.description || 'No description available',
      treatment: disease.treatment
    }));

    res.json({
      success: true,
      predictions,
      total: predictions.length,
      message: language === 'hi'
        ? 'डेटाबेस से रोग की जानकारी'
        : 'Disease information from database'
    });
  } catch (error) {
    console.error('Error in predictDisease:', error);
    res.status(500).json({ 
      error: req.query.lang === 'hi' ? 'रोग जानकारी प्राप्त करने में विफल' : 'Failed to get disease information',
      details: error.message
    });
  }
};

// ===================================
// 🔹 GET TREATMENT RECOMMENDATIONS
// ===================================
export const getTreatmentRecommendations = async (req, res) => {
  try {
    const { disease, animalType } = req.body;
    const language = req.query.lang || 'en';

    if (!disease) {
      return res.status(400).json({
        error: language === 'hi' ? 'कृपया रोग का नाम प्रदान करें' : 'Please provide disease name'
      });
    }

    // Get disease info from database - only real data
    const diseaseInfo = await getDiseaseByName(disease);

    if (!diseaseInfo) {
      return res.status(404).json({ 
        error: language === 'hi' ? 'रोग डेटाबेस में नहीं मिला' : 'Disease not found in database',
        note: language === 'hi' ? 'पशु चिकित्सक से परामर्श करें' : 'Please consult a veterinarian'
      });
    }

    // Return only database information - no mock recommendations
    res.json({
      success: true,
      disease: diseaseInfo.name,
      description: diseaseInfo.description || language === 'hi' ? 'विवरण उपलब्ध नहीं' : 'No description available',
      treatment: diseaseInfo.treatment || language === 'hi' ? 'पशु चिकित्सक से परामर्श करें' : 'Consult a veterinarian for treatment',
      message: language === 'hi' ? 'डेटाबेस से उपचार जानकारी' : 'Treatment information from database'
    });
  } catch (error) {
    console.error('Error in getTreatmentRecommendations:', error);
    res.status(500).json({ 
      error: language === 'hi' ? 'उपचार जानकारी प्राप्त करने में विफल' : 'Failed to get treatment information',
      details: error.message
    });
  }
};

// ===================================
// 🔹 GET USER PREDICTION HISTORY
// ===================================
export const getPredictionHistory = async (req, res) => {
  try {
    const userId = req.user?.id || req.params.userId;
    const language = req.query.lang || 'en';

    if (!userId) {
      return res.status(400).json({ error: language === 'hi' ? 'उपयोगकर्ता आईडी आवश्यक है' : 'User ID required' });
    }

    const predictions = await getUserPredictions(userId);

    res.json({
      success: true,
      predictions,
      total: predictions.length,
      message: language === 'hi' ? 'पूर्वानुमान इतिहास प्राप्त हुआ' : 'Prediction history retrieved successfully'
    });
  } catch (error) {
    console.error('Error in getPredictionHistory:', error);
    res.status(500).json({
      error: language === 'hi' ? 'पूर्वानुमान इतिहास प्राप्त करने में विफल' : 'Failed to fetch prediction history',
      details: error.message
    });
  }
};

// ===================================
// 🔹 GET ALL DISEASES
// ===================================
export const getAllDiseases = async (req, res) => {
  try {
    const language = req.query.lang || 'en';
    const diseases = await executeQuery('SELECT id, name, description, treatment FROM diseases ORDER BY name ASC');

    const response = {
      success: true,
      diseases,
      total: diseases.length,
      message: language === 'hi' ? 'बीमारियों की सूची प्राप्त हुई' : 'Disease list retrieved successfully'
    };

    res.json(response);
  } catch (error) {
    console.error('Error in getAllDiseases:', error);
    res.status(500).json({
      error: language === 'hi' ? 'बीमारियों को प्राप्त करने में विफल' : 'Failed to fetch diseases',
      details: error.message
    });
  }
};

// ===================================
// 🔹 GET VETERINARY ADVICE
// ===================================
export const getVeterinaryAdvice = async (req, res) => {
  try {
    const { query, context } = req.body;
    const language = req.query.lang || 'en';

    if (!query) {
      return res.status(400).json({
        error: language === 'hi' ? 'कृपया अपना सवाल दर्ज करें' : 'Please provide your question'
      });
    }

    // Veterinary advice requires real professional consultation - not mock data
    // This should connect to actual veterinarian advice database or AI service
    return res.status(501).json({
      success: false,
      error: language === 'hi' ? 'पशु चिकित्सा सलाह सेवा अभी उपलब्ध नहीं है' : 'Veterinary advice service is not yet available',
      message: language === 'hi' 
        ? 'कृपया एक योग्य पशु चिकित्सक से सलाह लें'
        : 'Please consult a qualified veterinarian for professional advice',
      contactVet: language === 'hi' ? 'अपने क्षेत्र के पशु चिकित्सक को ढूंढें' : 'Find a veterinarian in your area'
    });
  } catch (error) {
    console.error('Error in getVeterinaryAdvice:', error);
    res.status(500).json({ 
      error: req.query.lang === 'hi' ? 'सलाह प्राप्त करने में त्रुटि' : 'Failed to get advice',
      details: error.message
    });
  }
};


