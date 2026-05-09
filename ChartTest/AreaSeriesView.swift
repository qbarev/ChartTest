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

        let allPoints = segments.flatMap { $0.points }
        guard allPoints.count > 1 else { return }

        let allX = allPoints.map(\.x)
        let allY = allPoints.map(\.y)
        let minX = allX.min()!, maxX = allX.max()!
        let minY = allY.min()!, maxY = allY.max()!
        guard maxX > minX, maxY > minY else { return }

        let padding: CGFloat = 16

        func mapPoint(_ pt: CGPoint) -> CGPoint {
            let x = (pt.x - minX) / (maxX - minX) * bounds.width
            let y = padding + (bounds.height - padding * 2) * (1 - (pt.y - minY) / (maxY - minY))
            return CGPoint(x: x, y: y)
        }

        for (index, segment) in segments.enumerated() {
            guard !segment.points.isEmpty else { continue }

            let mapped = segment.points.map { mapPoint($0) }
            let path = CGMutablePath()

            if index > 0, let prevLast = segments[index - 1].points.last {
                path.move(to: mapPoint(prevLast))
                path.addLine(to: mapped[0])
            } else {
                path.move(to: mapped[0])
            }

            for i in 1..<mapped.count {
                path.addLine(to: mapped[i])
            }

            let area = AreaLayer()
            area.frame = bounds
            area.lineColor = segment.style.lineColor
            area.lineWidth = lineWidth
            area.areaColor = segment.style.areaColor
            area.path = path

            layer.insertSublayer(area, at: 0)
            chartLayers.append(area)
        }
    }
}
