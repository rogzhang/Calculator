//
//  ViewController.swift
//  Calculator
//
//  Created by Roger Zhang on 2017-02-03.
//  Copyright © 2017 Roger Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var sequence: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            var textCurrentlyInDisplay = display.text!
            if digit != "." || !textCurrentlyInDisplay.contains(".") {
                if digit == "⬅︎" {
                    textCurrentlyInDisplay.remove(at: textCurrentlyInDisplay.index(before: textCurrentlyInDisplay.endIndex))
                    if textCurrentlyInDisplay.isEmpty {
                        textCurrentlyInDisplay = String(0)
                    }
                    display.text = textCurrentlyInDisplay
                }
                else {
                    display.text = textCurrentlyInDisplay + digit
                }
            }
        } else {
            if digit != "⬅︎" {
                display.text = digit == "." ? "0" + digit : digit
                userIsInTheMiddleOfTyping = true
            }
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        sequence.text = brain.sequence ?? " "
        if let result = brain.result {
            displayValue = result
        }
    }
}

