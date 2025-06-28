const { Pool } = require('pg');

// Common database configurations to test
const configs = [
  {
    name: 'Default PostgreSQL credentials',
    user: 'postgres',
    password: 'postgres',
    host: 'localhost',
    port: 5432,
    database: 'postgres'
  },
  {
    name: 'Empty password',
    user: 'postgres',
    password: '',
    host: 'localhost',
    port: 5432,
    database: 'postgres'
  },
  {
    name: 'Root user',
    user: 'root',
    password: 'root',
    host: 'localhost',
    port: 5432,
    database: 'postgres'
  },
  {
    name: 'System user',
    user: process.env.USERNAME || 'postgres',
    password: '',
    host: 'localhost',
    port: 5432,
    database: 'postgres'
  },
  {
    name: 'Windows Authentication',
    connectionString: 'postgresql:///postgres?host=/var/run/postgresql'
  }
];

async function testConnection(config) {
  const pool = new Pool(config);
  const client = await pool.connect().catch(err => {
    console.log(`❌ ${config.name}: ${err.message}`);
    return null;
  });

  if (!client) {
    await pool.end();
    return false;
  }

  try {
    const result = await client.query('SELECT version()');
    console.log(`✅ ${config.name}: Successfully connected to PostgreSQL ${result.rows[0].version.split(' ')[1]}`);
    return true;
  } catch (err) {
    console.log(`❌ ${config.name}: ${err.message}`);
    return false;
  } finally {
    client.release();
    await pool.end();
  }
}

async function testAllConnections() {
  console.log('Testing PostgreSQL connections...\n');
  
  for (const config of configs) {
    await testConnection(config);
  }
  
  console.log('\nConnection tests completed.');
  
  // Provide instructions for next steps
  console.log('\nIf none of the connections worked, try these steps:');
  console.log('1. Make sure PostgreSQL is running');
  console.log('2. Check if the PostgreSQL service is running in Services (services.msc)');
  console.log('3. Verify the PostgreSQL port (default is 5432)');
  console.log('4. Check pg_hba.conf for authentication settings');
  console.log('5. Try resetting the postgres user password');
}

testAllConnections().catch(console.error);
