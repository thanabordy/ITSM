const userController = require('../controllers/userController');
const ticketController = require('../controllers/ticketController');
const pool = require('../config/db');

// Mock Request and Response
const mockRes = () => {
    const res = {};
    res.status = (code) => {
        console.log(`[STATUS] ${code}`);
        return res;
    };
    res.json = (data) => {
        console.log('[JSON OUTPUT PREVIEW]');
        // Print first item if array, or object keys
        if (Array.isArray(data)) {
            console.log(`Array Length: ${data.length}`);
            if (data.length > 0) console.log(data[0]);
        } else {
            console.log(data);
        }
        return res;
    };
    return res;
};

const runTests = async () => {
    try {
        console.log('--- TESTING getAllUsers ---');
        await userController.getAllUsers({ query: {} }, mockRes());

        console.log('\n--- TESTING getAllTickets ---');
        await ticketController.getAllTickets({ query: { limit: 1 } }, mockRes());

        console.log('\n--- TESTING getTicketById (TK-2024-001) ---');
        await ticketController.getTicketById({ params: { id: 'TK-2024-001' } }, mockRes());

        console.log('\n--- TESTING assignTicket (Add ST002 to TK-2024-001) ---');
        // Mock request with user and body
        const reqAssign = {
            params: { id: 'TK-2024-001' },
            body: { user_id: 'ST002', action: 'add' },
            user: { username: 'test_admin', id: 'ST001' }
        };
        await ticketController.assignTicket(reqAssign, mockRes());

        console.log('\n--- TESTING addComment (TK-2024-001) ---');
        const reqComment = {
            params: { id: 'TK-2024-001' },
            body: { detail: 'This is a test comment from manual test.' },
            user: { username: 'test_admin', id: 'ST001' }
        };
        await ticketController.addComment(reqComment, mockRes());

        console.log('\n--- VERIFYING ACTIONS (Get Ticket Again) ---');
        await ticketController.getTicketById({ params: { id: 'TK-2024-001' } }, mockRes());

        console.log('\n--- TESTING getDashboardStats ---');
        const dashboardController = require('../controllers/dashboardController');
        await dashboardController.getDashboardStats({}, mockRes());

        console.log('\n--- TESTING Auth (Login) ---');
        const authController = require('../controllers/authController');
        // Mock res for login to capture token if we were running full integration, 
        // but here we just check if it returns JSON with token.
        await authController.login({ body: { username: 'admin', password: 'password123' } }, mockRes());

        console.log('\n--- TESTING Auth (Get Me) ---');
        // Mock req with user attached (simulating auth middleware)
        await authController.getMe({ user: { id: 'ST001' } }, mockRes());

        console.log('\n--- TESTING SLA Policies ---');
        const slaController = require('../controllers/slaController');
        await slaController.getPolicies({}, mockRes());

        console.log('\n--- TESTING Notifications (Get My) ---');
        const notificationController = require('../controllers/notificationController');
        await notificationController.getMyNotifications({ user: { email: 'admin@demo.com' } }, mockRes());

        console.log('\n--- TESTING CSAT (Submit) ---');
        const csatController = require('../controllers/csatController');
        await csatController.submitCSAT({ params: { ticketId: 'TK-2024-001' }, body: { score: 5, comment: 'Great service!' } }, mockRes());

        console.log('\n--- TESTING File Upload (Mocked Multer) ---');
        // Mock req.file provided by our mock multer or manually injected here for controller test
        const mockFileReq = {
            params: { id: 'TK-2024-001' },
            file: {
                filename: 'test-upload.png',
                mimetype: 'image/png',
                size: 1024,
                path: 'uploads/test-upload.png'
            },
            user: { username: 'admin' }
        };
        await ticketController.uploadAttachment(mockFileReq, mockRes());

        console.log('\n--- TESTING Auto-Assign Logic (Create Hardware Ticket) ---');
        // Hardware category should assign to ST001, ST002, or ST004 (based on demo data)
        const mockCreateReq = {
            body: {
                title: 'Test Auto Assign',
                description: 'Testing auto assign logic',
                category: 'Hardware',
                urgency: 'High',
                impact: 'High',
                user_email: 'admin@demo.com'
            }
        };
        await ticketController.createTicket(mockCreateReq, mockRes());

        console.log('\n--- TESTING User CRUD (Create User) ---');
        // userController is already required at the top of the file.
        // We removed the duplicate require here to avoid ReferenceError (TDZ).

        const mockUserReq = {
            body: {
                id: 'TEST001',
                code: 'TEST001',
                name: 'Test User',
                email: 'test@demo.com',
                department: 'IT',
                position: 'Tester',
                role: 'User'
            }
        };
        await userController.createUser(mockUserReq, mockRes());

        console.log('\n--- TESTING User CRUD (Update User) ---');
        const mockUpdateUserReq = {
            params: { id: 'TEST001' },
            body: {
                name: 'Test User Updated',
                email: 'test@demo.com',
                department: 'IT',
                position: 'Senior Tester',
                role: 'User',
                skills: ['Testing', 'Automation'],
                permissions: ['read']
            }
        };
        await userController.updateUser(mockUpdateUserReq, mockRes());

        console.log('\n--- TESTING User CRUD (Delete User) ---');
        await userController.deleteUser({ params: { id: 'TEST001' } }, mockRes());

        console.log('\n--- TESTING Asset CRUD (Create Asset) ---');
        const assetController = require('../controllers/assetController');
        const mockAssetReq = {
            body: {
                id: 'A-TEST-01',
                name: 'Test Laptop',
                type: 'Laptop',
                brand: 'Dell',
                model: 'Latitude',
                serial: 'SN-TEST-01',
                location: 'HQ',
                status: 'Active'
            }
        };
        await assetController.createAsset(mockAssetReq, mockRes());

        console.log('\n--- TESTING Asset CRUD (Update Asset) ---');
        const mockUpdateAssetReq = {
            params: { id: 'A-TEST-01' },
            body: {
                name: 'Test Laptop Updated',
                type: 'Laptop',
                brand: 'Dell',
                model: 'Latitude X',
                serial: 'SN-TEST-01',
                location: 'HQ',
                status: 'In Repair',
                assigned_to: 'ST001'
            }
        };
        await assetController.updateAsset(mockUpdateAssetReq, mockRes());

        console.log('\n--- TESTING Asset CRUD (Delete Asset) ---');
        await assetController.deleteAsset({ params: { id: 'A-TEST-01' } }, mockRes());

        console.log('\n--- TESTING KB CRUD (Create Article) ---');
        const kbController = require('../controllers/kbController');
        const mockKbReq = {
            body: {
                title: 'How to fix printer',
                category: 'Hardware',
                content: 'Turn it off and on again.',
                is_public: 1
            }
        };
        await kbController.createArticle(mockKbReq, mockRes());
        // Note: ID generation in KB controller relies on DB query, mockRes won't capture the ID returned easily unless we modify mockRes or controller returns explicit ID in json.
        // Controller returns: res.status(201).json({ id, message: 'Article created' });
        // Let's assume ID is KB001 for update test if empty DB, but we should probably use a hardcoded ID or just test logic.

        console.log('\n--- TESTING KB CRUD (Update Article - KB001) ---');
        const mockUpdateKbReq = {
            params: { id: 'KB001' },
            body: {
                title: 'How to fix printer (Updated)',
                category: 'Hardware',
                content: 'Check paper tray.',
                is_public: 1
            }
        };
        await kbController.updateArticle(mockUpdateKbReq, mockRes());


        console.log('\n--- TESTS COMPLETED ---');


        process.exit(0);
    } catch (error) {
        console.error(error);
        process.exit(1);
    }
};

runTests();
