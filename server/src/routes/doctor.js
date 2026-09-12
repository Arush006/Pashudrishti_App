import express from 'express';
import { authMiddleware } from '../middleware/auth.js';
import { roleMiddleware } from '../middleware/role.js';
import {
  getDoctorDashboard,
  getCaseRequests,
  acceptCase,
  addDiagnosis,
  markCaseResolved,
  requestPhysicalVisit,
  getCaseHistory
} from '../controllers/doctorController.js';

const router = express.Router();

router.use(authMiddleware);
router.use(roleMiddleware(['doctor']));

router.get('/dashboard', getDoctorDashboard);
router.get('/case-requests', getCaseRequests);
router.put('/cases/:caseId/accept', acceptCase);
router.put('/cases/:caseId/diagnosis', addDiagnosis);
router.put('/cases/:caseId/resolve', markCaseResolved);
router.post('/cases/:caseId/physical-visit', requestPhysicalVisit);
router.get('/cases', getCaseHistory);

export default router;
