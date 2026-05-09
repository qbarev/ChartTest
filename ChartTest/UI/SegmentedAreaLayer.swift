import UIKit

final class SegmentedAreaLayer: CALayer {

    private var areaLayers: [AreaLayer] = []

    func setSegments(_ segments: [ChartSegment], mapper: ChartPointMapper, lineWidth: CGFloat) {
        let drawer = SegmentSeriesDrawer(
            pointsPerSegment: segments.map(\.points),
            mapper: mapper
        )
        guard drawer.count > 0 else {
            areaLayers.forEach { $0.removeFromSuperlayer() }
            areaLayers.removeAll()
            return
        }

        while areaLayers.count > segments.count {
            areaLayers.removeLast().removeFromSuperlayer()
        }

        while areaLayers.count < segments.count {
            let area = AreaLayer()
            insertSublayer(area, at: 0)
            areaLayers.append(area)
        }

        for (index, segment) in segments.enumerated() {
            let path = drawer[index]
            let box = path.boundingBox
            let segmentFrame = CGRect(x: box.minX, y: 0, width: box.width, height: bounds.height)

            var transform = CGAffineTransform(translationX: -box.minX, y: 0)
            let localPath = path.copy(using: &transform)!

            let area = areaLayers[index]
            area.frame = segmentFrame
            area.lineColor = segment.style.lineColor
            area.lineWidth = lineWidth
            area.areaColor = segment.style.areaColor
            area.path = localPath
        }
    }
}
