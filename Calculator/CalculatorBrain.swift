//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Roger Zhang on 2017-03-14.
//  Copyright © 2017 Roger Zhang. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator = 0.0
    
    private var descriptionAccumulator = "0" {
        didSet {
            if pendingBinaryOperation == nil {
                currentPrecedence = Precedence.Max
            }
        }
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String, Precedence)
        case nullaryOperation(() -> Double, String)
        case equals
    }
    
    private var operations: Dictionary<String,Operation> =
    [
        "%" : Operation.unaryOperation({ $0 / 100.0 }, { "%(\($0))"} ),
        "±" : Operation.unaryOperation({ -$0 }, { "-(\($0))"} ),
        "√" : Operation.unaryOperation(sqrt, { "√(\($0))"} ),
        "tan" : Operation.unaryOperation(tan, { "tan(\($0))"} ),
        "sin" : Operation.unaryOperation(sin, { "sin(\($0))"} ),
        "cos" : Operation.unaryOperation(cos, { "cos(\($0))"} ),
        "x²" : Operation.unaryOperation({ $0 * $0 }, { "(\($0)²"}),
        "÷" : Operation.binaryOperation({ $0 / $1 }, { "\($0) ÷ \($1)"}, Precedence.Max ),
        "×" : Operation.binaryOperation({ $0 * $1 }, { "\($0) × \($1)"}, Precedence.Max ),
        "−" : Operation.binaryOperation({ $0 - $1 }, { "\($0) − \($1)"}, Precedence.Min ),
        "+" : Operation.binaryOperation({ $0 + $1 }, { "\($0) + \($1)"}, Precedence.Min ),
        "rand" : Operation.nullaryOperation({ Double(arc4random()) }, "random()"),
        "π" : Operation.constant(M_PI),
        "e" : Operation.constant(M_E),
        "=" : Operation.equals
    ]
    
    private enum Precedence: Int {
        case Min = 0, Max
    }
    
    private var currentPrecedence = Precedence.Max
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .unaryOperation(let function, let descriptionFunction):
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .binaryOperation(let function, let descriptionFunction, let precedence):
                performPendingBinaryOperation()
                if currentPrecedence.rawValue < precedence.rawValue {
                    descriptionAccumulator = "(\(descriptionAccumulator))"
                }
                currentPrecedence = precedence
                pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator, descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
            case .nullaryOperation(let function, let descriptionValue):
                accumulator = function()
                descriptionAccumulator = descriptionValue
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator)
            descriptionAccumulator = pendingBinaryOperation!.performDescription(with: descriptionAccumulator)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double,Double) -> Double
        let firstOperand: Double
        let descriptionFunction: (String,String) -> String
        let descriptionOperand: String
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        func performDescription(with secondDescriptionOperand: String) -> String {
            return descriptionFunction(descriptionOperand, secondDescriptionOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        descriptionAccumulator = String(format:"%g", operand)
    }
    
    mutating func clear() {
        pendingBinaryOperation = nil
        accumulator = 0.0
        descriptionAccumulator = "0"
    }
    
    var description: String {
        get {
            if pendingBinaryOperation == nil {
                return descriptionAccumulator
            }
            else {
                return pendingBinaryOperation!.performDescription(with: pendingBinaryOperation!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    func getDescription() -> String {
        let whitespace = (description.hasSuffix(" ") ? "" : " ")
        return resultIsPending ? (description + whitespace + "...") : (description + whitespace + "=")
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil ? true : false
        }
    }
}
