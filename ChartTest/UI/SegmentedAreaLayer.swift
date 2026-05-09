import UIKit

final class SegmentedAreaLayer: CALayer {

    private var areaLayers: [AreaLayer] = []

    func setSegments(_ segments: [AreaSegment], lineWidth: CGFloat) {
        areaLayers.forEach { $0.removeFromSuperlayer() }
        areaLayers.removeAll()

        for segment in segments {
            let box = segment.path.boundingBox
            let segmentFrame = CGRect(x: box.minX, y: 0, width: box.width, height: bounds.height)

            var transform = CGAffineTransform(translationX: -box.minX, y: 0)
            let localPath = segment.path.copy(using: &transform)!

            let area = AreaLayer()
            area.frame = segmentFrame
            area.lineColor = segment.style.lineColor
            area.lineWidth = lineWidth
            area.areaColor = segment.style.areaColor
            area.path = localPath

            insertSublayer(area, at: 0)
            areaLayers.append(area)
        }
    }
}
