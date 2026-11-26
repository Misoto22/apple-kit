#!/usr/bin/env node
/**
 * Builds a brand's DTCG tokens into Swift for MisotoTheme (and CSS custom properties, for the brand's web).
 *
 *   misoto-tokens <tokens.json> --swift <out.swift> --enum <Name> [--css <out.css>] [--check]
 *
 * A colour token is `{"$type": "color", "$value": "#RRGGBB", "$extensions": {"misoto.dark": "#RRGGBB"}}`; optional
 * `misoto.lightIncreasedContrast` / `misoto.darkIncreasedContrast` give the Increase Contrast forms. A token with no dark
 * value is the same in both appearances. A duration token (`$type: duration`, `{"value": 0.25, "unit": "s"}`) becomes a
 * `TimeInterval`. `--check` fails when the files on disk differ from what the tokens build (CI's staleness gate).
 */
import { readFileSync, writeFileSync, mkdtempSync, existsSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import StyleDictionary from "style-dictionary";
import { swiftFormat, cssFormat } from "./formats.mjs";

const args = process.argv.slice(2);
const option = (name) => {
  const index = args.indexOf(name);
  return index >= 0 ? args[index + 1] : undefined;
};
const source = args[0];
const swiftOut = option("--swift");
const cssOut = option("--css");
const enumName = option("--enum") ?? "BrandTokens";
const check = args.includes("--check");
if (!source || (!swiftOut && !cssOut)) {
  console.error("usage: misoto-tokens <tokens.json> --swift <out.swift> --enum <Name> [--css <out.css>] [--check]");
  process.exit(2);
}

StyleDictionary.registerFormat({ name: "misoto/swift", format: ({ dictionary }) => swiftFormat(dictionary.allTokens, enumName) });
StyleDictionary.registerFormat({ name: "misoto/css", format: ({ dictionary }) => cssFormat(dictionary.allTokens) });

const scratch = mkdtempSync(join(tmpdir(), "misoto-tokens-"));
const platforms = {};
if (swiftOut) platforms.swift = { buildPath: `${scratch}/`, files: [{ destination: "out.swift", format: "misoto/swift" }] };
if (cssOut) platforms.css = { buildPath: `${scratch}/`, files: [{ destination: "out.css", format: "misoto/css" }] };

const sd = new StyleDictionary({ source: [source], usesDtcg: true, platforms, log: { verbosity: "silent" } });
await sd.buildAllPlatforms();

let stale = false;
for (const [built, target] of [["out.swift", swiftOut], ["out.css", cssOut]]) {
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
