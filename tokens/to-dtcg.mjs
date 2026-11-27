#!/usr/bin/env node
/**
 * Moves a `{ name: { light, dark } }` palette (kura-brand's `palette`, revala-brand's ThemeColor maps) into DTCG
 * colour tokens with the dark value in `$extensions["misoto.dark"]`, keeping `$comment` as `$description`.
 *
 *   node to-dtcg.mjs <file.json> <json-pointer-to-palette> <group-name> > tokens.json
 */
import { readFileSync } from "node:fs";

const [file, pointer = "", group = "color"] = process.argv.slice(2);
let node = JSON.parse(readFileSync(file, "utf8"));
for (const key of pointer.split("/").filter(Boolean)) node = node[key];
const out = { [group]: {} };
if (node.$comment) out[group].$description = node.$comment;
for (const [name, value] of Object.entries(node)) {
  if (name.startsWith("$") || typeof value !== "object" || !("light" in value)) continue;
  out[group][name] = { $type: "color", $value: value.light, $extensions: { "misoto.dark": value.dark } };
}
process.stdout.write(JSON.stringify(out, null, 2) + "\n");
