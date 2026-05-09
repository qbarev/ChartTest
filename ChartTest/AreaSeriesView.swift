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

    var selection: ChartSelection? {
        didSet { updateSelection() }
    }

    private let lineWidth: CGFloat = 1.5
    private let dimmedOpacity: Float = 0.3
    private let positiveColor = UIColor(red: 0.33, green: 0.82, blue: 0.68, alpha: 1.0)
    private let negativeColor = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)

    private var chartLayers: [AreaLayer] = []
    private let selectionLayer = AreaLayer()
    private let selectionMask = CAShapeLayer()
    private var mapper: ChartPointMapper?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        selectionLayer.lineWidth = lineWidth
        selectionLayer.mask = selectionMask
        selectionLayer.isHidden = true
        layer.addSublayer(selectionLayer)
    }

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

        let allPoints = segments.flatMap(\.points)
        guard let mapper = ChartPointMapper(allPoints: allPoints, bounds: bounds) else { return }
        self.mapper = mapper

        let drawer = SegmentSeriesDrawer(
            pointsPerSegment: segments.map(\.points),
            mapper: mapper
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

        // Update selection layer path and keep it on top
        let fullPath = LineSeriesDrawer(points: mapper.map(allPoints)).path
        selectionLayer.frame = bounds
        selectionLayer.path = fullPath
        selectionMask.frame = bounds
        layer.addSublayer(selectionLayer)

        updateSelection()
    }

    private func updateSelection() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        guard let selection = selection else {
            selectionLayer.isHidden = true
            chartLayers.forEach { $0.opacity = 1.0 }
            CATransaction.commit()
            return
        }

        selectionLayer.isHidden = false
        chartLayers.forEach { $0.opacity = dimmedOpacity }

        let rawMinX = min(selection.startPoint.x, selection.endPoint.x)
        let rawMaxX = max(selection.startPoint.x, selection.endPoint.x)

        // Snap to nearest data points
        let allMapped = segments.flatMap(\.points).compactMap { mapper?.map($0) }
        guard let snappedStart = allMapped.min(by: { abs($0.x - rawMinX) < abs($1.x - rawMinX) }),
              let snappedEnd = allMapped.min(by: { abs($0.x - rawMaxX) < abs($1.x - rawMaxX) }) else {
            CATransaction.commit()
            return
        }

        // Trend from data Y at snapped edges (screen Y inverted)
        let isPositive = snappedStart.y >= snappedEnd.y
        let trendColor = isPositive ? positiveColor : negativeColor
        selectionLayer.lineColor = trendColor
        selectionLayer.areaColor = trendColor

        let maskRect = CGRect(x: snappedStart.x, y: 0, width: snappedEnd.x - snappedStart.x, height: bounds.height)
        selectionMask.path = UIBezierPath(rect: maskRect).cgPath

        CATransaction.commit()
    }
}
