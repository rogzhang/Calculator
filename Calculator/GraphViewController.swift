//
//  GraphViewController.swift
//  Calculator
//
//  Created by Roger Zhang on 2017-03-22.
//  Copyright © 2017 Roger Zhang. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            let tapRecognizer = UITapGestureRecognizer(target: graphView, action: #selector(GraphView.changeOrigin(byReactingTo:)))
            tapRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tapRecognizer)
            let pinchRecognizer = UIPinchGestureRecognizer(target: graphView, action: #selector(GraphView.changeScale(byReactingTo:)))
            graphView.addGestureRecognizer(pinchRecognizer)
            let panRecognizer = UIPanGestureRecognizer(target: graphView, action: #selector(GraphView.translateOrigin(byReactingTo:)))
            graphView.addGestureRecognizer(panRecognizer)
            updateUI()
        }
    }
    
    func getYCoordinate(_ x: CGFloat) -> CGFloat? {
        if let function = function {
            return CGFloat(function(x))
        }
        return nil
    }
    
    var function: ((CGFloat) -> Double)? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        graphView?.getYCoordinateFunction = getYCoordinate
    }
}
