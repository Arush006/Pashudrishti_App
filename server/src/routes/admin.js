import express from 'express';
import { authMiddleware } from '../middleware/auth.js';
import { roleMiddleware } from '../middleware/role.js';
import {
  getDashboardStats,
  getDoctors,
  approveDoctors,
  suspendDoctor,
  getUsers,
  suspendUser,
  getDiseases,
  addDisease,
  broadcastNotification
} from '../controllers/adminController.js';

const router = express.Router();

router.use(authMiddleware);
router.use(roleMiddleware(['admin']));

router.get('/stats', getDashboardStats);
router.get('/doctors', getDoctors);
router.put('/doctors/:doctorId/approve', approveDoctors);
router.put('/doctors/:doctorId/suspend', suspendDoctor);
router.get('/users', getUsers);
router.put('/users/:userId/suspend', suspendUser);
router.get('/diseases', getDiseases);
router.post('/diseases', addDisease);
router.post('/notifications', broadcastNotification);

export default router;
