import { executeQuery } from '../config/database.js';

export const getDashboardStats = async (req, res) => {
  try {
    const totalUsers = await executeQuery('SELECT COUNT(*) as count FROM users WHERE role = "user"');
    const totalDoctors = await executeQuery('SELECT COUNT(*) as count FROM doctors WHERE status = "approved"');
    const totalCases = await executeQuery('SELECT COUNT(*) as count FROM cases');
    const activeCases = await executeQuery('SELECT COUNT(*) as count FROM cases WHERE status = "pending"');
    const resolvedCases = await executeQuery('SELECT COUNT(*) as count FROM cases WHERE status = "resolved"');

    const casesByMonth = await executeQuery(
      `SELECT DATE_FORMAT(created_at, '%Y-%m') as month, COUNT(*) as count 
       FROM cases 
       GROUP BY DATE_FORMAT(created_at, '%Y-%m') 
       ORDER BY month DESC LIMIT 12`
    );

    const diseaseStats = await executeQuery(
      `SELECT disease_name, COUNT(*) as count 
       FROM cases 
       WHERE disease_name IS NOT NULL 
       GROUP BY disease_name 
       LIMIT 10`
    );

    res.json({
      totalUsers: totalUsers[0].count,
      totalDoctors: totalDoctors[0].count,
      totalCases: totalCases[0].count,
      activeCases: activeCases[0].count,
      resolvedCases: resolvedCases[0].count,
      casesByMonth,
      diseaseStats
    });
  } catch (error) {
    console.error('Dashboard stats error:', error);
    res.status(500).json({ error: 'Failed to fetch dashboard stats' });
  }
};

export const getDoctors = async (req, res) => {
  try {
    const doctors = await executeQuery(
      `SELECT d.id, u.name, u.email, u.phone, d.specialization, d.status, d.approval_date, d.created_at
       FROM doctors d
       JOIN users u ON d.user_id = u.id
       ORDER BY d.created_at DESC`
    );

    res.json(doctors);
  } catch (error) {
    console.error('Get doctors error:', error);
    res.status(500).json({ error: 'Failed to fetch doctors' });
  }
};

export const approveDoctors = async (req, res) => {
  try {
    const { doctorId } = req.params;

    await executeQuery(
      'UPDATE doctors SET status = ?, approval_date = NOW() WHERE id = ?',
      ['approved', doctorId]
    );

    res.json({ message: 'Doctor approved successfully' });
  } catch (error) {
    console.error('Approve doctor error:', error);
    res.status(500).json({ error: 'Failed to approve doctor' });
  }
};

export const suspendDoctor = async (req, res) => {
  try {
    const { doctorId } = req.params;

    await executeQuery(
      'UPDATE doctors SET status = ? WHERE id = ?',
      ['suspended', doctorId]
    );

    res.json({ message: 'Doctor suspended successfully' });
  } catch (error) {
    console.error('Suspend doctor error:', error);
    res.status(500).json({ error: 'Failed to suspend doctor' });
  }
};

export const getUsers = async (req, res) => {
  try {
    const users = await executeQuery(
      `SELECT id, name, email, phone, status, created_at 
       FROM users 
       WHERE role = "user" 
       ORDER BY created_at DESC`
    );

    res.json(users);
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
};

export const suspendUser = async (req, res) => {
  try {
    const { userId } = req.params;

    await executeQuery(
      'UPDATE users SET status = ? WHERE id = ?',
      ['suspended', userId]
    );

    res.json({ message: 'User suspended successfully' });
  } catch (error) {
    console.error('Suspend user error:', error);
    res.status(500).json({ error: 'Failed to suspend user' });
  }
};

export const getDiseases = async (req, res) => {
  try {
    const diseases = await executeQuery(
      'SELECT * FROM diseases ORDER BY name ASC'
    );

    res.json(diseases);
  } catch (error) {
    console.error('Get diseases error:', error);
    res.status(500).json({ error: 'Failed to fetch diseases' });
  }
};

export const addDisease = async (req, res) => {
  try {
    const { name, description, treatment } = req.body;

    await executeQuery(
      'INSERT INTO diseases (name, description, treatment) VALUES (?, ?, ?)',
      [name, description, treatment]
    );

    res.status(201).json({ message: 'Disease added successfully' });
  } catch (error) {
    console.error('Add disease error:', error);
    res.status(500).json({ error: 'Failed to add disease' });
  }
};

export const broadcastNotification = async (req, res) => {
  try {
    const { title, message, target_role } = req.body;

    await executeQuery(
      'INSERT INTO notifications (title, message, target_role, created_at) VALUES (?, ?, ?, NOW())',
      [title, message, target_role]
    );

    res.status(201).json({ message: 'Notification sent successfully' });
  } catch (error) {
    console.error('Broadcast notification error:', error);
    res.status(500).json({ error: 'Failed to send notification' });
  }
};
