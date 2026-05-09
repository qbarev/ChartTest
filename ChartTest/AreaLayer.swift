import UIKit

final class AreaLayer: LineLayer {

    var areaColor: UIColor? {
        didSet { updateGradient() }
    }

    override var path: CGPath? {
        didSet { updateGradient() }
    }

    private let gradientLayer = CAGradientLayer()
    private let gradientMask = CAShapeLayer()

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
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientMask.fillColor = UIColor.white.cgColor
        gradientLayer.mask = gradientMask
        insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSublayers() {
        super.layoutSublayers()
        gradientLayer.frame = bounds
        gradientMask.frame = bounds
        updateGradient()
    }

    private func updateGradient() {
        guard let color = areaColor, let linePath = path else {
            gradientLayer.isHidden = true
            return
        }

        gradientLayer.isHidden = false
        gradientLayer.colors = [
            color.withAlphaComponent(0.4).cgColor,
            color.withAlphaComponent(0.0).cgColor
        ]

        let fillPath = CGMutablePath()
        fillPath.addPath(linePath)

        let box = linePath.boundingBox
        fillPath.addLine(to: CGPoint(x: box.maxX, y: bounds.height))
        fillPath.addLine(to: CGPoint(x: box.minX, y: bounds.height))
        fillPath.closeSubpath()

        gradientMask.path = fillPath
    }
}
