//
//  Task5.swift
//  grapher
//
//  Created by Максим Лейхнер on 07.05.2023.
//

import Foundation

class Task5 : TaskProtocol {
    required init(graph: Graph, args: [String]) {
        myGraph = graph
        count = graph.getGraph().count
        
        if args.count != 4 {
            fatalError("Extra args")
        } else {
            switch args[0] {
            case "-n":
                from = Int(args[1])! - 1
                to = Int(args[3])! - 1
            case "-d":
                from = Int(args[3])! - 1
                to = Int(args[1])! - 1
            default:
                fatalError("Unknown arg: \(args[0])")
            }
        }
    }
    
    let myGraph: Graph
    let count: Int
    let from: Int
    let to: Int
    
    func run() -> String {
        
        let edges = myGraph.list_of_edges()
        var vertices: [Int] = [from]
        var shortest: [Int] = Array(repeating: Int.max, count: count)
        shortest[from] = 0
        
        var path: [Edge] = Array(repeating: Edge.infinite, count: count)
        
        while vertices.firstIndex(of: to) == nil {
            
            var minW = Int.max
            var minEdge = Edge.infinite
            
            for edge in edges.filter({ vertices.firstIndex(of: $0.i) != nil && vertices.firstIndex(of: $0.j) == nil }) {
                if shortest[edge.i] + edge.weight < minW {
                    minW = shortest[edge.i] + edge.weight
                    minEdge = edge
                }
            }
            
            if minEdge == Edge.infinite {
                return "There is no path between the vertices \(from + 1) and \(to + 1)."
            }
            
            vertices.append(minEdge.j)
            shortest[minEdge.j] = shortest[minEdge.i] + minEdge.weight
            path[minEdge.j] = minEdge
            
        }
        
        var result = [path[to]]
        while result.last!.i != from
        {
            result.append(path[result.last!.i])
        }
        
        return "Shortest path length between \(from + 1) and \(to + 1) vertices: \(shortest[to])\n\(Array(result.reversed()))\n"
    }
    
    
}


extension Edge {
    static let infinite = Edge(i: -1, j: -1, weight: Int.max)
}
