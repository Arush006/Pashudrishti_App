import mysql from 'mysql2/promise';
import dotenv from 'dotenv';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const currentDirectory = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({
  path: path.resolve(currentDirectory, '../../.env')
});

// Create MySQL Connection Pool
const pool = mysql.createPool({
  host: process.env.DB_HOST || '127.0.0.1',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'pashudrishti',
  port: Number(process.env.DB_PORT || 3306),
  connectTimeout: 10000,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

// Test Database Connection
(async () => {
  const maxAttempts = 5;

  for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
    try {
      const connection = await pool.getConnection();
      console.log("✅ MySQL Connected Successfully");
      connection.release();
      return;
    } catch (error) {
      if (attempt === maxAttempts) {
        console.error("❌ Database Connection Failed:", error.message);
        return;
      }

      await new Promise(resolve => setTimeout(resolve, 2000));
    }
  }
})();

// Execute Query Function (IMPORTANT - Your controllers use this)
export const executeQuery = async (query, params = []) => {
  const connection = await pool.getConnection();
  try {
    const [rows] = await connection.execute(query, params);
    return rows;
  } catch (error) {
    console.error("Query Error:", error.message);
    throw error;
  } finally {
    connection.release();
  }
};

// Export pool if needed elsewhere
export default pool;