// The pipeline reproduces kura-brand's palette value for value: every `Pair(light:dark:)` in kura-ios's vendored
// KuraBrand.swift reappears as the same ColorPair. Skipped where the two checkouts are not beside apple-kit.
import { test } from "node:test";
import assert from "node:assert/strict";
import { existsSync, readFileSync, writeFileSync, mkdtempSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { join, dirname } from "node:path";
import { tmpdir } from "node:os";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const brand = join(here, "../../../kura-casa/kura-brand/tokens/kura.json");
const vendored = join(here, "../../../kura-casa/kura-ios/Vendor/kura-brand/KuraBrand.swift");

test("kura palette round-trips", { skip: !existsSync(brand) || !existsSync(vendored) }, () => {
  const dir = mkdtempSync(join(tmpdir(), "kura-proof-"));
  const dtcg = execFileSync("node", [join(here, "../to-dtcg.mjs"), brand, "palette", "palette"], { encoding: "utf8" });
  writeFileSync(join(dir, "tokens.json"), dtcg);
  execFileSync("node", [join(here, "../build.mjs"), join(dir, "tokens.json"), "--swift", join(dir, "Kura.swift"), "--enum", "Kura"]);
  const built = readFileSync(join(dir, "Kura.swift"), "utf8");
  const source = readFileSync(vendored, "utf8");
  const palette = new Set(Object.keys(JSON.parse(readFileSync(brand, "utf8")).palette).filter((k) => !k.startsWith("$")));
  const pairs = [...source.matchAll(/static let (\w+) = Pair\(light: 0x([0-9A-Fa-f]{6}), dark: 0x([0-9A-Fa-f]{6})\)/g)]
    .filter(([, name]) => palette.has(name));
  assert.equal(pairs.length, palette.size, "every palette colour is vendored");
  assert.ok(pairs.length >= 8, `found ${pairs.length} pairs`);
  for (const [, name, light, dark] of pairs) {
    const expected = `static let ${name}: ColorPair = ColorPair(light: RGBA(hex: 0x${light.toUpperCase()}), dark: RGBA(hex: 0x${dark.toUpperCase()}))`;
    assert.ok(built.includes(expected), `${name} differs`);
  }
});
