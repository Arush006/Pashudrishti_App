import mysql from 'mysql2/promise';
import bcrypt from 'bcrypt';
import dotenv from 'dotenv';

dotenv.config();

const addAdminUser = async () => {
  let connection;
  try {
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      database: 'pashudrishti'
    });

    console.log('✓ Connected to database');

    // Check if admin user already exists
    const [existing] = await connection.execute(
      'SELECT id FROM users WHERE email = ?',
      ['admin@pashudrishti.com']
    );

    if (existing.length > 0) {
      console.log('✓ Admin user already exists');
      await connection.end();
      return;
    }

    // Hash password
    const hashedPassword = await bcrypt.hash('password123', 10);

    // Insert admin user
    await connection.execute(
      'INSERT INTO users (name, email, password, role, phone, created_at) VALUES (?, ?, ?, ?, ?, NOW())',
      ['Admin', 'admin@pashudrishti.com', hashedPassword, 'admin', '+91 9999999999']
    );

    console.log('✓ Admin user created successfully');
    console.log('  Email: admin@pashudrishti.com');
    console.log('  Password: password123');

    await connection.end();
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
};

addAdminUser();
