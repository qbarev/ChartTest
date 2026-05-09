# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build

```bash
xcodebuild -project ChartTest.xcodeproj -scheme ChartTest -destination 'platform=iOS Simulator,name=iPhone 16' build
```

No tests or linter configured.

## Architecture

UIKit + CoreAnimation financial line chart with colored segments, gradient fills, and two-finger selection.

**Layer hierarchy:** `LineLayer` (CALayer with CAShapeLayer for stroke) → `AreaLayer` (adds CAGradientLayer fill below the line) → `SegmentedAreaLayer` (groups multiple AreaLayers under one CALayer for unified masking).

**Data flow:** `ChartSegment` (points + style) → `ChartPointMapper` (data space → screen space) → `SegmentSeriesDrawer` (builds CGPath per segment, connecting boundaries) → `AreaSegment` (path + style) → `SegmentedAreaLayer`.

**Selection:** Two-finger gesture on ViewController generates `ChartSelection` → `AreaSeriesView.updateSelection()` snaps to nearest data points, determines trend color (positive/negative), applies selection mask on `selectionLayer` and inverted even-odd mask on `segmentedLayer` to prevent color blending.

**Key design decisions:**
- Segments share no duplicate points at boundaries; `SegmentSeriesDrawer` inserts the previous segment's last point automatically
- Earlier segments render on top (z-order via `insertSublayer(at: 0)`)
- Gradient area colors are opaque (pre-multiplied for black background) to avoid alpha blending artifacts during selection
- Project uses `PBXFileSystemSynchronizedRootGroup` — Xcode auto-syncs filesystem changes, no manual pbxproj edits needed for adding/moving files
