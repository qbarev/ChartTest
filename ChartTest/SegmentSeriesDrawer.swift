import CoreGraphics

struct SegmentSeriesDrawer {

    private let paths: [CGPath]

    init(pointsPerSegment: [[CGPoint]], bounds: CGRect) {
        let allPoints = pointsPerSegment.flatMap { $0 }
        guard allPoints.count > 1 else {
            paths = []
            return
        }

        let allX = allPoints.map(\.x)
        let allY = allPoints.map(\.y)
        let minX = allX.min()!, maxX = allX.max()!
        let minY = allY.min()!, maxY = allY.max()!

        guard maxX > minX, maxY > minY else {
            paths = []
            return
        }

        let padding: CGFloat = 16

        func mapPoint(_ pt: CGPoint) -> CGPoint {
            let x = (pt.x - minX) / (maxX - minX) * bounds.width
            let y = padding + (bounds.height - padding * 2) * (1 - (pt.y - minY) / (maxY - minY))
            return CGPoint(x: x, y: y)
        }

        var result: [CGPath] = []

        for (index, points) in pointsPerSegment.enumerated() {
            var mapped = points.map { mapPoint($0) }

            if index > 0, let prevLast = pointsPerSegment[index - 1].last {
                mapped.insert(mapPoint(prevLast), at: 0)
            }

            let drawer = LineSeriesDrawer(points: mapped)
            result.append(drawer.path)
        }

        paths = result
    }

    subscript(index: Int) -> CGPath {
        paths[index]
    }

    var count: Int {
        paths.count
    }
}
