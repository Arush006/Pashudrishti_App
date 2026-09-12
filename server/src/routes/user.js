import express from 'express';
import { authMiddleware } from '../middleware/auth.js';
import { roleMiddleware } from '../middleware/role.js';
import {
  getUserDashboard,
  submitCase,
  getMyCases,
  getNearbyDoctors,
  getProfile,
  updateProfile,
  sendMessage,
  getMessages
} from '../controllers/userController.js';

const router = express.Router();

router.use(authMiddleware);
router.use(roleMiddleware(['user']));

router.get('/dashboard', getUserDashboard);
router.post('/cases', submitCase);
router.get('/cases', getMyCases);
router.get('/doctors', getNearbyDoctors);
router.get('/profile', getProfile);
router.put('/profile', updateProfile);
router.post('/messages', sendMessage);
router.get('/messages/:caseId', getMessages);

export default router;
