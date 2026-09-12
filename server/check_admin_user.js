import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const checkAdminUser = async () => {
  let connection;
  try {
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      database: 'pashudrishti'
    });

    console.log('✓ Connected to database\n');

    // Check admin user
    const [users] = await connection.execute(
      'SELECT id, name, email, role, password FROM users WHERE email = ?',
      ['admin@pashudrishti.com']
    );

    if (users.length === 0) {
      console.log('❌ Admin user not found');
    } else {
      const user = users[0];
      console.log('✓ Admin user found:');
      console.log(`  ID: ${user.id}`);
      console.log(`  Name: ${user.name}`);
      console.log(`  Email: ${user.email}`);
      console.log(`  Role: ${user.role}`);
      console.log(`  Password hash length: ${user.password.length}`);
      console.log(`  Password hash starts with: $${user.password.substring(1, 20)}...`);
    }

    // Check all users
    const [allUsers] = await connection.execute('SELECT id, email, role FROM users');
    console.log(`\n📊 Total users in database: ${allUsers.length}`);
    allUsers.forEach(u => {
      console.log(`  - ${u.email} (${u.role})`);
    });

    await connection.end();
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
};

checkAdminUser();
