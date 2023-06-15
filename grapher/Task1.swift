//
//  Task1.swift
//  grapher
//
//  Created by Максим Лейхнер on 07.05.2023.
//

import Foundation

class Task1 : TaskProtocol {
    
    required init(graph: Graph, args: [String]) {
        self.myGraph = graph
        self.count = graph.getGraph().count
    }
    
    let myGraph: Graph
    let count: Int
    
    func run() -> String {
        var result = ""
        
        let directed = myGraph.isDirected()
        let outgoing = myGraph.getGraph().map { vertex -> Int in
            return vertex.count
        }
        
        if directed {
            var incoming: [Int] = Array(repeating: 0, count: count)
            for i in (0..<count) {
                for vertex in myGraph.getGraph() {
                    if let _ = vertex[i] {
                        incoming[i] += 1
                    }
                }
            }
            result += "deg+ = \(incoming)\n"
            result += "deg- = \(outgoing)\n"
        } else {
            result += "deg = \(outgoing)\n"
        }
        
        result += "Distancies:\n"
        
        var distances = myGraph.adjacency_matrix().map { row in
            return row.map { value in
                if value == 0 {
                    return Int.max
                }
                return value
            }
        }
        
        for i in (0..<count) {
            distances[i][i] = 0
        }
        
        for i in (0..<count) {
            for j in (0..<count) {
                for k in (0..<count) {
                    distances[j][k] = min(distances[j][k], distances[j][i] + distances[i][k])
                }
            }
        }
        
        var showEccentricity: Bool = true
        
        for i in (0..<count) {
            result += "["
            for j in (0..<count) {
                let num = distances[i][j]
                
                if num == Int.max {
                    result += " ∞"
                    showEccentricity = false
                } else {
                    result += (num < 10 ? " " : "") + "\(num)"
                }
                
                if j != count - 1 {
                    result += " "
                }
                
            }
            result += "]\n"
        }
        
        if !showEccentricity {
            return result
        }
        
        let eccentricity = distances.map { row -> Int in
            row.max()!
        }

        result += "Eccentricity: \(eccentricity)\n"
        
        if directed {
            return result
        }
        
        let D = distances.joined().max()!
        let R = eccentricity.min()!
        
        var Z: [Int] = []
        var P: [Int] = []
        
        for i in (0..<count) {
            if eccentricity[i] == R {
                Z.append(i + 1)
            }
            if eccentricity[i] == D {
                P.append(i + 1)
            }
        }
        
        result += "D = \(D)\n"
        result += "R = \(R)\n"
        result += "Z = \(Z)\n"
        result += "P = \(P)\n"
        
        return result
    }
    
}
