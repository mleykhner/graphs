//
//  Task11.swift
//  grapher
//
//  Created by Максим Лейхнер on 09.06.2023.
//

import Foundation

class Task11 : TaskProtocol {
    required init(graph: Graph, args: [String]) {
        myGraph = graph
    }

    var myGraph: Graph
    
    func run() -> String {
        var parts: [Int?] = Array(repeating: nil, count: myGraph.getGraph().count)
        let bipartite = isBipartite(graph: myGraph, parts: &parts)

        if !bipartite {
            return "is not Bipartite\n"
        }

        let partsUnwrapped = parts.compactMap { $0 }
        if parts.count != partsUnwrapped.count {
            fatalError("Error while unwrapping parts")
        }

        let firstPart = partsUnwrapped.allIndices(of: 0) ?? []
        let secondPart = partsUnwrapped.allIndices(of: 1) ?? []

        let s = myGraph.addVertex(connectedTo: firstPart, weight: 1)
        let t = myGraph.addVertex(connectedTo: [], weight: 0)

        for i in firstPart {
            for (u, _) in myGraph.getGraph()[i] {
                myGraph.deleteEdge(i: u, j: i)
            }
        }
        for i in secondPart{
            myGraph.updateWeight(Edge(i: i, j: t, weight: 1))
        }

        var myFlowGraph = FlowGraph(from: myGraph)
        let _ = FordFulkerson(graph: &myFlowGraph, from: s, to: t)
        let matches = myFlowGraph.listOfEdges().filter { $0.flow == 1 }
        .filter { $0.i != s && $0.j != s && $0.i != t && $0.j != t }

        return "is Bipartite\n" + matches.map { "\($0.j + 1) - \($0.i + 1)\n" }.joined()
    }

    func dfs(graph: FlowGraph, src: Int, dst: Int, path: inout [FlowEdge], visited: inout [Bool]) -> Bool {
        if src == dst {
            return true
        }

        if visited[src] {
            return false
        }

        for edge in graph.getGraph()[src] {
            if edge.value.1 - edge.value.0 <= 0 {
                continue
            }
            visited[src] = true
            if dfs(graph: graph, src: edge.key, dst: dst, path: &path, visited: &visited) {
                path.append(FlowEdge(source: src, edge: edge))
                return true
            }
        }
        return false
    }

    func FordFulkerson(graph: inout FlowGraph, from src: Int, to dst: Int) -> Int {
        var maxFlow = 0
        while true {
            var path: [FlowEdge] = []
            var visited: [Bool] = Array(repeating: false, count: myGraph.getGraph().count)

            if dfs(graph: graph, src: src, dst: dst, path: &path, visited: &visited) == false {
                break
            }

            let minFlow = path.min { $0.residualFlow() < $1.residualFlow() }!.residualFlow()
            maxFlow += minFlow

            for i in (0..<path.count) {
                path[i].flow += minFlow
                graph.updateEdge(path[i])
                if var antiEdge = graph.getEdge(from: path[i].j, to: path[i].i) {
                    antiEdge.flow -= minFlow
                    graph.updateEdge(antiEdge)
                }
            }
        }
        return maxFlow
    }

    func isBipartite(graph: Graph, parts: inout [Int?]) -> Bool {
        if parts.count != graph.getGraph().count {
            return false
        }
        var q = Array(repeating: 0, count: parts.count)
        for i in (0..<parts.count) {
            if parts[i] == nil {
                var h = 0
                var t = 0
                q[t] = i
                t += 1
                parts[i] = 0
                while h < t {
                    let v = q[h]
                    h += 1
                    for (u, _) in graph.getGraph()[v] {
                        if parts[u] == nil {
                            parts[u] = 1 - parts[v]!
                            q[t] = u
                            t += 1
                        } else if parts[u] == parts[v] {
                            return false
                        }
                    }
                }
            }
        }
        return true
    }
    
}