import CoreGraphics

struct LineSeriesDrawer {

    let path: CGPath

    init(points: [CGPoint]) {
        let mutablePath = CGMutablePath()
        guard !points.isEmpty else {
            path = mutablePath
            return
        }

        mutablePath.move(to: points[0])
        for i in 1..<points.count {
            mutablePath.addLine(to: points[i])
        }

        path = mutablePath
    }
}
