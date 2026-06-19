import { execSync } from "child_process";
import path from "path";

const STARTER_ROOT = path.resolve(__dirname, "../..");
const PKG_DIR = path.join(STARTER_ROOT, "node_modules", "@noizu", "styleguide");

execSync("npx tsx src/generate.ts", {
  cwd: PKG_DIR,
  env: {
    ...process.env,
    STYLEGUIDE_CONFIG_ROOT: path.join(STARTER_ROOT, "src", "config"),
    STYLEGUIDE_OUTPUT: path.join(STARTER_ROOT, "src", "app", "design-system.generated.css"),
    STYLEGUIDE_THEME_DIR: path.join(STARTER_ROOT, "public", "themes"),
  },
  stdio: "inherit",
});
