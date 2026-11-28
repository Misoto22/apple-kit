// Verifies 1:1 SSOT parity between tokens/shared/*.tokens.json and generated Swift/CSS/Kotlin outputs via `--check`,
// plus one-source-three-outputs brand generation via build.mjs.
import { test } from "node:test";
import assert from "node:assert/strict";
import { existsSync, mkdtempSync, readFileSync, writeFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, "../..");
const genScript = join(here, "../generate-shared.mjs");

test("shared motion and timing tokens match generated Swift, CSS, and Kotlin artifacts 1:1", () => {
  execFileSync("node", [genScript, "--check"], { encoding: "utf8" });

  // Verify every shared token output exists for iOS/macOS, Web CSS, and Android Kotlin consumers.
  const artifacts = [
    "Sources/MisotoMotion/GeneratedMotionTokens.swift",
    "Sources/MisotoComponents/GeneratedTimingTokens.swift",
    "tokens/dist/misoto-motion.css",
    "tokens/dist/MisotoMotionTokens.kt",
    "tokens/dist/misoto-timing.css",
    "tokens/dist/MisotoTimingTokens.kt",
  ];
  for (const rel of artifacts) {
    assert.ok(existsSync(join(root, rel)), `Missing generated SSOT artifact: ${rel}`);
  }
});

test("generate-shared --check detects drift and fails", () => {
  const cssPath = join(root, "tokens/dist/misoto-motion.css");
  const original = readFileSync(cssPath, "utf8");
  try {
    writeFileSync(cssPath, original + "\n/* drift */\n");
    assert.throws(() => execFileSync("node", [genScript, "--check"], { stdio: "pipe" }));
  } finally {
    writeFileSync(cssPath, original);
  }
  execFileSync("node", [genScript, "--check"], { stdio: "pipe" });
});

test("build.mjs emits Swift Theme, pure-JVM Kotlin, and CSS and passes --check", () => {
  const dir = mkdtempSync(join(tmpdir(), "misoto-ssot-"));
  const example = join(here, "../examples/complete-brand.tokens.json");
  const swiftOut = join(dir, "BrandTokens.swift");
  const cssOut = join(dir, "tokens.css");
  const ktOut = join(dir, "BrandTokens.kt");

  const args = [
    join(here, "../build.mjs"),
    example,
    "--swift", swiftOut, "--enum", "KiokuTokens", "--theme", "kioku",
    "--css", cssOut,
    "--kotlin", ktOut, "--kotlin-package", "app.misoto.tokens",
  ];

  execFileSync("node", args, { encoding: "utf8" });
  assert.ok(existsSync(swiftOut) && existsSync(cssOut) && existsSync(ktOut));

  execFileSync("node", [...args, "--check"], { encoding: "utf8" });

  writeFileSync(ktOut, readFileSync(ktOut, "utf8") + "\n// drifted\n");
  assert.throws(() => execFileSync("node", [...args, "--check"], { stdio: "pipe" }));
});
