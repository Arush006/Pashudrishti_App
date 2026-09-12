import mysql from 'mysql2/promise';
import dotenv from 'dotenv';
import readline from 'readline';

dotenv.config();

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

const question = (prompt) => new Promise((resolve) => {
  rl.question(prompt, resolve);
});

const cleanDatabase = async () => {
  let connection;
  try {
    // Create connection
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      database: 'pashudrishti'
    });

    console.log('✓ Connected to database');

    // Ask user what to clean
    console.log('\n🧹 Database Cleanup Tool');
    console.log('========================\n');
    console.log('What would you like to clean?\n');
    console.log('1. Delete ALL test cases only');
    console.log('2. Delete ALL test animals only');
    console.log('3. Delete ALL test users (except first admin/doctor)');
    console.log('4. Delete EVERYTHING (full reset)');
    console.log('5. Cancel\n');

    const choice = await question('Enter choice (1-5): ');

    let deleteQuery = '';
    let description = '';

    switch (choice) {
      case '1':
        // Delete all cases
        deleteQuery = 'DELETE FROM cases';
        description = 'Deleted all cases';
        break;

      case '2':
        // Delete all animals
        deleteQuery = 'DELETE FROM animals';
        description = 'Deleted all animals';
        break;

      case '3':
        // Delete users except first few admin/doctors
        deleteQuery = `DELETE FROM users WHERE role = 'user' OR (role = 'doctor' AND id > 2)`;
        description = 'Deleted test users';
        break;

      case '4':
        // Full reset - delete all data but keep tables
        const confirm = await question('\n⚠️  WARNING: This will delete ALL data. Type "YES" to confirm: ');
        if (confirm !== 'YES') {
          console.log('❌ Cancelled');
          rl.close();
          return;
        }
        console.log('\nDeleting all data...');
        
        await connection.query('DELETE FROM messages');
        console.log('  ✓ Deleted messages');
        
        await connection.query('DELETE FROM visit_requests');
        console.log('  ✓ Deleted visit requests');
        
        await connection.query('DELETE FROM notifications');
        console.log('  ✓ Deleted notifications');
        
        await connection.query('DELETE FROM cases');
        console.log('  ✓ Deleted cases');
        
        await connection.query('DELETE FROM doctors WHERE id > 2');
        console.log('  ✓ Deleted doctor profiles');
        
        await connection.query('DELETE FROM animals');
        console.log('  ✓ Deleted animals');
        
        await connection.query('DELETE FROM users WHERE id > 2');
        console.log('  ✓ Deleted test users');
        
        console.log('\n✅ Database cleaned successfully!');
        rl.close();
        return;

      case '5':
        console.log('❌ Cancelled');
        rl.close();
        return;

      default:
        console.log('❌ Invalid choice');
        rl.close();
        return;
    }

    // Confirm before deletion
    if (choice !== '4') {
      console.log(`\n⚠️  This will ${description}`);
      const confirm = await question('Continue? (yes/no): ');

      if (confirm.toLowerCase() !== 'yes') {
        console.log('❌ Cancelled');
        rl.close();
        return;
      }

      // Execute delete
      const [result] = await connection.query(deleteQuery);
      console.log(`\n✅ ${description}`);
      console.log(`   Rows affected: ${result.affectedRows}`);
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    if (connection) {
      await connection.end();
    }
    rl.close();
  }
};

// Run cleanup
console.log('Starting database cleanup...\n');
cleanDatabase().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
