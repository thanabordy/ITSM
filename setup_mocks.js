const fs = require('fs');
const path = require('path');

const mockModules = [
    {
        name: 'jsonwebtoken',
        content: `
            module.exports = {
                sign: (payload, secret, options) => 'mock_jwt_token_' + JSON.stringify(payload),
                verify: (token, secret, callback) => {
                    if (callback) return callback(null, { id: 'ST001', role: 'admin', username: 'admin' });
                    return { id: 'ST001', role: 'admin', username: 'admin' };
                }
            };
        `
    },
    {
        name: 'multer',
        content: `
            const multer = (options) => ({
                single: (field) => (req, res, next) => {
                    // Inject mock file
                    req.file = {
                        fieldname: field,
                        originalname: 'test.png',
                        encoding: '7bit',
                        mimetype: 'image/png',
                        destination: './uploads/',
                        filename: 'test-123.png',
                        path: 'uploads/test-123.png',
                        size: 1024
                    };
                    next();
                },
                array: () => (req, res, next) => next(),
                fields: () => (req, res, next) => next(),
                any: () => (req, res, next) => next(),
            });
            multer.diskStorage = () => {};
            module.exports = multer;
        `
    }
];

const nodeModulesPath = path.join(__dirname, 'node_modules');

if (!fs.existsSync(nodeModulesPath)) {
    fs.mkdirSync(nodeModulesPath);
}

mockModules.forEach(mod => {
    const modPath = path.join(nodeModulesPath, mod.name);
    if (!fs.existsSync(modPath)) {
        fs.mkdirSync(modPath);
        fs.writeFileSync(path.join(modPath, 'index.js'), mod.content);
        console.log(`Created mock module: ${mod.name}`);
    } else {
        console.log(`Mock module exists: ${mod.name}`);
    }
});
