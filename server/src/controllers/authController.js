import bcrypt from 'bcrypt';
import crypto from 'crypto';
import { generateToken } from '../middleware/auth.js';
import { executeQuery } from '../config/database.js';
import { sendPasswordResetEmail } from '../config/email.js';

export const register = async (req, res) => {
  try {
    const { name, email, password, role, phone } = req.body;

    // Validate required fields
    if (!email || !password || !name) {
      return res.status(400).json({ error: 'Name, email, and password are required' });
    }

    // Normalize email (lowercase)
    const normalizedEmail = email.toLowerCase().trim();

    // Check if user exists
    const existingUser = await executeQuery(
      'SELECT id FROM users WHERE LOWER(email) = ?',
      [normalizedEmail]
    );

    if (existingUser.length > 0) {
      console.log(`Registration attempt with existing email: ${normalizedEmail}`);
      return res.status(400).json({ error: 'User already exists' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert user
    await executeQuery(
      'INSERT INTO users (name, email, password, role, phone, created_at) VALUES (?, ?, ?, ?, ?, NOW())',
      [name.trim(), normalizedEmail, hashedPassword, role || 'user', phone || '']
    );

    const newUser = await executeQuery(
      'SELECT id, name, email, role FROM users WHERE LOWER(email) = ?',
      [normalizedEmail]
    );

    if (newUser.length === 0) {
      return res.status(500).json({ error: 'User creation failed' });
    }

    const token = generateToken(newUser[0]);

    console.log(`New user registered: ${normalizedEmail} (role: ${role})`);

    res.status(201).json({
      message: 'User registered successfully',
      user: newUser[0],
      token
    });
  } catch (error) {
    console.error('Register error:', error.message);
    res.status(500).json({ error: 'Registration failed - ' + error.message });
  }
};

export const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Normalize email (lowercase)
    const normalizedEmail = email.toLowerCase().trim();

    // Find user (case-insensitive)
    const users = await executeQuery(
      'SELECT * FROM users WHERE LOWER(email) = ?',
      [normalizedEmail]
    );

    if (users.length === 0) {
      console.log(`Login failed: User not found - ${normalizedEmail}`);
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = users[0];

    // Check password
    try {
      const passwordMatch = await bcrypt.compare(password, user.password);

      if (!passwordMatch) {
        console.log(`Login failed: Wrong password for - ${normalizedEmail}`);
        return res.status(401).json({ error: 'Invalid credentials' });
      }
    } catch (bcryptError) {
      console.error(`Bcrypt error for ${normalizedEmail}:`, bcryptError.message);
      console.error(`Password hash: ${user.password}`);
      console.error(`Password hash type: ${typeof user.password}`);
      return res.status(500).json({ error: 'Password verification failed: ' + bcryptError.message });
    }

    // Check if doctor is approved
    if (user.role === 'doctor') {
      const doctors = await executeQuery(
        'SELECT * FROM doctors WHERE user_id = ?',
        [user.id]
      );

      if (doctors.length > 0 && doctors[0].status !== 'approved') {
        return res.status(403).json({ error: 'Doctor account not approved yet' });
      }
    }

    const token = generateToken(user);

    console.log(`User logged in: ${normalizedEmail} (role: ${user.role})`);

    res.json({
      message: 'Login successful',
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role
      },
      token
    });
  } catch (error) {
    console.error('Login error:', error.message);
    res.status(500).json({ error: 'Login failed - ' + error.message });
  }
};

export const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
    }

    const normalizedEmail = email.toLowerCase().trim();

    // Check if user exists
    const users = await executeQuery(
      'SELECT id, name, email FROM users WHERE LOWER(email) = ?',
      [normalizedEmail]
    );

    if (users.length === 0) {
      // Don't reveal if email exists (security)
      return res.status(200).json({ 
        message: 'If this email exists, a password reset link has been sent' 
      });
    }

    const user = users[0];

    // Generate reset token
    const resetToken = crypto.randomBytes(32).toString('hex');
    const hashedToken = crypto
      .createHash('sha256')
      .update(resetToken)
      .digest('hex');

    // Set token expiration (1 hour)
    const expiration = new Date(Date.now() + 60 * 60 * 1000);

    // Update user with reset token
    await executeQuery(
      'UPDATE users SET password_reset_token = ?, password_reset_expire = ? WHERE id = ?',
      [hashedToken, expiration, user.id]
    );

    // Send email with reset link
    try {
      await sendPasswordResetEmail(user.email, resetToken);
      console.log(`Password reset email sent to ${user.email}`);
    } catch (emailError) {
      console.error('Email sending failed:', emailError.message);
      // Clear the reset token if email fails
      await executeQuery(
        'UPDATE users SET password_reset_token = NULL, password_reset_expire = NULL WHERE id = ?',
        [user.id]
      );
      return res.status(500).json({ error: 'Failed to send reset email. Please try again.' });
    }

    res.status(200).json({ 
      message: 'If this email exists, a password reset link has been sent' 
    });
  } catch (error) {
    console.error('Forgot password error:', error.message);
    res.status(500).json({ error: 'An error occurred. Please try again.' });
  }
};

export const resetPassword = async (req, res) => {
  try {
    const { token, newPassword } = req.body;

    if (!token || !newPassword) {
      return res.status(400).json({ error: 'Token and new password are required' });
    }

    // Hash the token to compare with stored token
    const hashedToken = crypto
      .createHash('sha256')
      .update(token)
      .digest('hex');

    // Find user with valid reset token
    const users = await executeQuery(
      'SELECT id, name, email FROM users WHERE password_reset_token = ? AND password_reset_expire > NOW()',
      [hashedToken]
    );

    if (users.length === 0) {
      return res.status(400).json({ error: 'Invalid or expired reset token' });
    }

    const user = users[0];

    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update password and clear reset token
    await executeQuery(
      'UPDATE users SET password = ?, password_reset_token = NULL, password_reset_expire = NULL WHERE id = ?',
      [hashedPassword, user.id]
    );

    console.log(`Password reset successful for user: ${user.email}`);

    res.status(200).json({ 
      message: 'Password has been reset successfully. You can now login with your new password.' 
    });
  } catch (error) {
    console.error('Reset password error:', error.message);
    res.status(500).json({ error: 'An error occurred while resetting password' });
  }
};
