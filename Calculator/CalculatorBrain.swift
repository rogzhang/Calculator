//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Roger Zhang on 2017-03-14.
//  Copyright © 2017 Roger Zhang. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator: (accumulator: Double?, description: String?)
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
        case clear
    }
    
    private var operations: Dictionary<String,Operation> =
    [
        "√" : Operation.unaryOperation(sqrt),
        "C" : Operation.clear,
        "%" : Operation.unaryOperation({ $0 / 100.0 }),
        "±" : Operation.unaryOperation({ -$0 }),
        "÷" : Operation.binaryOperation({ $0 / $1 }),
        "tan" : Operation.unaryOperation(tan),
        "×" : Operation.binaryOperation({ $0 * $1 }),
        "sin" : Operation.unaryOperation(sin),
        "−" : Operation.binaryOperation({ $0 - $1 }),
        "cos" : Operation.unaryOperation(cos),
        "+" : Operation.binaryOperation({ $0 + $1 }),
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "=" : Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator.accumulator = value
                updateDescription(with: symbol, ofOperation : operation);
            case .unaryOperation(let function):
                if accumulator.accumulator != nil {
                    accumulator.accumulator = function(accumulator.accumulator!)
                    updateDescription(with: symbol, ofOperation : operation);
                }
            case .binaryOperation(let function):
                if accumulator.accumulator != nil {
                    performPendingBinaryOperation()
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator.accumulator!)
                    accumulator.accumulator = nil
                    updateDescription(with: symbol, ofOperation : operation);
                }
            case .equals:
                performPendingBinaryOperation()
                updateDescription(with: symbol, ofOperation : operation);
            case .clear:
                accumulator.accumulator = 0
                accumulator.description = nil
                pendingBinaryOperation = nil
                previousDescription = nil
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator.accumulator != nil {
            accumulator.accumulator = pendingBinaryOperation!.perform(with: accumulator.accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double,Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator.accumulator = operand
        updateDescription(with: "\(operand)", ofOperation : Operation.constant(operand));
    }
    
    private var previousDescription : String?
    
    private mutating func updateDescription(with description: String, ofOperation operation: Operation) {
        if let oldDescription = accumulator.description {
            switch operation {
            case .constant(_):
                previousDescription = description
            case .unaryOperation(_):
                if previousDescription != nil {
                    previousDescription = description + "(" + previousDescription! + ")"
                    accumulator.description = oldDescription + " " + previousDescription!
                    previousDescription = nil
                } else {
                    accumulator.description = description + "(" + oldDescription + ")"
                    previousDescription = accumulator.description
                }
            case .binaryOperation(_):
                if previousDescription != nil {
                    accumulator.description = previousDescription! + " " + description
                    previousDescription = nil
                } else {
                    accumulator.description = oldDescription + " " + description
                }
            case .equals:
                if previousDescription != nil {
                    accumulator.description = oldDescription + " " + previousDescription!
                    previousDescription = nil
                }
            default: break
                
            }
        }
        else {
            accumulator.description = description
            previousDescription = description
        }
    }
    
    var sequence: String? {
        get {
            if let description = accumulator.description {
                return resultIsPending ? description + " ..." : description + " ="
            }
            else {
                return nil
            }
        }
    }
    
    var result: Double? {
        get {
            return accumulator.accumulator
        }
    }
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil ? true : false
        }
    }
}
