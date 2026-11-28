#!/usr/bin/env node
/**
 * Generates shared Misoto motion and timing artifacts from tokens/shared/*.tokens.json:
 * - Swift SSOT constants consumed directly by MisotoMotion & MisotoComponents
 * - Consumable CSS custom properties under tokens/dist/
 * - Consumable pure-JVM Kotlin token objects under tokens/dist/
 *
 * Pass `--check` to fail on any drift between JSON sources and generated outputs.
 */
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, "..");
const check = process.argv.includes("--check");

const motion = JSON.parse(readFileSync(join(here, "shared/misoto-motion.tokens.json"), "utf8")).motion;
const timing = JSON.parse(readFileSync(join(here, "shared/misoto-timing.tokens.json"), "utf8"));

const toSeconds = (token) => (token.$value.unit === "ms" ? token.$value.value / 1000 : token.$value.value);
const toMs = (token) => (token.$value.unit === "s" ? Math.round(token.$value.value * 1000) : token.$value.value);
const formatNum = (value) => (Number.isInteger(value) ? `${value}.0` : `${value}`);

const [sx1, sy1, sx2, sy2] = motion.standardCurve.$value;
const [ex1, ey1, ex2, ey2] = motion.emphasizedCurve.$value;

const swiftMotion = `// Generated from tokens/shared/misoto-motion.tokens.json by tokens/generate-shared.mjs. Do not edit.
import CoreGraphics
import Foundation

internal enum GeneratedMotionTokens {
    static let standardCurve = CubicBezier(x1: ${formatNum(sx1)}, y1: ${formatNum(sy1)}, x2: ${formatNum(sx2)}, y2: ${formatNum(sy2)})
    static let emphasizedCurve = CubicBezier(x1: ${formatNum(ex1)}, y1: ${formatNum(ey1)}, x2: ${formatNum(ex2)}, y2: ${formatNum(ey2)})

    static let fast: TimeInterval = ${formatNum(toSeconds(motion.quickDuration))}
    static let medium: TimeInterval = ${formatNum(toSeconds(motion.standardDuration))}
    static let slowDuration: TimeInterval = ${formatNum(toSeconds(motion.slowDuration))}
    static let breathDuration: TimeInterval = ${formatNum(toSeconds(motion.breathDuration))}
    static let spinDuration: TimeInterval = ${formatNum(toSeconds(motion.spinDuration))}
    static let spinEnsoDuration: TimeInterval = ${formatNum(toSeconds(motion.spinEnsoDuration))}
    static let breathLow: Double = ${formatNum(motion.breathLow.$value)}

    static let enterOffset: CGFloat = ${formatNum(motion.enterOffset.$value.value)}
    static let enterScale: CGFloat = ${formatNum(motion.enterScale.$value)}
    static let stagger: TimeInterval = ${formatNum(toSeconds(motion.stagger))}

    static let pressScale: CGFloat = ${formatNum(motion.pressScale.$value)}
    static let pressOpacity: Double = ${formatNum(motion.pressOpacity.$value)}
}
`;

const swiftTiming = `// Generated from tokens/shared/misoto-timing.tokens.json by tokens/generate-shared.mjs. Do not edit.
import Foundation

internal enum GeneratedTimingTokens {
    enum Toast {
        static let shortDuration: TimeInterval = ${formatNum(toSeconds(timing.toast.shortDuration))}
        static let undoDuration: TimeInterval = ${formatNum(toSeconds(timing.toast.undoDuration))}
        static let voiceOverDuration: TimeInterval = ${formatNum(toSeconds(timing.toast.voiceOverDuration))}
    }

    enum Loading {
        static let placeholderDelay: TimeInterval = ${formatNum(toSeconds(timing.loading.placeholderDelay))}
        static let minimumDisplay: TimeInterval = ${formatNum(toSeconds(timing.loading.minimumDisplay))}
        static let slowThreshold: TimeInterval = ${formatNum(toSeconds(timing.loading.slowThreshold))}
        static let timeout: TimeInterval = ${formatNum(toSeconds(timing.loading.timeout))}
    }
}
`;

const cssMotion = `/* Generated from tokens/shared/misoto-motion.tokens.json by tokens/generate-shared.mjs. Do not edit. */
:root {
  --misoto-motion-curve-standard: cubic-bezier(${sx1}, ${sy1}, ${sx2}, ${sy2});
  --misoto-motion-curve-emphasized: cubic-bezier(${ex1}, ${ey1}, ${ex2}, ${ey2});
  --misoto-motion-duration-quick: ${toMs(motion.quickDuration)}ms;
  --misoto-motion-duration-standard: ${toMs(motion.standardDuration)}ms;
  --misoto-motion-duration-slow: ${toMs(motion.slowDuration)}ms;
  --misoto-motion-duration-breath: ${toMs(motion.breathDuration)}ms;
  --misoto-motion-duration-spin: ${toMs(motion.spinDuration)}ms;
  --misoto-motion-duration-spin-enso: ${toMs(motion.spinEnsoDuration)}ms;
  --misoto-motion-breath-low: ${motion.breathLow.$value};
  --misoto-motion-enter-offset: ${motion.enterOffset.$value.value}px;
  --misoto-motion-enter-scale: ${motion.enterScale.$value};
  --misoto-motion-stagger: ${toMs(motion.stagger)}ms;
  --misoto-motion-press-scale: ${motion.pressScale.$value};
  --misoto-motion-press-opacity: ${motion.pressOpacity.$value};
}
`;

const ktMotion = `// Generated from tokens/shared/misoto-motion.tokens.json by tokens/generate-shared.mjs. Do not edit.
package app.misoto.tokens

object MisotoMotionTokens {
    val standardCurve = floatArrayOf(${formatNum(sx1)}f, ${formatNum(sy1)}f, ${formatNum(sx2)}f, ${formatNum(sy2)}f)
    val emphasizedCurve = floatArrayOf(${formatNum(ex1)}f, ${formatNum(ey1)}f, ${formatNum(ex2)}f, ${formatNum(ey2)}f)

    const val quickDurationMs: Long = ${toMs(motion.quickDuration)}L
    const val standardDurationMs: Long = ${toMs(motion.standardDuration)}L
    const val slowDurationMs: Long = ${toMs(motion.slowDuration)}L
    const val breathDurationMs: Long = ${toMs(motion.breathDuration)}L
    const val spinDurationMs: Long = ${toMs(motion.spinDuration)}L
    const val spinEnsoDurationMs: Long = ${toMs(motion.spinEnsoDuration)}L
    const val breathLow: Double = ${formatNum(motion.breathLow.$value)}

    const val enterOffsetDp: Double = ${formatNum(motion.enterOffset.$value.value)}
    const val enterScale: Double = ${formatNum(motion.enterScale.$value)}
    const val staggerMs: Long = ${toMs(motion.stagger)}L

    const val pressScale: Double = ${formatNum(motion.pressScale.$value)}
    const val pressOpacity: Double = ${formatNum(motion.pressOpacity.$value)}
}
`;

const cssTiming = `/* Generated from tokens/shared/misoto-timing.tokens.json by tokens/generate-shared.mjs. Do not edit. */
:root {
  --misoto-toast-short-duration: ${toMs(timing.toast.shortDuration)}ms;
  --misoto-toast-undo-duration: ${toMs(timing.toast.undoDuration)}ms;
  --misoto-toast-voiceover-duration: ${toMs(timing.toast.voiceOverDuration)}ms;
  --misoto-loading-placeholder-delay: ${toMs(timing.loading.placeholderDelay)}ms;
  --misoto-loading-minimum-display: ${toMs(timing.loading.minimumDisplay)}ms;
  --misoto-loading-slow-threshold: ${toMs(timing.loading.slowThreshold)}ms;
  --misoto-loading-timeout: ${toMs(timing.loading.timeout)}ms;
}
`;

const ktTiming = `// Generated from tokens/shared/misoto-timing.tokens.json by tokens/generate-shared.mjs. Do not edit.
package app.misoto.tokens

object MisotoTimingTokens {
    const val toastShortDurationMs: Long = ${toMs(timing.toast.shortDuration)}L
    const val toastUndoDurationMs: Long = ${toMs(timing.toast.undoDuration)}L
    const val toastVoiceOverDurationMs: Long = ${toMs(timing.toast.voiceOverDuration)}L

    const val loadingPlaceholderDelayMs: Long = ${toMs(timing.loading.placeholderDelay)}L
    const val loadingMinimumDisplayMs: Long = ${toMs(timing.loading.minimumDisplay)}L
    const val loadingSlowThresholdMs: Long = ${toMs(timing.loading.slowThreshold)}L
    const val loadingTimeoutMs: Long = ${toMs(timing.loading.timeout)}L
}
`;

const outputs = [
  [join(root, "Sources/MisotoMotion/GeneratedMotionTokens.swift"), swiftMotion],
  [join(root, "Sources/MisotoComponents/GeneratedTimingTokens.swift"), swiftTiming],
  [join(here, "dist/misoto-motion.css"), cssMotion],
  [join(here, "dist/MisotoMotionTokens.kt"), ktMotion],
  [join(here, "dist/misoto-timing.css"), cssTiming],
  [join(here, "dist/MisotoTimingTokens.kt"), ktTiming],
];

let drifted = false;
for (const [target, content] of outputs) {
  if (check) {
    if (!existsSync(target) || readFileSync(target, "utf8") !== content) {
      console.error(`stale: ${target}`);
      drifted = true;
    }
  } else {
    mkdirSync(dirname(target), { recursive: true });
    writeFileSync(target, content);
    console.log(`wrote ${target}`);
  }
}

process.exit(drifted ? 1 : 0);
