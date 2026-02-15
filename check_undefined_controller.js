const fs = require('fs');
const path = require('path');

const controllersPath = path.join(__dirname, 'controllers');
const routesPath = path.join(__dirname, 'routes');

console.log('--- Checking Controllers for Undefined Exports ---');
const controllers = fs.readdirSync(controllersPath).filter(f => f.endsWith('.js'));
controllers.forEach(file => {
    try {
        const controller = require(path.join(controllersPath, file));
        console.log(`Checking ${file}...`);
        Object.keys(controller).forEach(key => {
            if (controller[key] === undefined) {
                console.error(`ERROR: ${file} exports ${key} as undefined!`);
            }
        });
        console.log(`  > Exports: ${Object.keys(controller).join(', ')}`);
    } catch (e) {
        console.error(`ERROR loading ${file}:`, e.message);
    }
});

console.log('\n--- Checking Routes for Undefined Callbacks ---');
// We can't easily check routes without mocking express, 
// but we can check if they import controllers correctly.

const routes = fs.readdirSync(routesPath).filter(f => f.endsWith('.js'));
routes.forEach(file => {
    const content = fs.readFileSync(path.join(routesPath, file), 'utf8');
    // Regex to find controller usage like controller.funcName
    const matches = content.matchAll(/([a-zA-Z0-9]+Controller)\.([a-zA-Z0-9_]+)/g);

    console.log(`Checking ${file}...`);
    for (const match of matches) {
        const controllerName = match[1];
        const funcName = match[2];
        const controllerFile = controllerName + '.js';

        try {
            const controller = require(path.join(controllersPath, controllerFile));
            if (controller[funcName] === undefined) {
                console.error(`CRITICAL ERROR in ${file}: ${controllerName}.${funcName} is UNDEFINED!`);
            }
        } catch (e) {
            // Controller might be named differently or require failed
            // console.warn(`  Could not check ${controllerName}.${funcName}`);
        }
    }
});
