//
//  ViewController.swift
//  Calculator
//
//  Created by Roger Zhang on 2017-02-03.
//  Copyright © 2017 Roger Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
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
                descriptionLabel.text = brain.getDescription()
            }
            else {
                display.text = "0"
                descriptionLabel.text = " "
                userIsInTheMiddleOfTyping = false
            }
        }
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        guard userIsInTheMiddleOfTyping == true else {
            return
        }
        
        guard var number = display.text else {
            return
        }
        
        number.remove(at: number.index(before: number.endIndex))
        if number.isEmpty {
            number = "0"
            userIsInTheMiddleOfTyping = false
        }
        display.text = number
    }
    
    @IBAction func clear(_ sender: UIButton) {
        brain.clear()
        displayValue = 0
        userIsInTheMiddleOfTyping = false
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue!)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
    }
}

struct Constants {
    static let numberOfDecimalPoints = 6
}
