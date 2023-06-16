//
//  main.swift
//  grapher
//
//  Created by Максим Лейхнер on 03.04.2023.
//

import Foundation

var inputPath = ""
var type: FileType = .adjacencyList
var outputPath = ""

let argsCount = CommandLine.arguments.count
if argsCount == 2 {
    if CommandLine.arguments[1] == "-h" {
        ConsoleIO.printHelp()
    } else {
        fatalError("Unknown command: \(CommandLine.arguments[1])")
    }
} else if argsCount >= 4 {
    switch CommandLine.arguments[2] {
    case "-e":
        type = .edgesList
    case "-m":
        type = .adjacencyMatrix
    case "-l":
        type = .adjacencyList
    default:
        fatalError("Unknown input mode: \(CommandLine.arguments[2])")
    }
    inputPath = CommandLine.arguments[3]
    if CommandLine.arguments[argsCount - 2] == "-o" {
        outputPath = CommandLine.arguments[argsCount - 1]
        runTest(Int(CommandLine.arguments[1])!, args: CommandLine.arguments[4..<argsCount - 2])
    } else {
        runTest(Int(CommandLine.arguments[1])!, args: CommandLine.arguments[4...])
    }
} else {
    fatalError("Unknown command")
}



func runTest(_ task: Int, args: ArraySlice<String> = []) {
    let tasks: [TaskProtocol.Type] = [
        Task1.self,
        Task2.self,
        Task3.self,
        Task4.self,
        Task5.self,
        Task6.self,
        Task7.self,
        Task7.self,
        Task9.self,
        Task10.self,
        Task11.self
    ]
    
    var result = ""
    
    if task == 8 {
        let myMap = Map(path: inputPath)
        let MyTest = Task8(map: myMap, args: Array(args))
        result = MyTest.run()
    } else {
        let myGraph = Graph(path: inputPath, type: type)
        let myTest = tasks[task - 1].init(graph: myGraph, args: Array(args))
        result = myTest.run()
    }
    
    if !outputPath.isEmpty {
        let url = URL( fileURLWithPath: outputPath)
        do {
          try result.write(to: url, atomically: true, encoding: .utf8)
        }
        catch {
          print("Error writing: \(error.localizedDescription)")
        }
    } else {
        print(result)
    }
}



extension Int {
    static func +(lhs: Int, rhs: Int) -> Int{
        if lhs == Int.max || rhs == Int.max {
            return Int.max
        }
        return lhs.advanced(by: rhs)
    }
}
