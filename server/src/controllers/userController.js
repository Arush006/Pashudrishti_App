import { executeQuery } from '../config/database.js';

export const getUserDashboard = async (req, res) => {
  try {
    const userId = req.user.id;

    const totalCases = await executeQuery(
      'SELECT COUNT(*) as count FROM cases WHERE user_id = ?',
      [userId]
    );

    const pendingCases = await executeQuery(
      'SELECT COUNT(*) as count FROM cases WHERE user_id = ? AND status = "pending"',
      [userId]
    );

    const resolvedCases = await executeQuery(
      'SELECT COUNT(*) as count FROM cases WHERE user_id = ? AND status = "resolved"',
      [userId]
    );

    const nearbyDoctors = await executeQuery(
      `SELECT d.id, u.name, u.phone, d.specialization, d.rating, d.cases_handled
       FROM doctors d
       JOIN users u ON d.user_id = u.id
       WHERE d.status = "approved"
       ORDER BY d.rating DESC
       LIMIT 5`
    );

    res.json({
      totalCases: totalCases[0].count,
      pendingCases: pendingCases[0].count,
      resolvedCases: resolvedCases[0].count,
      nearbyDoctors
    });
  } catch (error) {
    console.error('User dashboard error:', error);
    res.status(500).json({ error: 'Failed to fetch dashboard' });
  }
};

export const submitCase = async (req, res) => {
  try {
    const { animalType, breed, age, weight, location, fever, appetite, lesions, notes, imageUrl, aiAnalysis } = req.body;
    const userId = req.user.id;

    // Validate required fields
    if (!animalType || !age || !weight || !location || !fever || !appetite || !lesions) {
      return res.status(400).json({ error: 'All required fields must be filled' });
    }

    const safeImageUrl = String(imageUrl || '').slice(0, 500);

    // Insert animal (without breed - will add column later)
    const animalResult = await executeQuery(
      'INSERT INTO animals (animal_type, age, weight, location) VALUES (?, ?, ?, ?)',
      [animalType, parseInt(age, 10) || null, parseFloat(weight) || null, location]
    );

    const animalId = animalResult.insertId;

    // Create symptoms string from clinical signs
    const symptoms = `Fever: ${fever}, Appetite: ${appetite}, Lesions: ${lesions}`;

    // Insert case with AI analysis
    const caseResult = await executeQuery(
      `INSERT INTO cases (user_id, animal_id, symptoms, image_url, notes, status, disease_name, created_at)
       VALUES (?, ?, ?, ?, ?, "pending", ?, NOW())`,
      [
        userId,
        animalId,
        symptoms,
        safeImageUrl || 'https://via.placeholder.com/400',
        notes || null,
        aiAnalysis?.disease_name || 'Pending Review'
      ]
    );

    res.status(201).json({
      success: true,
      message: 'Case submitted successfully with AI analysis',
      caseId: caseResult.insertId,
      aiAnalysis: aiAnalysis || { disease_name: 'Pending Review', confidence: 0 }
    });
  } catch (error) {
    console.error('Submit case error:', error);
    res.status(500).json({ success: false, error: 'Failed to submit case: ' + error.message });
  }
};



export const getMyCases = async (req, res) => {
  try {
    const userId = req.user.id;

    const cases = await executeQuery(
      `SELECT c.id, c.symptoms, c.status, c.disease_name, c.created_at, a.animal_type, a.location,
              d.user_id as doctor_user_id
       FROM cases c
       LEFT JOIN animals a ON c.animal_id = a.id
       LEFT JOIN doctors d ON c.assigned_doctor_id = d.id
       WHERE c.user_id = ?
       ORDER BY c.created_at DESC`,
      [userId]
    );

    res.json(cases);
  } catch (error) {
    console.error('Get my cases error:', error);
    res.status(500).json({ error: 'Failed to fetch cases' });
  }
};

export const getNearbyDoctors = async (req, res) => {
  try {
    const doctors = await executeQuery(
      `SELECT d.id, u.name, u.phone, d.specialization, d.rating, 
              d.cases_handled, d.created_at
       FROM doctors d
       JOIN users u ON d.user_id = u.id
       WHERE d.status = "approved"
       ORDER BY ABS(d.rating) DESC`
    );

    res.json(doctors);
  } catch (error) {
    console.error('Get nearby doctors error:', error);
    res.status(500).json({ error: 'Failed to fetch doctors' });
  }
};

export const getProfile = async (req, res) => {
  try {
    const userId = req.user.id;

    const users = await executeQuery(
      'SELECT id, name, email, phone, status, created_at FROM users WHERE id = ?',
      [userId]
    );

    res.json(users[0]);
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
};

export const updateProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const { name, phone } = req.body;

    await executeQuery(
      'UPDATE users SET name = ?, phone = ? WHERE id = ?',
      [name, phone, userId]
    );

    res.json({ message: 'Profile updated successfully' });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ error: 'Failed to update profile' });
  }
};

export const sendMessage = async (req, res) => {
  try {
    const { caseId, recipientId, message } = req.body;
    const senderId = req.user.id;

    await executeQuery(
      'INSERT INTO messages (case_id, sender_id, recipient_id, message, created_at) VALUES (?, ?, ?, ?, NOW())',
      [caseId, senderId, recipientId, message]
    );

    res.status(201).json({ message: 'Message sent successfully' });
  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({ error: 'Failed to send message' });
  }
};

export const getMessages = async (req, res) => {
  try {
    const { caseId } = req.params;
    const userId = req.user.id;

    const messages = await executeQuery(
      `SELECT m.*, u.name as sender_name FROM messages m
       JOIN users u ON m.sender_id = u.id
       WHERE m.case_id = ?
       ORDER BY m.created_at ASC`,
      [caseId]
    );

    res.json(messages);
  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({ error: 'Failed to fetch messages' });
  }
};
