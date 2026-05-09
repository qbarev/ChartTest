import UIKit

struct AreaSegment {
    let path: CGPath
    let style: ChartSegment.Style
}

final class SegmentedAreaLayer: CALayer {

    private var areaLayers: [AreaLayer] = []

    func setSegments(_ segments: [AreaSegment], lineWidth: CGFloat) {
        areaLayers.forEach { $0.removeFromSuperlayer() }
        areaLayers.removeAll()

        for segment in segments {
            let area = AreaLayer()
            area.frame = bounds
            area.lineColor = segment.style.lineColor
            area.lineWidth = lineWidth
            area.areaColor = segment.style.areaColor
            area.path = segment.path

            insertSublayer(area, at: 0)
            areaLayers.append(area)
        }
    }

    override func layoutSublayers() {
        super.layoutSublayers()
        areaLayers.forEach { $0.frame = bounds }
    }
}
