import { defineConfig, type PluginOption } from "vite";
import react from "@vitejs/plugin-react";
import { spawn, execSync } from "child_process";
import { resolve, dirname } from "path";
import { fileURLToPath } from "url";

const API_PORT = 3100;

async function isApiRunning(): Promise<boolean> {
  try {
    const res = await fetch(`http://localhost:${API_PORT}/api/health`, {
      signal: AbortSignal.timeout(500),
    });
    const body = await res.json();
    return body?.status === "ok";
  } catch {
    return false;
  }
}

function findRuntime(): { cmd: string; args: string[] } | null {
  for (const cmd of ["bun", "tsx", "npx"]) {
    try {
      execSync(`which ${cmd}`, { stdio: "ignore" });
      if (cmd === "npx") return { cmd: "npx", args: ["tsx"] };
      return { cmd, args: cmd === "bun" ? ["run"] : [] };
    } catch {}
  }
  return null;
}

function ensureApiPlugin(): PluginOption {
  return {
    name: "ensure-api",
    async configureServer() {
      if (await isApiRunning()) return;

      const runtime = findRuntime();
      if (!runtime) {
        console.warn(
          "\x1b[33m[claude-assist]\x1b[0m No TS runtime found (bun, tsx). " +
          "Install one or start the API manually: pnpm --filter @claude-assist/api dev"
        );
        return;
      }

      const thisDir = dirname(fileURLToPath(import.meta.url));
      const entrypoint = resolve(thisDir, "..", "api", "src", "index.ts");

      const child = spawn(runtime.cmd, [...runtime.args, entrypoint], {
        env: { ...process.env, PORT: String(API_PORT) },
        stdio: "ignore",
        detached: true,
      });
      child.unref();

      const deadline = Date.now() + 8000;
      while (Date.now() < deadline) {
        if (await isApiRunning()) {
          console.log(
            `\x1b[36m[claude-assist]\x1b[0m Started API server via ${runtime.cmd} on http://localhost:${API_PORT}`
          );
          return;
        }
        await new Promise((r) => setTimeout(r, 200));
      }
      console.warn(
        "\x1b[33m[claude-assist]\x1b[0m API server failed to start — web UI will have no data. " +
        "Try: pnpm --filter @claude-assist/api dev"
      );
    },
  };
}

export default defineConfig({
  plugins: [react(), ensureApiPlugin()],
  server: {
    port: 5173,
    proxy: {
      "/api": "http://localhost:3100",
    },
  },
});
