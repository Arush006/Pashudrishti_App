import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const migrateDatabase = async () => {
  let connection;
  try {
    connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: ''
    });

    console.log('✓ Connected to MySQL');

    await connection.query('USE pashudrishti');

    // Add password reset columns if they don't exist
    const queries = [
      `ALTER TABLE users ADD COLUMN password_reset_token VARCHAR(255) DEFAULT NULL`,
      `ALTER TABLE users ADD COLUMN password_reset_expire DATETIME DEFAULT NULL`
    ];

    for (const query of queries) {
      try {
        await connection.query(query);
        console.log('✓ Migration successful: ' + query.substring(0, 50) + '...');
      } catch (error) {
        if (error.message.includes('Duplicate column')) {
          console.log('✓ Column already exists');
        } else {
          throw error;
        }
      }
    }

    console.log('\n✓ Database migration completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('✗ Database migration failed:', error.message);
    process.exit(1);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
};

migrateDatabase();
