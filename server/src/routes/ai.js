import express from 'express';
import multer from 'multer';
import { authMiddleware } from '../middleware/auth.js';
import {
  getChatResponse,
  analyzeImage,
  predictDisease,
  getTreatmentRecommendations,
  getVeterinaryAdvice,
  getPredictionHistory,
  getAllDiseases
} from '../controllers/aiController.js';

const router = express.Router();
const upload = multer({ storage: multer.memoryStorage() });

// Protect routes with authentication
router.use(authMiddleware);

// AI Chat endpoint
router.post('/chat', getChatResponse);

// Analyze image for disease detection
router.post('/analyze-image', upload.single('image'), analyzeImage);

// Predict disease based on symptoms
router.post('/predict-disease', predictDisease);

// Get treatment recommendations
router.post('/treatment-recommendations', getTreatmentRecommendations);

// Get veterinary advice
router.post('/veterinary-advice', getVeterinaryAdvice);

// Get user prediction history
router.get('/prediction-history', getPredictionHistory);
router.get('/prediction-history/:userId', getPredictionHistory);

// Get all diseases
router.get('/diseases', getAllDiseases);

export default router;
