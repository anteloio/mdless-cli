import { readFileSync } from "node:fs";
import { join } from "node:path";

// Root of the package: the folder that holds package.json, assets/ and src/.
// This file must stay directly inside src/. It runs from two places:
//   - src/paths.ts in a git checkout (bin.mjs runs the TypeScript with tsx)
//   - dist/index.js in the published package (all of src/ bundled in one file)
// In both cases the root is one folder up.
export const PACKAGE_ROOT = join(import.meta.dirname, "..");

// Read the version at runtime, not at build time: semantic-release writes the
// new version into package.json after the build and before `npm publish`.
export function packageVersion(): string {
  const pkg = JSON.parse(readFileSync(join(PACKAGE_ROOT, "package.json"), "utf8"));
  return pkg.version;
}
