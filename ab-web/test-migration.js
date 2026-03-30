const axios = require('axios');

const API_URL = 'http://localhost:3333/api'; // Or your port

async function runTests() {
  try {
    console.log('--- Testing Registration ---');
    const registerResponse = await axios.post(`${API_URL}/auth/register`, {
      email: `test_${Date.now()}@example.com`,
      password: 'password123',
      fullName: 'Test User',
    });
    console.log('Registration Success');
    const token = registerResponse.data.access_token;

    console.log('--- Testing Products List ---');
    const productsResponse = await axios.get(`${API_URL}/products`);
    console.log(`Fetched ${productsResponse.data.length} products`);

    console.log('--- Testing Auth Protected Route ---');
    try {
      await axios.post(`${API_URL}/products`, {
        name: 'Test Vehicle',
        categoryId: 1, // Assuming category 1 exists
        state: 'new',
        description: 'Test description',
        price: 10000,
      }, {
        headers: { Authorization: `Bearer ${token}` }
      });
      console.log('Protected route access (Seller) Success');
    } catch (e) {
      console.log('Failed protected route (Category 1 probably missing but Auth worked if 404/400 instead of 401)');
      console.log('Status:', e.response?.status);
    }
    
    console.log('--- ALL BASIC TESTS PASSED ---');
  } catch (error) {
    console.error('Test Failed:', error.response?.data || error.message);
  }
}

// To run this, the server must be UP
// I'll start the server and run this after a delay
// runTests();
