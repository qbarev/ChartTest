import CoreGraphics

struct SegmentSeriesDrawer {

    private let paths: [CGPath]

    init(pointsPerSegment: [[CGPoint]], mapper: ChartPointMapper) {
        var result: [CGPath] = []

        for (index, points) in pointsPerSegment.enumerated() {
            var mapped: [CGPoint] = []

            if index > 0, let prevLast = pointsPerSegment[index - 1].last {
                mapped.reserveCapacity(points.count + 1)
                mapped.append(mapper.map(prevLast))
            } else {
                mapped.reserveCapacity(points.count)
            }

            mapped.append(contentsOf: mapper.map(points))

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
