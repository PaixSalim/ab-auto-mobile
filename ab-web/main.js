/**
 * AB-AUTO Hostinger Entry Point
 * This file serves as a bridge for the Hostinger Node.js selector.
 * It is designed to be more robust and log informative messages if things go wrong.
 */

const fs = require('fs');
const path = require('path');

process.on('uncaughtException', (error) => {
  console.error('=== UNCAUGHT EXCEPTION ===');
  console.error(error.message);
  console.error(error.stack);
  process.exit(1);
});

process.on('unhandledRejection', (reason) => {
  console.error('=== UNHANDLED REJECTION ===');
  console.error(reason);
  process.exit(1);
});

console.log('--- Bridge Node.js AB-AUTO START ---');
console.log('Current __dirname:', __dirname);
console.log('Current process.cwd():', process.cwd());

// Potential compiled entry point locations
// Based on TypeScript configuration preserving folder structures
const possibleEntryPoints = [
  './dist/src/main.js',
  './dist/main.js',
  './dist/src/main',
  './dist/main'
];

let found = false;
for (const entryPath of possibleEntryPoints) {
  const absoluteEntryPath = path.isAbsolute(entryPath) ? entryPath : path.join(__dirname, entryPath);
  
  if (fs.existsSync(absoluteEntryPath) || fs.existsSync(absoluteEntryPath + '.js')) {
    console.log('✅ Entry point found:', absoluteEntryPath);
    try {
      require(entryPath);
      found = true;
      console.log('🚀 Loading application...');
      break;
    } catch (requireError) {
      console.error('❌ Error while requiring entry point:', entryPath);
      console.error(requireError);
    }
  } else {
    console.log('ℹ️ Checked path:', absoluteEntryPath, '- NOT FOUND');
  }
}

if (!found) {
  console.error('CRITICAL ERROR: No NestJS entry point found.');
  
  // Debug: list contents of important directories
  try {
    const distPath = path.join(__dirname, 'dist');
    if (fs.existsSync(distPath)) {
      console.log('Contents of dist/:', fs.readdirSync(distPath));
      const distSrcPath = path.join(distPath, 'src');
      if (fs.existsSync(distSrcPath)) {
        console.log('Contents of dist/src/:', fs.readdirSync(distSrcPath));
      }
    } else {
      console.log('dist/ directory DOES NOT EXIST at', distPath);
    }
  } catch (debugError) {
    console.error('Debug logging failed:', debugError);
  }
  
  process.exit(1);
}
