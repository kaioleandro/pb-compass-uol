/**
 * Create Test User Script
 */
const dotenv = require('dotenv');
const path = require('path');
const mongoose = require('mongoose');
const { User } = require('../models');

// Load environment variables from root directory
dotenv.config({ path: path.join(__dirname, '../../.env') });

// Verificar se a variável de ambiente foi carregada
if (!process.env.MONGODB_URI) {
  console.error('❌ MONGODB_URI não encontrada nas variáveis de ambiente!');
  console.error('   Verifique se o arquivo .env existe na raiz do projeto.');
  console.error('   Caminho procurado:', path.join(__dirname, '../../.env'));
  process.exit(1);
}

// Connect to the database
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('MongoDB connected for creating test users');
    return mongoose.connection;
  } catch (err) {
    console.error('Error connecting to MongoDB:', err.message);
    process.exit(1);
  }
};

// Create a test user
const createTestUser = async () => {
  try {
    // Connect to the database
    await connectDB();
    
    console.log('Creating test users...\n');
    
    // Check if test user already exists
    const existingUser = await User.findOne({ email: 'test@example.com' });
    
    if (!existingUser) {
      // Create test user
      const testUser = await User.create({
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        role: 'user'
      });
      
      console.log('✅ Test user created successfully:');
      console.log('   Email: test@example.com');
      console.log('   Password: password123');
      console.log('   Role: user');
      console.log('   Password encrypted:', testUser.password.startsWith('$2b$') ? 'Yes' : 'No');
    } else {
      console.log('ℹ️  Test user already exists (test@example.com)');
    }
    
    // Create test admin user
    const adminExists = await User.findOne({ email: 'admin@example.com' });
    
    if (!adminExists) {
      const adminUser = await User.create({
        name: 'Admin User',
        email: 'admin@example.com',
        password: 'admin123',
        role: 'admin'
      });
      
      console.log('\n✅ Test admin created successfully:');
      console.log('   Email: admin@example.com');
      console.log('   Password: admin123');
      console.log('   Role: admin');
      console.log('   Password encrypted:', adminUser.password.startsWith('$2b$') ? 'Yes' : 'No');
    } else {
      console.log('\nℹ️  Test admin already exists (admin@example.com)');
    }
    
    console.log('\n🎉 Test users setup completed!');
    console.log('\nYou can now use these credentials:');
    console.log('👤 Regular User: test@example.com / password123');
    console.log('👑 Admin User: admin@example.com / admin123');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating test users:', error.message);
    if (error.code === 11000) {
      console.error('   This is likely a duplicate key error. Users may already exist.');
    }
    process.exit(1);
  }
};

// Run the function
createTestUser();
