import UIKit

final class AreaSeriesView: UIView {

    var segments: [ChartSegment] = [] {
        didSet { setNeedsLayout() }
    }

    var selection: ChartSelection? {
        didSet { updateSelection() }
    }

    private let lineWidth: CGFloat = 1.5
    private let dimmedOpacity: Float = 0.3
    private let positiveLineColor = UIColor(red: 0.33, green: 0.82, blue: 0.68, alpha: 1.0)
    private let positiveAreaColor = UIColor(red: 0.13, green: 0.33, blue: 0.27, alpha: 1.0)
    private let negativeLineColor = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
    private let negativeAreaColor = UIColor(red: 0.36, green: 0.12, blue: 0.12, alpha: 1.0)

    private let segmentedLayer = SegmentedAreaLayer()
    private let selectionLayer = AreaLayer()
    private let selectionMask = CAShapeLayer()
    private let invertedMask = CAShapeLayer()
    private var mapper: ChartPointMapper?
    private var mappedPoints: [CGPoint] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        layer.addSublayer(segmentedLayer)

        selectionLayer.lineWidth = lineWidth
        selectionLayer.mask = selectionMask
        selectionLayer.isHidden = true
        layer.addSublayer(selectionLayer)

        invertedMask.fillRule = .evenOdd
        segmentedLayer.mask = invertedMask
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        rebuild()
        CATransaction.commit()
    }

    private func rebuild() {
        let allPoints = segments.flatMap(\.points)
        guard let mapper = ChartPointMapper(allPoints: allPoints, bounds: bounds) else { return }
        self.mapper = mapper

        let drawer = SegmentSeriesDrawer(
            pointsPerSegment: segments.map(\.points),
            mapper: mapper
        )
        guard drawer.count > 0 else { return }

        // Build segments for SegmentedAreaLayer
        var areaSegments: [AreaSegment] = []
        for (index, segment) in segments.enumerated() {
            areaSegments.append(AreaSegment(path: drawer[index], style: segment.style))
        }

        segmentedLayer.frame = bounds
        segmentedLayer.setSegments(areaSegments, lineWidth: lineWidth)

        // Cache mapped points for selection snapping
        mappedPoints = mapper.map(allPoints)

        // Update selection layer path and keep it on top
        let fullPath = LineSeriesDrawer(points: mappedPoints).path
        selectionLayer.frame = bounds
        selectionLayer.path = fullPath
        selectionMask.frame = bounds

        updateSelection()
    }

    private func updateSelection() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        guard let selection = selection else {
            selectionLayer.isHidden = true
            segmentedLayer.opacity = 1.0
            invertedMask.path = UIBezierPath(rect: bounds).cgPath
            CATransaction.commit()
            return
        }

        guard mappedPoints.count > 1 else {
            CATransaction.commit()
            return
        }

        selectionLayer.isHidden = false
        segmentedLayer.opacity = dimmedOpacity

        let rawMinX = min(selection.startPoint.x, selection.endPoint.x)
        let rawMaxX = max(selection.startPoint.x, selection.endPoint.x)

        // Snap to nearest data points (binary search)
        guard let startIndex = mappedPoints.nearestIndex(to: rawMinX, by: \.x),
              let endIndex = mappedPoints.nearestIndex(to: rawMaxX, by: \.x) else {
            CATransaction.commit()
            return
        }
        let snappedStart = mappedPoints[startIndex]
        let snappedEnd = mappedPoints[endIndex]

        // Trend from data Y at snapped edges (screen Y inverted)
        let isPositive = snappedStart.y >= snappedEnd.y
        selectionLayer.lineColor = isPositive ? positiveLineColor : negativeLineColor
        selectionLayer.areaColor = isPositive ? positiveAreaColor : negativeAreaColor

        let selectionRect = CGRect(x: snappedStart.x, y: 0, width: snappedEnd.x - snappedStart.x, height: bounds.height)
        selectionMask.path = UIBezierPath(rect: selectionRect).cgPath

        // Inverted mask on segmentedLayer: show everything except selection area
        let path = UIBezierPath(rect: bounds)
        path.append(UIBezierPath(rect: selectionRect))

        invertedMask.frame = bounds
        invertedMask.path = path.cgPath

        CATransaction.commit()
    }

}
