import mysql from 'mysql2/promise';
import bcrypt from 'bcrypt';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const setupDatabase = async () => {
  let connection;
  try {
    // First, connect without a database to create it
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || ''
    });

    console.log('✓ Connected to MySQL');

    // Create database if it doesn't exist
    try {
      await connection.query('CREATE DATABASE IF NOT EXISTS pashudrishti');
      console.log('✓ Database created or already exists');
    } catch (error) {
      console.log('✓ Database already exists');
    }

    // Select the database
    await connection.query('USE pashudrishti');

    // Read and execute schema
    const schemaPath = path.join(__dirname, '../config/schema.sql');
    const schemaSql = fs.readFileSync(schemaPath, 'utf-8');
    
    // Split SQL statements and execute them
    const statements = schemaSql.split(';').filter(stmt => stmt.trim());
    for (const statement of statements) {
      if (statement.trim()) {
        try {
          // Use query() for both DDL and DML statements
          await connection.query(statement);
        } catch (error) {
          if (!error.message.includes('already exists')) {
            console.error('Error executing statement:', statement.substring(0, 50));
            console.error('Error details:', error.message);
          }
        }
      }
    }
    console.log('✓ Database tables created or already exist');

    // Insert demo users
    const demoUsers = [
      {
        name: 'Admin',
        email: 'admin@pashudrishti.com',
        password: 'password123',
        role: 'admin',
        phone: '+91 9999999999'
      },
      {
        name: 'Doctor',
        email: 'doctor@pashudrishti.com',
        password: 'password123',
        role: 'doctor',
        phone: '+91 9888888888'
      }
    ];

    console.log('\n📝 Inserting demo users...');

    for (const user of demoUsers) {
      try {
        // Check if user already exists
        const [existing] = await connection.execute(
          'SELECT id FROM users WHERE email = ?',
          [user.email]
        );

        if (existing.length > 0) {
          console.log(`  ⚠️  User with email ${user.email} already exists, skipping...`);
          continue;
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(user.password, 10);

        // Insert user
        await connection.execute(
          'INSERT INTO users (name, email, password, role, phone, created_at) VALUES (?, ?, ?, ?, ?, NOW())',
          [user.name, user.email, hashedPassword, user.role, user.phone]
        );

        console.log(`  ✓ Created user: ${user.email} (Role: ${user.role})`);
      } catch (error) {
        console.error(`  ❌ Error creating user ${user.email}:`, error.message);
      }
    }

    // If a doctor user exists, create a doctor profile for them
    try {
      const [doctorUser] = await connection.execute(
        'SELECT id FROM users WHERE email = ? AND role = ?',
        ['doctor@pashudrishti.com', 'doctor']
      );

      if (doctorUser.length > 0) {
        const userId = doctorUser[0].id;

        // Check if doctor profile already exists
        const [existingDoctor] = await connection.execute(
          'SELECT id FROM doctors WHERE user_id = ?',
          [userId]
        );

        if (existingDoctor.length === 0) {
          await connection.execute(
            'INSERT INTO doctors (user_id, specialization, license_number, status, approval_date) VALUES (?, ?, ?, ?, NOW())',
            [userId, 'General Veterinary Medicine', 'LIC-2024-001', 'approved']
          );
          console.log('  ✓ Created doctor profile');
        }
      }
    } catch (error) {
      console.error('Error creating doctor profile:', error.message);
    }

    console.log('\n✅ Database setup completed successfully!');

  } catch (error) {
    console.error('❌ Database setup failed:', error.message);
    process.exit(1);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
};

// Run setup
setupDatabase().then(() => {
  console.log('\nYou can now start the server with: npm start');
  process.exit(0);
}).catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
