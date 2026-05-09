# ChartTest

Financial line chart built with UIKit and CoreAnimation. Supports multi-colored segments with gradient fills and two-finger selection with trend-based coloring.

## Features

- **Segmented line chart** — multiple segments with individual line and gradient colors
- **Gradient fills** — vertical gradient from line to bottom, per segment
- **Two-finger selection** — long press with two fingers to select a range
- **Trend coloring** — selection area turns green (positive) or red (negative) based on price direction
- **Data point snapping** — selection edges snap to nearest data points
- **Inverted masking** — prevents color blending between selection and background segments

## Architecture

```
LineLayer → AreaLayer → SegmentedAreaLayer
```

- `LineLayer` — base CALayer with stroke path
- `AreaLayer` — adds gradient fill below the line
- `SegmentedAreaLayer` — groups segments for unified masking
- `AreaSeriesView` — main chart view with selection logic
- `ChartPointMapper` — data space ↔ screen space conversion
- `SegmentSeriesDrawer` / `LineSeriesDrawer` — CGPath construction

## Requirements

- iOS 18.0+
- Xcode 26.0+
- Swift 5.0+
