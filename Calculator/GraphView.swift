//
//  GraphView.swift
//  Calculator
//
//  Created by Roger Zhang on 2017-03-22.
//  Copyright © 2017 Roger Zhang. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    @IBInspectable
    var origin: CGPoint! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var scale = CGFloat(Constants.pointsPerUnit) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var lineWidth: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var color: UIColor = UIColor.blue {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var getYCoordinateFunction: ((CGFloat) -> CGFloat?)?
    
    private let drawer = AxesDrawer()
    
    override func draw(_ rect: CGRect) {
        origin = origin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        color.set()
        pathForFunction().stroke()
        drawer.drawAxes(in: rect, origin: origin, pointsPerUnit: scale)
    }
    
    private func pathForFunction() -> UIBezierPath {
        let path = UIBezierPath()
        
        var pathIsEmpty = true
        var point = CGPoint()
        
        let width = Int(bounds.size.width * scale)
        for pixel in 0...width {
            point.x = CGFloat(pixel) / scale
            if getYCoordinateFunction != nil {
                if let y = getYCoordinateFunction!((point.x - origin.x) / scale) {
                    if !y.isNormal && !y.isZero {
                        pathIsEmpty = true
                        continue
                    }
                    
                    point.y = origin.y - y * scale
                    
                    if pathIsEmpty {
                        path.move(to: point)
                        pathIsEmpty = false
                    } else {
                        path.addLine(to: point)
                    }
                }
            }
        }
        path.lineWidth = lineWidth
        return path
    }
    
    func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed,.ended:
            scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
        default:
            break
        }
    }
    
    func changeOrigin(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        switch tapRecognizer.state {
        case .ended:
            origin = tapRecognizer.location(in: self)
        default:
            break
        }
    }
    
    func translateOrigin(byReactingTo panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .changed:
            fallthrough
        case .ended:
            let translation = panRecognizer.translation(in: self)
            origin.x += translation.x
            origin.y += translation.y
            panRecognizer.setTranslation(CGPoint.zero, in: self)
        default:
            break
        }
    }
}
