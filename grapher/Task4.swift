//
//  Task4.swift
//  grapher
//
//  Created by Максим Лейхнер on 29.04.2023.
//

import Foundation

class Task4 : TaskProtocol {
    
    required init(graph: Graph, args: [String]) {
        if graph.isDirected() {
            self.myGraph = Graph(graph.adjacency_matrix().weightedCorrelated())
        } else {
            self.myGraph = graph
        }
        self.count = graph.getGraph().count
        guard let mode = args.first else {
            fatalError("Mode undefined")
        }
        self.mode = mode
    }
    
    let myGraph: Graph
    let count: Int
    let mode: String
    
    func run() -> String {
        var tree: [Edge] = []
        var result = ""
        switch mode {
        case "-k", "-p", "-b":
            switch mode {
                case "-k":
                    tree = Kruskal()
                case "-p":
                    tree = Prim()
                case "-b":
                    tree = Boruvka()
                default:
                    break
            }
            result += "Minimum spanning tree:\n"
            result += "\(tree)\n"
            result += "Weight of spanning tree: \(tree.totalWeight())"
        case "-s":
            let clock = ContinuousClock()
            let kTime = clock.measure { let _ = Kruskal() }
            let pTime = clock.measure { let _ = Prim() }
            let bTime = clock.measure { let _ = Boruvka() }
            result += "Kruscal: \(kTime), Prim: \(pTime), Boruvka: \(bTime)\n"
        default:
            fatalError("No such mode: \(mode)\n")
        }
        return result
    }
    
    func Kruskal() -> [Edge] {
        var sets: [Set<Int>] = []
        var edges = myGraph.list_of_edges().sorted()
        
        for edge in edges {
            var from = -1
            var to = -1
            for i in (0..<sets.count) {
                if sets[i].contains(edge.i) {
                    from = i
                }
                if sets[i].contains(edge.j) {
                    to = i
                }
                if from != -1, to != -1 {
                    break
                }
            }
            if from == to {
                if from == -1 {
                    sets.append(Set([edge.i, edge.j]))
                }
                else {
                    edges.remove(at: edges.firstIndex(of: edge)!)
                }
            } else {
                if from == -1 {
                    sets[to].insert(edge.i)
                } else if to == -1 {
                    sets[from].insert(edge.j)
                } else {
                    sets[from] = sets[from].union(sets[to])
                    sets.remove(at: to)
                }
            }
        }
        return edges
    }
    
    func Prim() -> [Edge] {
        var used: Set<Int> = [0]
        var result: [Edge] = []
        
        while result.count < count - 1 {
            var minW = Int.max
            var minU = -1
            var minP = -1
            for v in used {
                for (u, w) in myGraph.getGraph()[v] {
                    if used.firstIndex(of: u) == nil, w < minW {
                        minW = w
                        minU = u
                        minP = v
                    }
                }
            }
            used.insert(minU)
            result.append(Edge(i: minP, j: minU, weight: minW))
        }
        
        return result
    }
    
    func Boruvka() -> [Edge] {
        var sets = (0..<count).map { num -> Set<Int> in
            return Set([num])
        }
        var result: [Edge] = []
        
        while sets.count > 1 {
            var i = 0
            while i < sets.count {
                var minE = Edge.infinite
                for v in sets[i] {
                    for edge in myGraph.getGraph()[v] {
                        if !sets[i].contains(edge.key), edge.value < minE.weight {
                            minE = Edge(i: v, j: edge.key, weight: edge.value)
                        }
                    }
                }
                result.append(minE)
                let second = sets.firstIndex { $0.contains(minE.j) }!
                sets.merge(i, second)
                i += 1
            }
        }
        return result
    }
}

extension [Edge] {
    func totalWeight() -> Int {
//        let res = self.reduce(0) { partialResult, edge in
//            partialResult + edge.weight
//        }
        var result = 0
        for edge in self {
            result += edge.weight
        }
        return result
    }
}

extension [Set<Int>] {
    mutating func merge(_ i: Int, _ j: Int) {
        self[i] = self[i].union(self[j])
        self.remove(at: j)
    }
}

