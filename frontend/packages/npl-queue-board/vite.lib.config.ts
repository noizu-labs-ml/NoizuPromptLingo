import {defineConfig} from 'vite';

export default defineConfig({
  build: {
    target: 'es2021',
    outDir: 'dist',
    emptyOutDir: true,
    sourcemap: true,
    lib: {
      entry: 'src/index.ts',
      formats: ['es'],
      fileName: () => 'npl-queue-board.js',
    },
  },
});
