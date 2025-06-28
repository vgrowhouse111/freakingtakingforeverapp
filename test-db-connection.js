const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || '127.0.0.1',
  database: process.env.DB_NAME || 'wavetype.xyz',
  password: process.env.DB_PASSWORD || '',
  port: parseInt(process.env.DB_PORT || '5432', 10),
});

async function testConnection() {
  const client = await pool.connect();
  try {
    console.log('Successfully connected to the database');
    
    // Test query to check if the images table exists
    const result = await client.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'images'
      );
    `);
    
    console.log('Images table exists:', result.rows[0].exists);
    
    // If table exists, count the number of images
    if (result.rows[0].exists) {
      const countResult = await client.query('SELECT COUNT(*) FROM images');
      console.log(`Number of images in database: ${countResult.rows[0].count}`);
    }
    
  } catch (err) {
    console.error('Error testing database connection:', err);
  } finally {
    client.release();
    await pool.end();
  }
}

testConnection();
