const { spawn, exec } = require('child_process');
const path = require('path');

console.log('🚀 Starting development environment...\n');

const colors = {
  nest: '\x1b[36m',    // Cyan
  vite: '\x1b[33m',     // Yellow
  reset: '\x1b[0m'
};

console.log(`${colors.nest}📦 Starting NestJS backend (development mode)...${colors.reset}`);
const nest = spawn('npm', ['run', 'start:dev'], {
  cwd: process.cwd(),
  shell: true,
  stdio: 'inherit'
});

nest.on('close', (code) => {
  if (code !== 0) {
    console.error(`${colors.nest}❌ NestJS failed to start${colors.reset}`);
    process.exit(1);
  }
});

console.log(`${colors.vite}⚡ Starting Vite frontend build (watch mode)...${colors.reset}`);
spawn('npx', ['vite', 'build', '--watch'], {
  cwd: process.cwd(),
  shell: true,
  stdio: 'inherit'
});

// Handle process termination
process.on('SIGINT', () => {
  console.log('\n\n🛑 Shutting down development servers...');
  process.exit(0);
});