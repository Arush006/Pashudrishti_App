import { executeQuery } from '../config/database.js';

export const getDoctorDashboard = async (req, res) => {
  try {
    const userId = req.user.id;

    const assignedCases = await executeQuery(
      `SELECT COUNT(*) as count FROM cases WHERE assigned_doctor_id = (SELECT id FROM doctors WHERE user_id = ?)`,
      [userId]
    );

    const resolvedCases = await executeQuery(
      `SELECT COUNT(*) as count FROM cases WHERE assigned_doctor_id = (SELECT id FROM doctors WHERE user_id = ?) AND status = "resolved"`,
      [userId]
    );

    const pendingCases = await executeQuery(
      `SELECT COUNT(*) as count FROM cases WHERE assigned_doctor_id = (SELECT id FROM doctors WHERE user_id = ?) AND status = "pending"`,
      [userId]
    );

    const cureRate = assignedCases[0].count > 0 
      ? Math.round((resolvedCases[0].count / assignedCases[0].count) * 100) 
      : 0;

    const monthlyPerformance = await executeQuery(
      `SELECT DATE_FORMAT(created_at, '%Y-%m') as month, COUNT(*) as count 
       FROM cases 
       WHERE assigned_doctor_id = (SELECT id FROM doctors WHERE user_id = ?) AND status = "resolved"
       GROUP BY DATE_FORMAT(created_at, '%Y-%m') 
       LIMIT 12`,
      [userId]
    );

    res.json({
      assignedCases: assignedCases[0].count,
      resolvedCases: resolvedCases[0].count,
      pendingCases: pendingCases[0].count,
      cureRate,
      monthlyPerformance
    });
  } catch (error) {
    console.error('Doctor dashboard error:', error);
    res.status(500).json({ error: 'Failed to fetch dashboard' });
  }
};

export const getCaseRequests = async (req, res) => {
  try {
    const userId = req.user.id;

    const cases = await executeQuery(
      `SELECT c.*, u.name as user_name, u.phone, a.animal_type, a.age, a.weight, a.location
       FROM cases c
       JOIN users u ON c.user_id = u.id
       JOIN animals a ON c.animal_id = a.id
       WHERE c.assigned_doctor_id IS NULL
       ORDER BY c.created_at DESC`
    );

    res.json(cases);
  } catch (error) {
    console.error('Get case requests error:', error);
    res.status(500).json({ error: 'Failed to fetch case requests' });
  }
};

export const acceptCase = async (req, res) => {
  try {
    const { caseId } = req.params;
    const userId = req.user.id;

    const doctor = await executeQuery(
      'SELECT id FROM doctors WHERE user_id = ?',
      [userId]
    );

    if (doctor.length === 0) {
      return res.status(404).json({ error: 'Doctor profile not found' });
    }

    await executeQuery(
      'UPDATE cases SET assigned_doctor_id = ?, status = "in_progress" WHERE id = ?',
      [doctor[0].id, caseId]
    );

    res.json({ message: 'Case accepted successfully' });
  } catch (error) {
    console.error('Accept case error:', error);
    res.status(500).json({ error: 'Failed to accept case' });
  }
};

export const addDiagnosis = async (req, res) => {
  try {
    const { caseId } = req.params;
    const { diagnosis, medication, notes } = req.body;

    await executeQuery(
      'UPDATE cases SET diagnosis = ?, prescribed_medicine = ?, notes = ? WHERE id = ?',
      [diagnosis, medication, notes, caseId]
    );

    res.json({ message: 'Diagnosis added successfully' });
  } catch (error) {
    console.error('Add diagnosis error:', error);
    res.status(500).json({ error: 'Failed to add diagnosis' });
  }
};

export const markCaseResolved = async (req, res) => {
  try {
    const { caseId } = req.params;

    await executeQuery(
      'UPDATE cases SET status = ? WHERE id = ?',
      ['resolved', caseId]
    );

    res.json({ message: 'Case marked as resolved' });
  } catch (error) {
    console.error('Mark case resolved error:', error);
    res.status(500).json({ error: 'Failed to mark case as resolved' });
  }
};

export const requestPhysicalVisit = async (req, res) => {
  try {
    const { caseId } = req.params;
    const { date, time, location } = req.body;

    await executeQuery(
      'INSERT INTO visit_requests (case_id, recommended_date, recommended_time, location) VALUES (?, ?, ?, ?)',
      [caseId, date, time, location]
    );

    res.status(201).json({ message: 'Physical visit requested' });
  } catch (error) {
    console.error('Request physical visit error:', error);
    res.status(500).json({ error: 'Failed to request physical visit' });
  }
};

export const getCaseHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    const { search } = req.query;

    let query = `SELECT c.*, u.name as user_name, a.animal_type
                 FROM cases c
                 JOIN users u ON c.user_id = u.id
                 JOIN animals a ON c.animal_id = a.id
                 WHERE c.assigned_doctor_id = (SELECT id FROM doctors WHERE user_id = ?)`;
    
    const params = [userId];

    if (search) {
      query += ` AND (u.name LIKE ? OR a.animal_type LIKE ? OR c.disease_name LIKE ?)`;
      params.push(`%${search}%`, `%${search}%`, `%${search}%`);
    }

    query += ' ORDER BY c.created_at DESC';

    const cases = await executeQuery(query, params);

    res.json(cases);
  } catch (error) {
    console.error('Get case history error:', error);
    res.status(500).json({ error: 'Failed to fetch case history' });
  }
};
