# Changelog

## [0.3.1](https://github.com/Misoto22/apple-kit/compare/v0.3.0...v0.3.1) (2026-11-28)


### Bug Fixes

* **foundation,testing:** generalize RateLimitRetry and RecordingKeychain and add haptics guide ([#15](https://github.com/Misoto22/apple-kit/issues/15)) ([5e1ba9e](https://github.com/Misoto22/apple-kit/commit/5e1ba9e058b0f9bde0160e1d54a358c7e5083cd7))

## [0.3.0](https://github.com/Misoto22/apple-kit/compare/v0.2.2...v0.3.0) (2026-11-28)


### ⚠ BREAKING CHANGES

* Removes 14 uncalled MisotoComponents visual shells, MisotoToastCapsule, ZoomablePhotoView, SemanticVersion, and unused Theme.Variants properties.

### Refactoring

* prune unshared visual shells and focus MisotoComponents on adopted primitives ([#13](https://github.com/Misoto22/apple-kit/issues/13)) ([ff6dc31](https://github.com/Misoto22/apple-kit/commit/ff6dc31c1b3dc708ad9b70b729452b7dd6e6467f))

## [0.2.2](https://github.com/Misoto22/apple-kit/compare/v0.2.1...v0.2.2) (2026-11-28)


### Bug Fixes

* **layout,behavior:** harden FlowLayout, guard hidden AppearanceWindow transitions, and add sheetRootClose ([#11](https://github.com/Misoto22/apple-kit/issues/11)) ([ce7ff1d](https://github.com/Misoto22/apple-kit/commit/ce7ff1de0adbf58444805c821e7ba3e0830cc542))

## [0.2.1](https://github.com/Misoto22/apple-kit/compare/v0.2.0...v0.2.1) (2026-11-28)


### Bug Fixes

* **components:** improve toggle a11y, spinner motion tokens, Dynamic Type icons, and sheet guard localization ([#9](https://github.com/Misoto22/apple-kit/issues/9)) ([574ded0](https://github.com/Misoto22/apple-kit/commit/574ded03f62540755f21e9b1520f2ce3967c6ee0))

## [0.2.0](https://github.com/Misoto22/apple-kit/compare/v0.1.0...v0.2.0) (2026-11-27)


### ⚠ BREAKING CHANGES

* expand AppleKit to 26+ shared design system ([#7](https://github.com/Misoto22/apple-kit/issues/7))

### Features

* expand AppleKit to 26+ shared design system ([#7](https://github.com/Misoto22/apple-kit/issues/7)) ([4af82aa](https://github.com/Misoto22/apple-kit/commit/4af82aa7098e77a46427ecec4e2440773f9a2afd))

## 0.1.0 (2026-11-27)


### ⚠ BREAKING CHANGES

* **behavior:** CoverWindow's init takes Options; breathing gains delay.

### Features

* share the foundation, theme roles and behaviours of the Misoto iOS apps ([0f8080e](https://github.com/Misoto22/apple-kit/commit/0f8080e7a2512a805b8636ccc2999716ec201cf3))
* **tokens:** one DTCG token pipeline that builds MisotoTheme Swift ([#3](https://github.com/Misoto22/apple-kit/issues/3)) ([23e3886](https://github.com/Misoto22/apple-kit/commit/23e3886790e63474c8c97a223b8754653318c1e6))


### Bug Fixes

* **behavior:** keep each app's behaviour in the breath, the sheet material and the cover window ([#4](https://github.com/Misoto22/apple-kit/issues/4)) ([6773c01](https://github.com/Misoto22/apple-kit/commit/6773c013cf131a57c9cb6640920972eff0bdffab))
