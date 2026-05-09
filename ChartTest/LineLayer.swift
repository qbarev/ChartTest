import UIKit

class LineLayer: CALayer {

    var path: CGPath? {
        didSet { updateLine() }
    }

    var lineColor: UIColor = .white {
        didSet { shapeLayer.strokeColor = lineColor.cgColor }
    }

    var lineWidth: CGFloat = 1.5 {
        didSet { shapeLayer.lineWidth = lineWidth }
    }

    private let shapeLayer = CAShapeLayer()

    override init() {
        super.init()
        setup()
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        shapeLayer.fillColor = nil
        shapeLayer.lineJoin = .round
        shapeLayer.lineCap = .round
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = lineWidth
        addSublayer(shapeLayer)
    }

    override func layoutSublayers() {
        super.layoutSublayers()
        shapeLayer.frame = bounds
    }

    private func updateLine() {
        shapeLayer.path = path
    }
}
