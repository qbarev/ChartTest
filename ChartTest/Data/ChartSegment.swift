import UIKit

struct ChartSegment {

    struct Style {
        let lineColor: UIColor
        let areaColor: UIColor
    }

    let points: [CGPoint]
    let style: Style
}
