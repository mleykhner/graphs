//
//  Task7.swift
//  grapher
//
//  Created by Максим Лейхнер on 03.06.2023.
//

import Foundation

class Task7 : TaskProtocol {
    required init(graph: Graph, args: [String]) {
        originalGraph = Graph(copy: graph)
        modifiedGraph = graph
        newVertex = modifiedGraph.addVertex()
        count = modifiedGraph.getGraph().count
    }
    
    var originalGraph: Graph
    var modifiedGraph: Graph
    var count: Int
    let newVertex: Int

    
    func run() -> String {
        
        guard let dist = BellmanFord() else {
            return "Graph contains a negative cycle.\n"
        }
        
        modifiedGraph.deleteVertex(newVertex)
        count -= 1
        
        var result = ""
        
        if modifiedGraph.getGraph().joined().contains(where: { $0.value < 0 }){
            result = "Graph contains edges with negative weight.\nShortest paths lengths:\n"
        } else {
            result = "Graph does not contain edges with negative weight.\nShortest paths lengths:\n"
        }
        
        let edges = modifiedGraph.list_of_edges()
        
        for edge in edges {
            modifiedGraph.updateWeight(edge.reweighting(edge.weight + dist[edge.i] - dist[edge.j]))
        }
        
        for v in (0..<count) {
            let path = DijkstraPath(v)
            for i in (0..<count) {
                if i == v { continue }
                var sum = 0
                var prev = i
                var pathExists = false
                while path[prev] != -1 {
                    pathExists = true
                    sum += originalGraph.weight(i: path[prev], j: prev)
                    prev = path[prev]
                }
                if !pathExists { continue }
                result += "\(v + 1) - \(i + 1): \(sum)\n"
            }
        }
        return result
    }
    
    func BellmanFord() -> [Int]? {
        let edges = modifiedGraph.list_of_edges()
        var dist = Array(repeating: Int.max, count: count)
        dist[newVertex] = 0

        for _ in (0..<(count - 1)) {
            for edge in edges {
                dist[edge.j] = min(dist[edge.j], dist[edge.i] + edge.weight)
            }
        }
        
        
        for edge in edges {
            if dist[edge.j] > dist[edge.i] + edge.weight {
                return nil
            }
        }
        
        return dist
    }
    
    func DijkstraPath(_ from: Int) -> [Int] {
        var used = Array(repeating: false, count: count)
        var prev = Array(repeating: -1, count: count)
        var dist = Array(repeating: Int.max, count: count)
        dist[from] = 0
        
        while let indices = used.allIndices(of: false), let v = indices.filter({ dist[$0] != Int.max }).min(by: { dist[$0] < dist[$1] }) {
            used[v] = true
            for (u, w) in modifiedGraph.getGraph()[v] {
                if dist[u] > dist[v] + w {
                    dist[u] = dist[v] + w
                    prev[u] = v
                }
            }
        }
        return prev
    }
    
}

extension Edge {
    func reweighting(_ weight: Int) -> Edge {
        return Edge(i: self.i, j: self.j, weight: weight)
    }
}

