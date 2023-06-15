//
//  Task10.swift
//  grapher
//
//  Created by Максим Лейхнер on 07.06.2023.
//

import Foundation

class Task10 : TaskProtocol {
    required init(graph: Graph, args: [String]) {
        myGraph = FlowGraph(from: graph)
        let deg = Task10.degree(graph: graph)
        guard let src = deg.1.firstIndex(of: 0), let dst = deg.0.firstIndex(of: 0) else {
            fatalError("Unable to find start or destination")
        }
        from = src
        to = dst
    }
    
    var myGraph: FlowGraph
    let from: Int
    let to: Int
    
    func run() -> String {
        let flow = FordFulkerson(from: from, to: to)
        var result = "\(flow) - maximum flow from \(from + 1) to \(to + 1).\n"
        for edge in myGraph.listOfEdges().sorted() {
            result += "\(edge.i + 1) \(edge.j + 1) \(edge.flow)/\(edge.capacity)\n"
        }
        return result
    }
    
    func dfs(src: Int, dst: Int, path: inout [FlowEdge], visited: inout [Bool]) -> Bool {
        if src == dst {
            return true
        }
        
        if visited[src] {
            return false
        }
        
        for edge in myGraph.getGraph()[src] {
            if edge.value.1 - edge.value.0 <= 0 {
                continue
            }
            visited[src] = true
            if dfs(src: edge.key, dst: dst, path: &path, visited: &visited) {
                path.append(FlowEdge(source: src, edge: edge))
                return true
            }
        }
        return false
    }
    
    func FordFulkerson(from src: Int, to dst: Int) -> Int {
        var maxFlow = 0
        while true {
            var path: [FlowEdge] = []
            var visited: [Bool] = Array(repeating: false, count: myGraph.getGraph().count)
            
            if dfs(src: src, dst: dst, path: &path, visited: &visited) == false {
                break
            }
            
            let minFlow = path.min { $0.residualFlow() < $1.residualFlow() }!.residualFlow()
            maxFlow += minFlow
            
            for i in (0..<path.count) {
                path[i].flow += minFlow
                myGraph.updateEdge(path[i])
                if var antiEdge = myGraph.getEdge(from: path[i].j, to: path[i].i) {
                    antiEdge.flow -= minFlow
                    myGraph.updateEdge(antiEdge)
                }
            }
        }
        return maxFlow
    }
    
    static func degree(graph: Graph) -> ([Int], [Int]) {
        var result: ([Int], [Int]) = ([],[])
        let directed = graph.isDirected()
        result.0 = graph.getGraph().map { vertex -> Int in
            return vertex.count
        }
        
        if directed {
            result.1 = Array(repeating: 0, count: graph.getGraph().count)
            for i in (0..<graph.getGraph().count) {
                for vertex in graph.getGraph() {
                    if let _ = vertex[i] {
                        result.1[i] += 1
                    }
                }
            }
        } else {
            result.1 = result.0
        }
        return result
        
    }
}

struct FlowEdge : Hashable, Comparable {

    static func < (lhs: FlowEdge, rhs: FlowEdge) -> Bool {
        if lhs.i < rhs.i {
            return true
        }
        if lhs.i == rhs.i, lhs.j < rhs.j {
            return true
        }
        return false
    }


    init(source: Int, edge: (key: Int, value: (Int, Int))) {
        i = source
        j = edge.key
        flow = edge.value.0
        capacity = edge.value.1
    }

    init?(from src: Int, to dst: Int, specs: (Int, Int)?) {
        if let specs {
            i = src
            j = dst
            flow = specs.0
            capacity = specs.1
        } else {
            return nil
        }
    }

    var i: Int
    var j: Int
    var flow: Int
    var capacity: Int

    func residualFlow() -> Int {
        return capacity - flow
    }
}

struct FlowGraph {
    init(from graph: Graph) {
        for vertex in graph.getGraph() {
            var adjacency = Dictionary<Int, (Int, Int)>()
            for (u, f) in vertex {
                adjacency[u] = (0, f)
            }
            myFlowGraph.append(adjacency)
        }
    }

    func listOfEdges() -> [FlowEdge] {
        var result: [FlowEdge] = []
        for i in (0..<myFlowGraph.count) {
            result += myFlowGraph[i].map { edge -> FlowEdge in FlowEdge(from: i, to: edge.key, specs: edge.value)! }
        }
        return result
    }

    private var myFlowGraph:[Dictionary<Int, (Int, Int)>] = []

    func getGraph() -> [Dictionary<Int, (Int, Int)>] {
        return myFlowGraph
    }

    func getEdge(from src: Int, to dst: Int) -> FlowEdge? {
        return FlowEdge(from: src, to: dst, specs: myFlowGraph[src][dst])
    }

    mutating func updateEdge(_ edge: FlowEdge) {
        myFlowGraph[edge.i][edge.j] = (edge.flow, edge.capacity)
    }
}
