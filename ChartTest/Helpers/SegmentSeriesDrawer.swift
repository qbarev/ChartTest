import CoreGraphics

struct SegmentSeriesDrawer {

    private let paths: [CGPath]

    init(pointsPerSegment: [[CGPoint]], mapper: ChartPointMapper) {
        var result: [CGPath] = []

        for (index, points) in pointsPerSegment.enumerated() {
            var mapped = mapper.map(points)

            if index > 0, let prevLast = pointsPerSegment[index - 1].last {
                mapped.insert(mapper.map(prevLast), at: 0)
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
