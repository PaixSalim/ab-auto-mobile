import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import UnoCSS from '@unocss/vite';
import path from 'path';

export default defineConfig({
  plugins: [
    vue(),
    // Presets UnoCSS : voir uno.config.mjs (évite un second presetIcons sans collections mdi/line-md).
    UnoCSS(),
  ],
  build: {
    outDir: 'public/build',
    emptyOutDir: true,
    manifest: true,
    copyPublicDir: false,
    rollupOptions: {
      input: 'inertia/app/app.ts',
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'inertia'),
      '~': path.resolve(__dirname, 'inertia') + '/',
      '#utils': path.resolve(__dirname, 'app/utils'),
      '#models': path.resolve(__dirname, 'app/models'),
      '#services': path.resolve(__dirname, 'app/services'),
      '#controllers': path.resolve(__dirname, 'app/controllers'),
      '#validators': path.resolve(__dirname, 'app/validators'),
      '#exceptions': path.resolve(__dirname, 'app/exceptions'),
      '#types': path.resolve(__dirname, 'app/types'),
      '#dto': path.resolve(__dirname, 'app/dto'),
      '#mails': path.resolve(__dirname, 'app/mails'),
      '#listeners': path.resolve(__dirname, 'app/listeners'),
      '#events': path.resolve(__dirname, 'app/events'),
      '#middleware': path.resolve(__dirname, 'app/middleware'),
      '#policies': path.resolve(__dirname, 'app/policies'),
      '#abilities': path.resolve(__dirname, 'app/abilities'),
      '#database': path.resolve(__dirname, 'database'),
      '#start': path.resolve(__dirname, 'start'),
      '#config': path.resolve(__dirname, 'config'),
    },
  },
  publicDir: 'public',
  server: {
    port: 5173,
  },
});
