import { spawn, execSync, type ChildProcess } from "child_process";
import { resolve, dirname } from "path";
import { fileURLToPath } from "url";

const DEFAULT_PORT = 3100;
const HEALTH_URL = (port: number) => `http://localhost:${port}/api/health`;
const POLL_INTERVAL_MS = 200;
const MAX_WAIT_MS = 8000;

export interface LaunchResult {
  alreadyRunning: boolean;
  port: number;
  process?: ChildProcess;
}

async function isApiRunning(port: number): Promise<boolean> {
  try {
    const res = await fetch(HEALTH_URL(port), { signal: AbortSignal.timeout(500) });
    const body = (await res.json()) as { status?: string };
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

function findApiEntrypoint(): string {
  const thisDir = dirname(fileURLToPath(import.meta.url));
  return resolve(thisDir, "..", "..", "api", "src", "index.ts");
}

export async function ensureApi(port = DEFAULT_PORT): Promise<LaunchResult> {
  if (await isApiRunning(port)) {
    return { alreadyRunning: true, port };
  }

  const runtime = findRuntime();
  if (!runtime) {
    throw new Error("No TypeScript runtime found (bun, tsx). Install one to auto-start the API.");
  }

  const entrypoint = findApiEntrypoint();
  const child = spawn(runtime.cmd, [...runtime.args, entrypoint], {
    env: { ...process.env, PORT: String(port) },
    stdio: "ignore",
    detached: true,
  });
  child.unref();

  const deadline = Date.now() + MAX_WAIT_MS;
  while (Date.now() < deadline) {
    if (await isApiRunning(port)) {
      return { alreadyRunning: false, port, process: child };
    }
    await new Promise((r) => setTimeout(r, POLL_INTERVAL_MS));
  }

  child.kill();
  throw new Error(`API server failed to start on port ${port} within ${MAX_WAIT_MS}ms`);
}

export { isApiRunning };
