import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import StyleDictionary from "style-dictionary";
import { parseColor, swiftName, swiftFormat, swiftThemeFormat, validateThemeTokens, cssFormat, kotlinFormat } from "../formats.mjs";

const here = dirname(fileURLToPath(import.meta.url));
const schema = JSON.parse(readFileSync(join(here, "../schema/theme-schema.json"), "utf8"));

test("parses short, long and alpha hex", () => {
  assert.deepEqual(parseColor("#abc"), { hex: "AABBCC", alpha: 1, aarrggbb: "FFAABBCC" });
  assert.deepEqual(parseColor("C2410C"), { hex: "C2410C", alpha: 1, aarrggbb: "FFC2410C" });
  assert.deepEqual(parseColor("#00000080"), { hex: "000000", alpha: 0.502, aarrggbb: "80000000" });
  assert.throws(() => parseColor("red"));
});

test("names are lower camel case", () => {
  assert.equal(swiftName(["color", "ink-strong"]), "inkStrong");
  assert.equal(swiftName(["space", "2x"]), "_2x");
});

test("a colour becomes a ColorPair, dark defaulting to light", () => {
  const swift = swiftFormat(
    [
      { path: ["color", "paper"], $type: "color", $value: "#F7F7F7", $extensions: { "misoto.dark": "#121212" } },
      { path: ["color", "mark"], $type: "color", $value: "#000000" },
      { path: ["motion", "quick"], $type: "duration", $value: { value: 250, unit: "ms" } },
    ],
    "Kura",
  );
  assert.match(swift, /public enum Kura \{/);
  assert.match(swift, /public enum Color \{/);
  assert.match(swift, /static let paper: ColorPair = ColorPair\(light: RGBA\(hex: 0xF7F7F7\), dark: RGBA\(hex: 0x121212\)\)/);
  assert.match(swift, /static let mark: ColorPair = ColorPair\(light: RGBA\(hex: 0x000000\), dark: RGBA\(hex: 0x000000\)\)/);
  assert.match(swift, /static let quick: TimeInterval = 0.25/);
});

test("swiftFormat emits cubicBezier, shadow, and typography tokens", () => {
  const swift = swiftFormat(
    [
      { path: ["motion", "standard"], $type: "cubicBezier", $value: [0.4, 0, 0.2, 1] },
      {
        path: ["elevation", "card"],
        $type: "shadow",
        $value: { offsetX: 0, offsetY: 2, blur: 8, spread: 0, color: "#0000001A" },
        $extensions: { "misoto.dark": { offsetX: 0, offsetY: 2, blur: 8, spread: 0, color: "#00000066" } },
      },
      { path: ["type", "body"], $type: "typography", $value: { fontFamily: "System", textStyle: "body", weight: "regular" } },
      { path: ["type", "mono"], $type: "typography", $value: { fontFamily: "Geist Mono", fontSize: 14, textStyle: "callout", weight: "medium" } },
    ],
    "BrandTokens",
  );
  assert.match(swift, /import MisotoMotion/);
  assert.match(swift, /static let standard: CubicBezier = CubicBezier\(x1: 0.4, y1: 0, x2: 0.2, y2: 1\)/);
  assert.match(swift, /static let card: ShadowPair = ShadowPair\(light: ShadowToken\(x: 0, y: 2, blur: 8, spread: 0, color: RGBA\(hex: 0x000000, alpha: 0.102\)\)/);
  assert.match(swift, /static let body: FontRole = FontRole\.system\(\.body, design: \.default, weight: \.regular\)/);
  assert.match(swift, /static let mono: FontRole = FontRole\.custom\("Geist Mono", size: 14, relativeTo: \.callout, weight: \.medium\)/);
});

test("CSS puts dark values and high contrast values under media queries", () => {
  const css = cssFormat([
    {
      path: ["color", "paper"],
      $type: "color",
      $value: "#F7F7F7",
      $extensions: {
        "misoto.dark": "#121212",
        "misoto.lightIncreasedContrast": "#FFFFFF",
        "misoto.darkIncreasedContrast": "#000000",
      },
    },
    { path: ["motion", "standard"], $type: "cubicBezier", $value: [0.4, 0, 0.2, 1] },
  ]);
  assert.match(css, /--color-paper: #F7F7F7;/);
  assert.match(css, /--motion-standard: cubic-bezier\(0.4, 0, 0.2, 1\);/);
  assert.match(css, /prefers-color-scheme: dark[\s\S]*--color-paper: #121212;/);
  assert.match(css, /prefers-contrast: more[\s\S]*--color-paper: #FFFFFF;/);
  assert.match(css, /prefers-contrast: more[\s\S]*prefers-color-scheme: dark[\s\S]*--color-paper: #000000;/);
});

test("kotlinFormat outputs pure JVM constants with Light/Dark/HighContrast", () => {
  const kt = kotlinFormat(
    [
      {
        path: ["color", "paper"],
        $type: "color",
        $value: "#F8F7F4",
        $extensions: { "misoto.dark": "#121212", "misoto.lightIncreasedContrast": "#FFFFFF" },
      },
      { path: ["motion", "standardDuration"], $type: "duration", $value: { value: 200, unit: "ms" } },
      { path: ["motion", "standardCurve"], $type: "cubicBezier", $value: [0.4, 0, 0.2, 1] },
    ],
    "RevalaTokens",
    "app.revala.core.designsystem.generated",
  );
  assert.match(kt, /package app\.revala\.core\.designsystem\.generated/);
  assert.match(kt, /object Light \{[\s\S]*const val colorPaper: Long = 0xFFF8F7F4/);
  assert.match(kt, /object Dark \{[\s\S]*const val colorPaper: Long = 0xFF121212/);
  assert.match(kt, /object LightHighContrast \{[\s\S]*const val colorPaper: Long = 0xFFFFFFFF/);
  assert.match(kt, /object DarkHighContrast \{[\s\S]*const val colorPaper: Long = 0xFF121212/);
  assert.match(kt, /const val motionStandardDurationMs: Long = 200L/);
  assert.match(kt, /val motionStandardCurve: FloatArray = floatArrayOf\(0.4f, 0f, 0.2f, 1f\)/);
  assert.doesNotMatch(kt, /import android|import androidx/);
});

test("validateThemeTokens and swiftThemeFormat validate schema and emit Theme extension", async () => {
  const sd = new StyleDictionary({
    source: [join(here, "../examples/complete-brand.tokens.json")],
    usesDtcg: true,
    platforms: { swift: {} },
    log: { verbosity: "silent" },
  });
  const dict = await sd.getPlatformTokens("swift");
  const swift = swiftThemeFormat(dict.allTokens, "KiokuTokens", "kioku", schema);
  assert.match(swift, /extension Theme \{/);
  assert.match(swift, /public static let kioku = Theme\(/);
  assert.match(swift, /paper: Color\(KiokuTokens\.Color\.paper\)/);
  assert.match(swift, /secondaryInk: Color\(KiokuTokens\.Color\.Glass\.secondaryInk\)/);
  assert.match(swift, /floating: KiokuTokens\.Elevation\.floating/);
  assert.match(swift, /card: nil/);
  assert.match(swift, /public enum Brand \{[\s\S]*static let moss: ColorPair/);

  // Missing required token fails
  assert.throws(
    () => validateThemeTokens(dict.allTokens.filter((t) => t.path.join(".") !== "color.paper"), schema),
    /missing required token 'color\.paper'/,
  );

  // Mismatched type fails
  const bad = dict.allTokens.map((t) =>
    t.path.join(".") === "radii.card" ? { ...t, $type: "color" } : t,
  );
  assert.throws(
    () => validateThemeTokens(bad, schema),
    /token 'radii\.card' expected \$type 'dimension' but got 'color'/,
  );
});

test("an unknown type is refused", () => {
  assert.throws(() => swiftFormat([{ path: ["x", "y"], $type: "fontFamily", $value: "Geist" }], "X"));
});
