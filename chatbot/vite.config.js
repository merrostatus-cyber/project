import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import { resolve } from 'path'

export default defineConfig({
  base: './',
  // Serve from d:\fitify so all pages are accessible under one server
  root: resolve(__dirname, '..'),
  plugins: [
    react(),
    tailwindcss(),
  ],
  build: {
    outDir: 'dist',
    rollupOptions: {
      input: {
        main: resolve(__dirname, '..', 'index.html'),
        muscleWiki: resolve(__dirname, '..', 'muscle.html'),
        chatbotLanding: resolve(__dirname, '..', 'chatbot', 'index.html'),
        chatbotApp: resolve(__dirname, '..', 'chatbot', 'chat.html'),
      },
    },
  },
})
