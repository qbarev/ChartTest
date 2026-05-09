import UIKit

// MARK: - Data Model

struct ChartSegment {

    struct Style {
        let lineColor: UIColor
        let areaColor: UIColor
    }

    let points: [CGPoint]
    let style: Style
}

// MARK: - AreaSeriesView

final class AreaSeriesView: UIView {

    var segments: [ChartSegment] = [] {
        didSet { setNeedsLayout() }
    }

    private let lineWidth: CGFloat = 1.5
    private var chartLayers: [AreaLayer] = []

    override func layoutSubviews() {
        super.layoutSubviews()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        rebuild()
        CATransaction.commit()
    }

    private func rebuild() {
        chartLayers.forEach { $0.removeFromSuperlayer() }
        chartLayers.removeAll()

        let drawer = SegmentSeriesDrawer(
            pointsPerSegment: segments.map(\.points),
            bounds: bounds
        )
        guard drawer.count > 0 else { return }

        for (index, segment) in segments.enumerated() {
            let area = AreaLayer()
            area.frame = bounds
            area.lineColor = segment.style.lineColor
            area.lineWidth = lineWidth
            area.areaColor = segment.style.areaColor
            area.path = drawer[index]

            layer.insertSublayer(area, at: 0)
            chartLayers.append(area)
        }
    }
}
