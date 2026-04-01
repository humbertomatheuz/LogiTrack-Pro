import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueDevTools from 'vite-plugin-vue-devtools'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    vueDevTools(),
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    },
  },
  server: {
    host: '0.0.0.0',
    port: 3000,
    // Polling necessário no WSL — o kernel Linux do WSL2 não propaga
    // eventos inotify corretamente através do filesystem 9P (pasta Windows).
    // Se os arquivos estão em /home ou /root (ext4 nativo), pode desabilitar.
    watch: {
      usePolling: true,
      interval: 500,
    },
    // Proxy para o backend — as chamadas /api/* são redirecionadas
    // para o container backend, evitando CORS em desenvolvimento.
    proxy: {
      '/api': {
        target: 'http://backend:8080',
        changeOrigin: true,
        rewrite: (path) => path,
      },
    },
    // Hot Module Replacement
    hmr: {
      // Quando acessado pelo browser no host WSL, o HMR WebSocket
      // precisa usar localhost (o que o browser enxerga), não o hostname
      // interno do container.
      host: 'localhost',
      port: 3000,
    },
  },
})
