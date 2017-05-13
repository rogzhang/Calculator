//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Roger Zhang on 2017-03-14.
//  Copyright © 2017 Roger Zhang. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String, Precedence)
        case nullaryOperation(() -> Double, String)
        case equals
    }
    
    private var operations: Dictionary<String,Operation> = [
        "%" : Operation.unaryOperation({ $0 / 100.0 }, { "%(\($0))"} ),
        "±" : Operation.unaryOperation({ -$0 }, { "-(\($0))"} ),
        "√" : Operation.unaryOperation(sqrt, { "√(\($0))"} ),
        "tan" : Operation.unaryOperation(tan, { "tan(\($0))"} ),
        "sin" : Operation.unaryOperation(sin, { "sin(\($0))"} ),
        "cos" : Operation.unaryOperation(cos, { "cos(\($0))"} ),
        "x²" : Operation.unaryOperation({ $0 * $0 }, { "(\($0)²"}),
        "÷" : Operation.binaryOperation({ $0 / $1 }, { "\($0) ÷ \($1)"}, Precedence.max ),
        "×" : Operation.binaryOperation({ $0 * $1 }, { "\($0) × \($1)"}, Precedence.max ),
        "−" : Operation.binaryOperation({ $0 - $1 }, { "\($0) − \($1)"}, Precedence.min ),
        "+" : Operation.binaryOperation({ $0 + $1 }, { "\($0) + \($1)"}, Precedence.min ),
        "rand" : Operation.nullaryOperation({ Double(arc4random()) }, "random()"),
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "=" : Operation.equals
    ]
    
    private enum Precedence: Int {
        case min = 0, max
    }
    
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
    
    private enum OpStack {
        case operand(Double)
        case operation(String)
        case variable(String)
    }
    
    private var internalProgram = [OpStack]()
    
    mutating func setOperand (_ operand: Double) {
        internalProgram.append(OpStack.operand(operand))
    }
    
    mutating func setOperand (variable named: String) {
        internalProgram.append(OpStack.variable(named))
    }
    
    mutating func performOperation (_ symbol: String) {
        internalProgram.append(OpStack.operation(symbol))
    }
    
    func evaluate(using variables: Dictionary<String,Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        
        var accumulator: Double?
        
        var pendingBinaryOperation: PendingBinaryOperation?
        
        var currentPrecedence = Precedence.max
        
        var descriptionAccumulator = " " {
            didSet {
                if pendingBinaryOperation == nil {
                    currentPrecedence = Precedence.max
                }
            }
        }
        
        var result: Double? {
            get {
                return accumulator
            }
        }
        
        var resultIsPending: Bool {
            get {
                return pendingBinaryOperation != nil
            }
        }
        
        var description: String {
            get {
                if pendingBinaryOperation == nil {
                    return descriptionAccumulator
                }
                else {
                    let description = pendingBinaryOperation!.performDescription(with: pendingBinaryOperation!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
                    let whitespace = (description.hasSuffix(" ") ? "" : " ")
                    return resultIsPending ? (description + whitespace + "...") : (description + whitespace + "=")
                }
            }
        }
        
        func setOperand(_ operand: Double) {
            accumulator = operand
            descriptionAccumulator = String(format:"%g", operand)
        }
        
        func setOperand(variable named: String) {
            accumulator = variables?[named] ?? 0
            descriptionAccumulator = named
        }
        
        func performPendingBinaryOperation() {
            if accumulator != nil && pendingBinaryOperation != nil {
                accumulator = pendingBinaryOperation!.perform(with: accumulator!)
                descriptionAccumulator = pendingBinaryOperation!.performDescription(with: descriptionAccumulator)
                pendingBinaryOperation = nil
            }
        }
        
        func performOperation(_ symbol: String) {
            if let operation = operations[symbol] {
                switch operation {
                case .constant(let value):
                    accumulator = value
                    descriptionAccumulator = symbol
                case .unaryOperation(let function, let descriptionFunction):
                    if accumulator != nil {
                        accumulator = function(accumulator!)
                        descriptionAccumulator = descriptionFunction(descriptionAccumulator)
                    }
                case .binaryOperation(let function, let descriptionFunction, let precedence):
                    performPendingBinaryOperation()
                    if currentPrecedence.rawValue < precedence.rawValue {
                        descriptionAccumulator = "(\(descriptionAccumulator))"
                    }
                    currentPrecedence = precedence
                    if accumulator != nil {
                        pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!, descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
                        accumulator = nil
                    }
                case .nullaryOperation(let function, let descriptionValue):
                    accumulator = function()
                    descriptionAccumulator = descriptionValue
                case .equals:
                    performPendingBinaryOperation()
                }
            }
        }
        
        guard !internalProgram.isEmpty else {
            return (nil, false, "?")
        }
        
        for op in internalProgram {
            switch op {
            case .operand(let operand):
                setOperand(operand)
            case .operation(let operation):
                performOperation(operation)
            case .variable(let symbol):
                setOperand(variable:symbol)
            }
        }
        
        return (result, resultIsPending, description)
        
    }
    
    mutating func clear() {
        internalProgram.removeAll()
    }
    
    mutating func undo() {
        if !internalProgram.isEmpty {
            internalProgram = Array(internalProgram.dropLast())
        }
    }
    
    @available(iOS, deprecated, message: "No longer needed")
    var description: String {
        get {
            return evaluate().description
        }
    }
    
    @available(iOS, deprecated, message: "No longer needed")
    var result: Double? {
        get {
            return evaluate().result
        }
    }
    
    @available(iOS, deprecated, message: "No longer needed")
    var resultIsPending: Bool {
        get {
            return evaluate().isPending
        }
    }
}
