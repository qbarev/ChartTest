import CoreGraphics

struct ChartPointMapper {

    private let minX: CGFloat
    private let minY: CGFloat
    private let rangeX: CGFloat
    private let rangeY: CGFloat
    private let bounds: CGRect
    private let padding: CGFloat

    init?(allPoints: [CGPoint], bounds: CGRect, padding: CGFloat = 16) {
        guard allPoints.count > 1 else { return nil }

        let allX = allPoints.map(\.x)
        let allY = allPoints.map(\.y)
        let minX = allX.min()!, maxX = allX.max()!
        let minY = allY.min()!, maxY = allY.max()!

        guard maxX > minX, maxY > minY else { return nil }

        self.minX = minX
        self.minY = minY
        self.rangeX = maxX - minX
        self.rangeY = maxY - minY
        self.bounds = bounds
        self.padding = padding
    }

    func map(_ point: CGPoint) -> CGPoint {
        let x = (point.x - minX) / rangeX * bounds.width
        let y = padding + (bounds.height - padding * 2) * (1 - (point.y - minY) / rangeY)
        return CGPoint(x: x, y: y)
    }

    func map(_ points: [CGPoint]) -> [CGPoint] {
        points.map { map($0) }
    }

}
