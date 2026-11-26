import { test } from "node:test";
import assert from "node:assert/strict";
import { parseColor, swiftName, swiftFormat, cssFormat } from "../formats.mjs";

test("parses short, long and alpha hex", () => {
  assert.deepEqual(parseColor("#abc"), { hex: "AABBCC", alpha: 1 });
  assert.deepEqual(parseColor("C2410C"), { hex: "C2410C", alpha: 1 });
  assert.deepEqual(parseColor("#00000080"), { hex: "000000", alpha: 0.502 });
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

test("CSS puts dark values under the media query", () => {
  const css = cssFormat([{ path: ["color", "paper"], $type: "color", $value: "#F7F7F7", $extensions: { "misoto.dark": "#121212" } }]);
  assert.match(css, /--color-paper: #F7F7F7;/);
  assert.match(css, /prefers-color-scheme: dark[\s\S]*--color-paper: #121212;/);
});

test("an unknown type is refused", () => {
  assert.throws(() => swiftFormat([{ path: ["x", "y"], $type: "fontFamily", $value: "Geist" }], "X"));
});
