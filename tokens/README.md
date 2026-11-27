# misoto-tokens

One token pipeline for the Misoto apps: a brand writes its tokens once in the W3C Design Tokens (DTCG) format, and
Style Dictionary builds Swift that speaks MisotoTheme (`ColorPair`, `TimeInterval`, `CGFloat`) plus CSS custom
properties for the brand's web. It replaces the three hand-written generators (kura-brand's Python, revala-brand's
TypeScript, jade-brand's CSS-to-Swift Python) as each brand moves its source to DTCG.

    npm ci
    node build.mjs tokens.json --swift Generated/BrandTokens.swift --enum KuraTokens --css generated/tokens.css
    node build.mjs tokens.json --swift Generated/BrandTokens.swift --enum KuraTokens --check   # CI staleness gate

A colour: `{"$type": "color", "$value": "#F7F7F7", "$extensions": {"misoto.dark": "#121212"}}`, with optional
`misoto.lightIncreasedContrast` and `misoto.darkIncreasedContrast`. A duration: `{"$type": "duration", "$value":
{"value": 250, "unit": "ms"}}`. Groups become nested enums.

`to-dtcg.mjs` moves an existing `{ name: { light, dark } }` palette into DTCG, and `test/kura-proof.test.mjs` shows
kura-brand's palette coming out value for value as the ColorPairs kura-ios vendors today.

    npm test
