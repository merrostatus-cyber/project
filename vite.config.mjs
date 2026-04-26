import { defineConfig } from 'vite'

export default defineConfig({
  build: {
    minify: false,
    terserOptions: {
      compress: false,
      mangle: false,
    },
    rollupOptions: {
      input: {
        main: 'index.html',
        muscle: 'muscle.html'
      },
      output: {
        entryFileNames: `assets/[name].js`,
        chunkFileNames: `assets/[name].js`,
        assetFileNames: `assets/[name].[ext]`
      }
    }
  }
})
