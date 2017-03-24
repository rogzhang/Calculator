//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Roger Zhang on 2017-02-03.
//  Copyright © 2017 Roger Zhang. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var graphButton: UIButton!
    @IBOutlet private weak var display: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if digit != "." || textCurrentlyInDisplay.contains(".") == false {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = digit == "." ? "0." : digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    private var displayValue: Double? {
        get {
            if let text = display.text, let value = NumberFormatter().number(from: text)?.doubleValue {
                    return value
            }
            return nil
        }
        set {
            if let value = newValue {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = Constants.numberOfDecimalPoints
                let valueNSNumber = NSNumber(value: value)
                display.text = formatter.string(from: valueNSNumber)
            }
            else {
                display.text = "0"
                userIsInTheMiddleOfTyping = false
            }
        }
    }
    
    private var displayResult: (result: Double?, isPending: Bool, description: String) = (nil, false, " ") {
        didSet {
            if let result = displayResult.result {
                displayValue = result
            }
            else if displayResult.description == "?" {
                displayValue = 0
            }
            descriptionLabel.text = displayResult.description
        }
    }
    
    @IBAction private func backspace(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            guard var number = display.text else {
                return
            }
            number.remove(at: number.index(before: number.endIndex))
            if number.isEmpty {
                number = "0"
                userIsInTheMiddleOfTyping = false
            }
            display.text = number
        } else {
            brain.undo()
            displayResult = brain.evaluate(using: variableValues)
            graphButton.isEnabled = !displayResult.isPending
        }
    }
    
    @IBAction func pushM(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        let symbol = String((sender.currentTitle!).characters.dropFirst())
        variableValues[symbol] = displayValue
        displayResult = brain.evaluate(using: variableValues)
        graphButton.isEnabled = !displayResult.isPending
    }
    
    @IBAction func setM(_ sender: UIButton) {
        brain.setOperand(variable: sender.currentTitle!)
        displayResult = brain.evaluate(using: variableValues)
        graphButton.isEnabled = !displayResult.isPending
    }
    
    @IBAction private func clear(_ sender: UIButton) {
        brain.clear()
        displayValue = 0
        descriptionLabel.text = " "
        variableValues = [:]
        userIsInTheMiddleOfTyping = false
    }
    
    private var brain = CalculatorBrain()
    private var variableValues = [String: Double]()
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue!)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayResult = brain.evaluate(using: variableValues)
        graphButton.isEnabled = !displayResult.isPending
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "graph" && !displayResult.isPending {
                if let graphViewController = (segue.destination.contents as? GraphViewController) {
                    graphViewController.navigationItem.title = displayResult.description
                    graphViewController.function = { (x: CGFloat) -> Double in
                        self.variableValues[Constants.variableM] = Double(x)
                        self.displayResult = self.brain.evaluate(using: self.variableValues)
                        return self.displayResult.result!
                    }
                }
            }
        }
    }
}

extension UIViewController
{
    var contents: UIViewController {
        get {
            if let navigationController = self as? UINavigationController {
                return navigationController.visibleViewController ?? self
            } else {
                return self
            }
        }
    }
}
