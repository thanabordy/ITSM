
const API_URL = 'http://localhost:5000/api';

async function testApi() {
    try {
        console.log('Testing Login...');
        const loginRes = await fetch(`${API_URL}/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                username: 'admin@demo.com',
                password: 'password123'
            })
        });

        if (!loginRes.ok) {
            throw new Error(`Login failed: ${loginRes.status} ${loginRes.statusText}`);
        }

        const loginData = await loginRes.json();

        if (loginData.token) {
            console.log('Login Successful!');
            const token = loginData.token;
            const headers = { 'Authorization': `Bearer ${token}` };

            console.log('Fetching Users...');
            try {
                const usersRes = await fetch(`${API_URL}/users`, { headers });
                const users = await usersRes.json();
                console.log(`Users fetched: ${Array.isArray(users) ? users.length : 'Not an array'} - Status: ${usersRes.status}`);
            } catch (e) { console.error('Error fetching users:', e.message); }

            console.log('Fetching Tickets...');
            try {
                const ticketsRes = await fetch(`${API_URL}/tickets`, { headers });
                const tickets = await ticketsRes.json();
                console.log(`Tickets fetched: ${Array.isArray(tickets) ? tickets.length : 'Not an array'} - Status: ${ticketsRes.status}`);
            } catch (e) { console.error('Error fetching tickets:', e.message); }

            console.log('Fetching Assets...');
            try {
                const assetsRes = await fetch(`${API_URL}/assets`, { headers });
                const assets = await assetsRes.json();
                console.log(`Assets fetched: ${Array.isArray(assets) ? assets.length : 'Not an array'} - Status: ${assetsRes.status}`);
            } catch (e) { console.error('Error fetching assets:', e.message); }

            console.log('Fetching KB...');
            try {
                const kbRes = await fetch(`${API_URL}/kb`, { headers });
                const kb = await kbRes.json();
                console.log(`KB fetched: ${Array.isArray(kb) ? kb.length : 'Not an array'} - Status: ${kbRes.status}`);
            } catch (e) { console.error('Error fetching KB:', e.message); }

        } else {
            console.error('Login failed: No token returned');
        }

    } catch (error) {
        console.error('API Test Failed:', error.message);
    }
}

testApi();
