//
//  Task3.swift
//  grapher
//
//  Created by Максим Лейхнер on 21.04.2023.
//

import Foundation

class Task3 : TaskProtocol {
    
    required init(graph: Graph, args: [String]) {
        self.myGraph = graph
        self.count = self.myGraph.getGraph().count
    }
    
    private let myGraph: Graph
    private let count: Int
    
    func run() -> String {
        var result = ""
        
        var visited: [Bool] = Array(repeating: false, count: count)
        var tin = Array(repeating: 0, count: count)
        var fup = Array(repeating: 0, count: count)
        var cutpoints: Set<Int> = []
        var bridges: [(Int, Int)] = []
        
        while let i = visited.firstIndex(of: false) {
            DFS(v: i, visited: &visited, tin: &tin, fup: &fup, cutpoints: &cutpoints, bridges: &bridges)
        }
        
        result += "Bridges:\n"
        result += "\(bridges)\n"
        result += "Cut vertices:\n"
        result += "\(cutpoints)\n"
        
        return result
    }
    
    private func DFS(v: Int, p: Int = -1, depth: Int = 0, visited: inout [Bool], tin: inout [Int], fup: inout [Int], cutpoints: inout Set<Int>, bridges: inout [(Int, Int)]) {
        
        visited[v] = true
        tin[v] = depth
        fup[v] = depth
        
        for (to, _) in myGraph.getGraph()[v] {
            if to == p { continue }
            if visited[to] { fup[v] = min(fup[v], tin[to]) }
            else {
                DFS(v: to, p: v, depth: depth + 1, visited: &visited, tin: &tin, fup: &fup, cutpoints: &cutpoints, bridges: &bridges)
                fup[v] = min(fup[v], fup[to])
                
                if fup[to] >= tin[v] && p != -1 {
                    cutpoints.insert(v + 1)
                }
                
                if fup[to] > tin[v] {
                    bridges.append((v + 1, to + 1))
                }
            }
        }
    }
}
