import { NextRequest, NextResponse } from "next/server";
import fs from "fs";
import path from "path";
import yaml from "js-yaml";

const THEME_DIR = path.join(process.cwd(), "src", "config", "theme-style-guide");
const OVERRIDES_FILE = path.join(THEME_DIR, "style-guide.overrides.yaml");

function readManifest(): { overrides: Record<string, string | null> } {
  if (!fs.existsSync(OVERRIDES_FILE)) return { overrides: {} };
  try {
    const raw = fs.readFileSync(OVERRIDES_FILE, "utf-8");
    const parsed = yaml.load(raw) as { overrides?: Record<string, string | null> };
    return { overrides: parsed?.overrides ?? {} };
  } catch {
    return { overrides: {} };
  }
}

function writeManifest(manifest: { overrides: Record<string, string | null> }) {
  fs.writeFileSync(OVERRIDES_FILE, yaml.dump(manifest, { lineWidth: -1 }), "utf-8");
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { action } = body as { action: string };

    // ─── Save a named variant ───
    if (action === "save") {
      const { section, variant, content } = body as {
        action: string; section: string; variant: string; content: string;
      };
      if (!section || !variant || !content) {
        return NextResponse.json({ error: "Missing section, variant, or content" }, { status: 400 });
      }
      const filename = `style-guide.${section}.${variant}.yaml`;
      const filePath = path.join(THEME_DIR, filename);
      if (!filePath.startsWith(THEME_DIR)) {
        return NextResponse.json({ error: "Invalid path" }, { status: 400 });
      }
      fs.writeFileSync(filePath, content, "utf-8");
      return NextResponse.json({ saved: filename });
    }

    // ─── Set override: activate a variant for a section ───
    if (action === "set-override") {
      const { section, variant } = body as { action: string; section: string; variant: string | null };
      const manifest = readManifest();
      if (variant) {
        manifest.overrides[section] = variant;
      } else {
        delete manifest.overrides[section];
      }
      writeManifest(manifest);
      return NextResponse.json({ overrides: manifest.overrides });
    }

    // ─── Get manifest + available variants ───
    if (action === "get-overrides") {
      const manifest = readManifest();
      // Scan for variant files
      const files = fs.readdirSync(THEME_DIR).filter((f) =>
        f.startsWith("style-guide.") && f.endsWith(".yaml") && f !== "style-guide.overrides.yaml"
      );
      const variants: Record<string, string[]> = {};
      for (const f of files) {
        const withoutExt = f.replace(".yaml", "").replace("style-guide.", "");
        const parts = withoutExt.split(".");
        if (parts.length === 2) {
          const [sec, v] = parts;
          if (!variants[sec]) variants[sec] = [];
          variants[sec].push(v);
        }
      }
      return NextResponse.json({ overrides: manifest.overrides, variants });
    }

    return NextResponse.json({ error: `Unknown action: ${action}` }, { status: 400 });
  } catch (err) {
    return NextResponse.json({ error: String(err) }, { status: 500 });
  }
}
