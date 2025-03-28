const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Create build directory if it doesn't exist
const buildDir = path.join(__dirname, 'build');
if (!fs.existsSync(buildDir)) {
    fs.mkdirSync(buildDir);
}

// Copy dist contents to build directory
const distDir = path.join(__dirname, 'dist');
fs.readdirSync(distDir).forEach(file => {
    const srcPath = path.join(distDir, file);
    const destPath = path.join(buildDir, file);
    fs.copyFileSync(srcPath, destPath);
});

// Copy node_modules to build directory
const nodeModulesDir = path.join(__dirname, 'node_modules');
const destNodeModulesDir = path.join(buildDir, 'node_modules');

//copy directory with fs module
fs.cpSync(nodeModulesDir, destNodeModulesDir, {recursive: true});

// Create ZIP file
execSync(`cd build && zip -qr ../lambda.zip . && cd ..`);


fs.rmSync(buildDir, { recursive: true, force: true });