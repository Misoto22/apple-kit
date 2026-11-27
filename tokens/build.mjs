#!/usr/bin/env node
/**
 * Builds DTCG tokens into Swift for MisotoTheme/MisotoMotion, CSS custom properties, and pure-JVM Kotlin primitives.
 *
 *   misoto-tokens <tokens.json> [--swift <out.swift> --enum <Name>] [--theme <propName>] [--css <out.css>] [--kotlin <out.kt> --kotlin-package <pkg>] [--check]
 */
import { readFileSync, writeFileSync, mkdtempSync, existsSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import StyleDictionary from "style-dictionary";
import { swiftFormat, swiftThemeFormat, cssFormat, kotlinFormat } from "./formats.mjs";

const args = process.argv.slice(2);
const option = (name) => {
  const index = args.indexOf(name);
  return index >= 0 ? args[index + 1] : undefined;
};
const source = args[0];
const swiftOut = option("--swift");
const cssOut = option("--css");
const kotlinOut = option("--kotlin");
const enumName = option("--enum") ?? "BrandTokens";
const themeProp = option("--theme");
const kotlinPackage = option("--kotlin-package") ?? "";
const check = args.includes("--check");
if (!source || (!swiftOut && !cssOut && !kotlinOut)) {
  console.error("usage: misoto-tokens <tokens.json> [--swift <out.swift> --enum <Name>] [--theme <propName>] [--css <out.css>] [--kotlin <out.kt> --kotlin-package <pkg>] [--check]");
  process.exit(2);
}

const here = dirname(fileURLToPath(import.meta.url));
const schema = themeProp ? JSON.parse(readFileSync(join(here, "schema/theme-schema.json"), "utf8")) : null;

StyleDictionary.registerFormat({
  name: "misoto/swift",
  format: ({ dictionary }) =>
    themeProp
      ? swiftThemeFormat(dictionary.allTokens, enumName, themeProp, schema)
      : swiftFormat(dictionary.allTokens, enumName),
});
StyleDictionary.registerFormat({ name: "misoto/css", format: ({ dictionary }) => cssFormat(dictionary.allTokens) });
StyleDictionary.registerFormat({ name: "misoto/kotlin", format: ({ dictionary }) => kotlinFormat(dictionary.allTokens, enumName, kotlinPackage) });

const scratch = mkdtempSync(join(tmpdir(), "misoto-tokens-"));
const platforms = {};
if (swiftOut) platforms.swift = { buildPath: `${scratch}/`, files: [{ destination: "out.swift", format: "misoto/swift" }] };
if (cssOut) platforms.css = { buildPath: `${scratch}/`, files: [{ destination: "out.css", format: "misoto/css" }] };
if (kotlinOut) platforms.kotlin = { buildPath: `${scratch}/`, files: [{ destination: "out.kt", format: "misoto/kotlin" }] };

const sd = new StyleDictionary({ source: [source], usesDtcg: true, platforms, log: { verbosity: "silent" } });
await sd.buildAllPlatforms();

let stale = false;
for (const [built, target] of [["out.swift", swiftOut], ["out.css", cssOut], ["out.kt", kotlinOut]]) {
  if (!target) continue;
  const text = readFileSync(join(scratch, built), "utf8");
  if (check) {
    if (!existsSync(target) || readFileSync(target, "utf8") !== text) {
      console.error(`stale: ${target} differs from what ${source} builds; run misoto-tokens without --check`);
      stale = true;
    }
  } else {
    writeFileSync(target, text);
    console.log(`wrote ${target}`);
  }
}
process.exit(stale ? 1 : 0);
