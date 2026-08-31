import {playwrightLauncher} from '@web/test-runner-playwright';
import {esbuildPlugin} from '@web/dev-server-esbuild';

export default {
  files: 'test/**/*.test.ts',
  nodeResolve: true,
  plugins: [esbuildPlugin({target: 'es2021', ts: true, tsconfig: 'tsconfig.json'})],
  browsers: [
    playwrightLauncher({product: 'chromium', launchOptions: {channel: 'chrome'}}),
  ],
};
