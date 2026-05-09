//
//  ViewController.swift
//  ChartTest
//
//  Created by Kirill Kubarev on 09.05.2026.
//

import UIKit

class ViewController: UIViewController {

    private let chartView = AreaSeriesView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        chartView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chartView)
        NSLayoutConstraint.activate([
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chartView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            chartView.heightAnchor.constraint(equalToConstant: 250)
        ])

        chartView.segments = makeTestSegments()

        let twoFingerGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleTwoFingerGesture(_:)))
        twoFingerGesture.numberOfTouchesRequired = 2
        twoFingerGesture.minimumPressDuration = 0
        view.addGestureRecognizer(twoFingerGesture)
    }

    @objc private func handleTwoFingerGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            guard gesture.numberOfTouches == 2 else { return }
            let p1 = gesture.location(ofTouch: 0, in: view)
            let p2 = gesture.location(ofTouch: 1, in: view)

            let start = view.convert(p1, to: chartView)
            let end = view.convert(p2, to: chartView)

            chartView.selection = ChartSelection(startPoint: start, endPoint: end)

        case .ended, .cancelled:
            chartView.selection = nil

        default:
            break
        }
    }

    private func makeTestSegments() -> [ChartSegment] {
        let blue = UIColor(red: 0.25, green: 0.52, blue: 0.96, alpha: 1.0)
        let blueArea = UIColor(red: 0.10, green: 0.21, blue: 0.38, alpha: 1.0)
        let green = UIColor(red: 0.33, green: 0.82, blue: 0.68, alpha: 1.0)
        let greenArea = UIColor(red: 0.13, green: 0.33, blue: 0.27, alpha: 1.0)
        let gray = UIColor(white: 0.65, alpha: 1.0)
        let grayArea = UIColor(white: 0.26, alpha: 1.0)

        var price: CGFloat = 291.0

        var bluePoints: [CGPoint] = []
        for i in 0..<120 {
            price += CGFloat.random(in: -0.4...0.42)
            price = max(288, min(295, price))
            bluePoints.append(CGPoint(x: CGFloat(i), y: price))
        }

        var greenPoints: [CGPoint] = []
        for i in 0..<100 {
            price += CGFloat.random(in: -0.4...0.42)
            price = max(288, min(295, price))
            greenPoints.append(CGPoint(x: CGFloat(120 + i), y: price))
        }

        var grayPoints: [CGPoint] = []
        for i in 0..<60 {
            price += CGFloat.random(in: -0.3...0.35)
            price = max(288, min(295, price))
            grayPoints.append(CGPoint(x: CGFloat(220 + i), y: price))
        }

        return [
            ChartSegment(
                points: bluePoints,
                style: .init(lineColor: blue, areaColor: blueArea)
            ),
            ChartSegment(
                points: greenPoints,
                style: .init(lineColor: green, areaColor: greenArea)
            ),
            ChartSegment(
                points: grayPoints,
                style: .init(lineColor: gray, areaColor: grayArea)
            )
        ]
    }
}

