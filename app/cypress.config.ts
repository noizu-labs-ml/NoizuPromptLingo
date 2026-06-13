import { defineConfig } from "cypress";
import fs from "fs";
import path from "path";

const LOG_DIR = path.join("cypress", "logs");
const LOG_FILE = path.join(LOG_DIR, "extract.log");

function ensureLogDir() {
  fs.mkdirSync(LOG_DIR, { recursive: true });
}

function appendLog(message: string) {
  ensureLogDir();
  const timestamp = new Date().toISOString();
  fs.appendFileSync(LOG_FILE, `[${timestamp}] ${message}\n`, "utf-8");
}

export default defineConfig({
  e2e: {
    baseUrl: "https://tailwindcss.com",
    chromeWebSecurity: false,
    defaultCommandTimeout: 15000,
    pageLoadTimeout: 30000,
    viewportWidth: 1920,
    viewportHeight: 1080,
    video: false,
    screenshotsFolder: "cypress/screenshots",
    screenshotOnRunFailure: true,
    setupNodeEvents(on) {
      on("task", {
        log(message: string) {
          appendLog(message);
          console.log(`[tw-extract] ${message}`);
          return null;
        },
        writeSnippet({ category, name, code }: { category: string; name: string; code: string }) {
          const dir = path.join("cypress", "fixtures", "snippets", category);
          fs.mkdirSync(dir, { recursive: true });
          const file = path.join(dir, `${name}.tsx`);
          fs.writeFileSync(file, code, "utf-8");
          appendLog(`WRITE ${file} (${code.length} chars)`);
          return file;
        },
        writeIndex({ category, entries }: { category: string; entries: { name: string; file: string }[] }) {
          const dir = path.join("cypress", "fixtures", "snippets", category);
          fs.mkdirSync(dir, { recursive: true });
          const indexFile = path.join(dir, "index.json");
          fs.writeFileSync(indexFile, JSON.stringify(entries, null, 2), "utf-8");
          appendLog(`INDEX ${indexFile} (${entries.length} entries)`);
          return indexFile;
        },
      });

      on("after:spec", (_spec, results) => {
        const passed = results.stats.passes;
        const failed = results.stats.failures;
        appendLog(`SPEC ${results.spec.relative} — ${passed} passed, ${failed} failed`);
      });
    },
  },
});
