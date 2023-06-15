//
//  Task6.swift
//  grapher
//
//  Created by Максим Лейхнер on 14.05.2023.
//

import Foundation

class Task6 : TaskProtocol {
    required init(graph: Graph, args: [String]) {
        myGraph = graph
        count = graph.getGraph().count
        if args.count != 3 {
            fatalError("Wrong set of args")
        }
        switch args[0] {
        case "-n":
            mode = args[2]
            guard let start = Int(args[1]), start > 0 , start <= count else {
                fatalError("Not a vertex number: \(args[1])")
            }
            from = start - 1
        case "-d", "-b", "-t":
            mode = args[0]
            guard let start = Int(args[2]), start > 0, start <= count else {
                fatalError("Not a vertex number: \(args[2])")
            }
            from = start - 1
        default:
            fatalError("Wrong set of args")
        }
    }
    
    let myGraph: Graph
    let count: Int
    let mode: String
    let from: Int
    
    func run() -> String {
        var result = ""
        let hasNegativeEdge = myGraph.getGraph().joined().contains(where: { $0.value < 0 })
        if hasNegativeEdge {
            if checkNegativeCycles() {
                return "Graph contains a negative cycle.\n"
            }
            result = "Graph contains edges with negative weight.\nShortest paths lengths:\n"
        } else {
            result = "Graph does not contain edges with negative weight.\nShortest paths lengths:\n"
        }
        var dist: [Int] = []
        switch mode {
        case "-d":
            if hasNegativeEdge {
                result += "Dijkstra's algorithm gives an unpredictable result if there are negative weight edges in the graph.\n"
            }
            dist = Dijkstra()
        case "-b":
            dist = BellmanFord()
        case "-t":
            dist = Levit()
        default:
            fatalError()
        }
        
        for i in (0..<(count - 1)) {
            if i < from {
                result += "\(from + 1) - \(i + 1): " + ((dist[i] == Int.max) ? "∞\n" : "\(dist[i])\n")
            } else {
                result += "\(from + 1) - \(i + 2): " + ((dist[i + 1] == Int.max) ? "∞\n" : "\(dist[i + 1])\n")
            }
        }
        
        return result
    }
    
    func Dijkstra() -> [Int] {
        var used = Array(repeating: false, count: count)
        var dist = Array(repeating: Int.max, count: count)
        dist[from] = 0
        
        while let indices = used.allIndices(of: false), let v = indices.filter({ dist[$0] != Int.max }).min(by: { dist[$0] < dist[$1] }) {
            used[v] = true
            for (u, w) in myGraph.getGraph()[v] {
                dist[u] = min(dist[u], dist[v] + w)
            }
        }
        
        return dist
    }
    
    func checkNegativeCycles() -> Bool {
        let dist = BellmanFord()
        let edges = myGraph.list_of_edges()
        
        for edge in edges {
            if dist[edge.j] > dist[edge.i] + edge.weight {
                return true
            }
        }
        return false
    }
    
    func BellmanFord() -> [Int] {
        let edges = myGraph.list_of_edges()
        var dist = Array(repeating: Int.max, count: count)
        dist[from] = 0

        for _ in (0..<(count - 1)) {
            for edge in edges {
                if dist[edge.j] > dist[edge.i] + edge.weight {
                    dist[edge.j] = dist[edge.i] + edge.weight
                }
                    
            }
        }
        
        return dist
    }
    
    func Levit() -> [Int] {
        var dist = Array(repeating: Int.max, count: count)
        dist[from] = 0
        var computed: [Int] = []
        var beingComputed = [from]
        var notComputedYet = Array(0..<count)
        notComputedYet.remove(at: from)
        
        while let v = beingComputed.popLast() {
            computed.append(v)
            for (u, w) in myGraph.getGraph()[v] {
                if let indU = notComputedYet.firstIndex(of: u) {
                    notComputedYet.remove(at: indU)
                    beingComputed.append(u)
                    dist[u] = dist[v] + w
                } else if let _ = beingComputed.firstIndex(of: u) {
                    dist[u] = min(dist[u], dist[v] + w)
                } else if let indU = computed.firstIndex(of: u), dist[u] > dist[v] + w {
                    dist[u] = dist[v] + w
                    computed.remove(at: indU)
                    beingComputed.insert(u, at: 0)
                }
            }
        }
        
        return dist
    }
    
    
    
    
}

extension Collection where Element : Equatable {
    func allIndices(of target:Element) -> [Int]? {
        let indices = self.enumerated().reduce(into: [Int]()) {
            if $1.1 == target {$0.append($1.0)}
        }
        if indices.isEmpty { return nil }
        return indices
    }
}

extension Collection {
    func pick(at indices: [Self.Index]) -> [Element] {
        var result: [Element] = []
        for index in indices {
            result.append(self[index])
        }
        return result
    }
}
