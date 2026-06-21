#!/usr/bin/env node
/**
 * Best-effort postinstall: download a pinned frp release and extract `frpc`
 * into `bin/` for the current OS/arch.
 *
 * Skipped when `FRPC_BIN` is set or a vendored `bin/frpc` already exists. Any
 * failure is non-fatal: we print a clear message telling the user to install
 * frp manually (or set FRPC_BIN) and exit 0 so `npm install` still succeeds.
 */

import { spawnSync } from "node:child_process";
import { chmodSync, existsSync, mkdirSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { pipeline } from "node:stream/promises";
import { createWriteStream } from "node:fs";

const FRP_VERSION = "0.61.0";

const __dirname = dirname(fileURLToPath(import.meta.url));
const binDir = join(__dirname, "..", "bin");
const isWindows = process.platform === "win32";
const binName = isWindows ? "frpc.exe" : "frpc";
const binPath = join(binDir, binName);

function note(message) {
  process.stderr.write(`[fetch-frpc] ${message}\n`);
}

function manualInstructions(reason) {
  note(reason);
  note(
    `Could not vendor frpc automatically. Install frp ${FRP_VERSION}+ yourself ` +
      `(https://github.com/fatedier/frp/releases) and either put \`frpc\` on your ` +
      `PATH or set FRPC_BIN=/path/to/frpc before running noizu-remote-access.`,
  );
}

/** Map Node's platform/arch to frp release asset naming. */
function resolveTarget() {
  const platformMap = { darwin: "darwin", linux: "linux", win32: "windows" };
  const archMap = { x64: "amd64", arm64: "arm64", arm: "arm" };
  const os = platformMap[process.platform];
  const arch = archMap[process.arch];
  if (!os || !arch) {
    return null;
  }
  const ext = os === "windows" ? "zip" : "tar.gz";
  const base = `frp_${FRP_VERSION}_${os}_${arch}`;
  return {
    base,
    asset: `${base}.${ext}`,
    ext,
    url: `https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/${base}.${ext}`,
  };
}

async function download(url, dest) {
  const res = await fetch(url, { redirect: "follow" });
  if (!res.ok || !res.body) {
    throw new Error(`HTTP ${res.status} ${res.statusText} for ${url}`);
  }
  await pipeline(res.body, createWriteStream(dest));
}

async function main() {
  if (process.env.FRPC_BIN) {
    note("FRPC_BIN is set; skipping download.");
    return;
  }
  if (existsSync(binPath)) {
    note(`vendored ${binName} already present; skipping download.`);
    return;
  }

  const target = resolveTarget();
  if (!target) {
    manualInstructions(
      `unsupported platform/arch: ${process.platform}/${process.arch}.`,
    );
    return;
  }

  let scratch;
  try {
    scratch = mkdtempSync(join(tmpdir(), "fetch-frpc-"));
    const archivePath = join(scratch, target.asset);

    note(`downloading ${target.url}`);
    await download(target.url, archivePath);

    // Extract just the frpc binary from the release archive.
    if (target.ext === "tar.gz") {
      const res = spawnSync(
        "tar",
        ["-xzf", archivePath, "-C", scratch, `${target.base}/frpc`],
        { stdio: "inherit" },
      );
      if (res.status !== 0) {
        throw new Error(`tar exited with status ${res.status ?? "unknown"}`);
      }
    } else {
      const res = spawnSync(
        "unzip",
        ["-o", "-j", archivePath, `${target.base}/frpc.exe`, "-d", scratch],
        { stdio: "inherit" },
      );
      if (res.status !== 0) {
        throw new Error(`unzip exited with status ${res.status ?? "unknown"}`);
      }
    }

    const extracted =
      target.ext === "tar.gz"
        ? join(scratch, target.base, "frpc")
        : join(scratch, "frpc.exe");
    if (!existsSync(extracted)) {
      throw new Error(`frpc not found in archive at ${extracted}`);
    }

    mkdirSync(binDir, { recursive: true });
    // Copy then chmod; rename across filesystems (tmp → project) can fail.
    const data = await import("node:fs/promises");
    await data.copyFile(extracted, binPath);
    if (!isWindows) chmodSync(binPath, 0o755);

    note(`installed ${binName} → ${binPath}`);
  } catch (err) {
    manualInstructions(`download/extract failed: ${err?.message ?? err}`);
  } finally {
    if (scratch) rmSync(scratch, { recursive: true, force: true });
  }
}

main().catch((err) => {
  // Never fail the install on an unexpected error.
  manualInstructions(`unexpected error: ${err?.message ?? err}`);
});
