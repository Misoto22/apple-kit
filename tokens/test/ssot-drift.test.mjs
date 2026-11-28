// Verifies 1:1 SSOT parity between tokens/shared/*.tokens.json and Swift constants in MisotoMotion / MisotoComponents,
// plus one-source-three-outputs generation (Swift Theme, pure-JVM Kotlin, CSS dark + high-contrast).
import { test } from "node:test";
import assert from "node:assert/strict";
import { existsSync, mkdtempSync, readFileSync, writeFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, "../..");

const motionTokens = JSON.parse(readFileSync(join(here, "../shared/misoto-motion.tokens.json"), "utf8")).motion;
const timingTokens = JSON.parse(readFileSync(join(here, "../shared/misoto-timing.tokens.json"), "utf8"));
const motionSwift = readFileSync(join(root, "Sources/MisotoMotion/Motion.swift"), "utf8");
const toastSwift = readFileSync(join(root, "Sources/MisotoComponents/Feedback/MisotoToast.swift"), "utf8");
const loadingSwift = readFileSync(join(root, "Sources/MisotoComponents/Feedback/LoadingTiming.swift"), "utf8");

const durationSeconds = (token) => (token.$value.unit === "ms" ? token.$value.value / 1000 : token.$value.value);

test("shared motion tokens match Motion.swift 1:1", () => {
  const [sx1, sy1, sx2, sy2] = motionTokens.standardCurve.$value;
  assert.match(motionSwift, new RegExp(`standardCurve = CubicBezier\\(x1: ${sx1}, y1: ${sy1}(?:\\.0)?, x2: ${sx2}, y2: ${sy2}(?:\\.0)?\\)`));

  const [ex1, ey1, ex2, ey2] = motionTokens.emphasizedCurve.$value;
  assert.match(motionSwift, new RegExp(`emphasizedCurve = CubicBezier\\(x1: ${ex1}, y1: ${ey1}(?:\\.0)?, x2: ${ex2}, y2: ${ey2}(?:\\.0)?\\)`));

  const checks = [
    ["fast", durationSeconds(motionTokens.quickDuration)],
    ["medium", durationSeconds(motionTokens.standardDuration)],
    ["slowDuration", durationSeconds(motionTokens.slowDuration)],
    ["breathDuration", durationSeconds(motionTokens.breathDuration)],
    ["breathLow", motionTokens.breathLow.$value],
    ["enterOffset", motionTokens.enterOffset.$value.value],
    ["enterScale", motionTokens.enterScale.$value],
    ["stagger", durationSeconds(motionTokens.stagger)],
    ["pressScale", motionTokens.pressScale.$value],
    ["pressOpacity", motionTokens.pressOpacity.$value],
  ];
  for (const [swiftProp, expected] of checks) {
    const m = motionSwift.match(new RegExp(`public static let ${swiftProp}: [^=]+ = ([0-9.]+)`));
    assert.ok(m, `Missing Motion.${swiftProp} in Motion.swift`);
    assert.equal(Number(m[1]), expected, `Motion.${swiftProp} drifted from misoto-motion.tokens.json`);
  }
});

test("shared toast and loading timing tokens match Swift constants 1:1", () => {
  const toastChecks = [
    ["shortDuration", durationSeconds(timingTokens.toast.shortDuration)],
    ["undoDuration", durationSeconds(timingTokens.toast.undoDuration)],
    ["voiceOverDuration", durationSeconds(timingTokens.toast.voiceOverDuration)],
  ];
  for (const [prop, expected] of toastChecks) {
    const m = toastSwift.match(new RegExp(`public static let ${prop}: TimeInterval = ([0-9.]+)`));
    assert.ok(m, `Missing ToastTiming.${prop} in MisotoToast.swift`);
    assert.equal(Number(m[1]), expected, `ToastTiming.${prop} drifted from misoto-timing.tokens.json`);
  }

  const loadingChecks = [
    ["placeholderDelay", durationSeconds(timingTokens.loading.placeholderDelay)],
    ["minimumDisplay", durationSeconds(timingTokens.loading.minimumDisplay)],
    ["slowThreshold", durationSeconds(timingTokens.loading.slowThreshold)],
    ["timeout", durationSeconds(timingTokens.loading.timeout)],
  ];
  for (const [prop, expected] of loadingChecks) {
    const m = loadingSwift.match(new RegExp(`public static let ${prop}: TimeInterval = ([0-9.]+)`));
    assert.ok(m, `Missing LoadingTiming.${prop} in LoadingTiming.swift`);
    assert.equal(Number(m[1]), expected, `LoadingTiming.${prop} drifted from misoto-timing.tokens.json`);
  }
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

  // --check passes when up to date
  execFileSync("node", [...args, "--check"], { encoding: "utf8" });

  // --check fails on drift
  writeFileSync(ktOut, readFileSync(ktOut, "utf8") + "\n// drifted\n");
  assert.throws(() => execFileSync("node", [...args, "--check"], { stdio: "pipe" }));
});
