//
//  Graph.swift
//  grapher
//
//  Created by Максим Лейхнер on 03.04.2023.
//

import Foundation

class Graph {
    
    init(_ adjacency: [[Int]]) {
        // Кол-во вершин
        let vertexCount = adjacency.count
        
        // Граф
        var graph = Array(repeating: Dictionary<Int, Int>(), count: vertexCount)
        
        //Двигаемся по строкам
        for i in (0..<vertexCount) {
            
            // Делим строку по пробелам, одновременно превращая подстроки в инты
            let vertex = adjacency[i]
            
            // Если две вершины смежны, создаем ребро графа
            for j in (0..<vertexCount) {
                if vertex[j] != 0 {
                    graph[i][j] = vertex[j]
                }
            }
        }
        
        self.graph = graph
        self.directed = Graph.is_directed(graph)
    }
    
    init(copy: Graph) {
        self.graph = copy.getGraph()
        self.directed = copy.isDirected()
    }
    
    init(path: String, type: FileType) {
        if !FileManager.default.fileExists(atPath: path) {
            fatalError("No such file: \(path)")
        }
        do {
            let data = try String(contentsOfFile: path)
            switch type {
            case .adjacencyMatrix:
                self.graph = Graph.initFromAdjacencyMatrix(data: data)
                break
            case .adjacencyList:
                self.graph = Graph.initFromAdjacencyList(data: data)
                break
            case .edgesList:
                self.graph = Graph.initFromEdgesList(data: data)
                break
            }
            self.directed = Graph.is_directed(self.graph)
        } catch {
            fatalError("Unable to read file. Error: \(error)")
        }
    }
    
    init(edges: [Edge]) {
        let count = max(edges.max { $0.i < $1.i }!.i, edges.max { $0.j < $1.j }!.j) + 1
        var preGraph = Array(repeating: Dictionary<Int, Int>(), count: count)
        for edge in edges {
            preGraph[edge.i][edge.j] = edge.weight
        }
        graph = preGraph
        directed = Graph.is_directed(graph)
    }
    
    private static func initFromAdjacencyMatrix(data: String) -> [Dictionary<Int, Int>] {
        // Строки файла
        let lines = data.split(separator: "\n")
        
        // Кол-во вершин
        let vertexCount = lines.count
        
        // Граф
        var graph = Array(repeating: Dictionary<Int, Int>(), count: vertexCount)
        
        //Двигаемся по строкам
        for i in (0..<vertexCount) {
            
            // Делим строку по пробелам, одновременно превращая подстроки в инты
            let vertex = lines[i].split(separator: " ").map {
                subst -> Int in
                return Int(subst) ?? 0
            }
            
            // Если две вершины смежны, создаем ребро графа
            for j in (0..<vertexCount) {
                if vertex[j] != 0 {
                    graph[i][j] = vertex[j]
                }
            }
        }

        // Возвращаем результат
        return graph
    }
    
    private static func initFromAdjacencyList(data: String) -> [Dictionary<Int, Int>] {
        // Строки файла
        let lines = data.split(separator: "\n")
        
        // Кол-во вершин
        let vertexCount = lines.count
        
        // Граф
        var graph = Array(repeating: Dictionary<Int, Int>(), count: vertexCount)
        
        //Двигаемся по строкам
        for i in (0..<vertexCount) {
            
            // Делим строку по пробелам, проставляем смежность
            lines[i]
                .trimmingCharacters(
                    in: CharacterSet(charactersIn: " "))
                .split(separator: " ")
                .forEach { vertex in
                    let index = Int(vertex) ?? 0
                    graph[i][index - 1] = 1
                }
        }
        
        // Возвращаем результат
        return graph
    }
    
    private static func initFromEdgesList(data: String) -> [Dictionary<Int, Int>] {
        // Строки файла
        let edges = data.split(separator: "\n").map { substr -> Edge in
            let res = substr.split(separator: " ").map { num in
                return Int(num) ?? 0
            }
            return Edge(res)!
        }
        
        
        let a = edges.max { a, b in
            return a.j < b.j
        }!.j
        
        let b = edges.max { a, b in
            return a.i < b.i
        }!.i
        
        // Кол-во вершин
        let vertexCount = max(a, b)
        
        // Граф
        var graph = Array(repeating: Dictionary<Int, Int>(), count: vertexCount)
        
        //Заполняем граф
        for edge in edges {
            graph[edge.i - 1][edge.j - 1] = edge.weight
        }
        
        return graph
    }
    
    
    private var graph: [Dictionary<Int, Int>]
    private var directed: Bool
    
    func isDirected() -> Bool {
        return directed
    }
    
    func getGraph() -> [Dictionary<Int, Int>] {
        return graph
    }
    
    func addVertex() -> Int {
        let newVertexIndex = graph.count
        graph.append(Dictionary<Int, Int>())
        for i in (0..<newVertexIndex) {
            graph[newVertexIndex][i] = 0
        }
        return newVertexIndex
    }

    func addVertex(connectedTo: [Int], weight: Int) -> Int {
        let newVertexIndex = graph.count
        graph.append(Dictionary<Int, Int>())
        for to in connectedTo {
            graph[newVertexIndex][to] = weight
        }
        return newVertexIndex
    }
    
    func deleteVertex(_ index: Int) {
        graph.remove(at: index)
        for i in (0..<graph.count) {
            graph[i].removeValue(forKey: index)
        }
    }
    
    func updateWeight(_ edge: Edge) {
        graph[edge.i][edge.j] = edge.weight
    }
    
    // Функция выводит вес ребра ij
    func weight(i: Int, j: Int) -> Int {
        return graph[i][j] ?? 0
    }

    func deleteEdge(i: Int, j: Int) {
        graph[i].removeValue(forKey: j)
    }
    
    func weightOpt(i: Int, j: Int) -> Int? {
        return graph[i][j]
    }
    
    // Есть ли такое ребро/дуга?
    func is_edge(i: Int, j: Int) -> Bool {
        if let _ = graph[i][j] {
            return true
        }
        return false
    }

    // Возвращает матрицу смежности
    func adjacency_matrix() -> [[Int]] {
        
        let vertexCount = graph.count
        
        var result = Array(repeating: Array(repeating: 0, count: vertexCount), count: vertexCount)
        
        for i in (0..<vertexCount) {
            for j in (0..<vertexCount) {
                if let weight = graph[i][j] {
                    result[i][j] = weight
                }
            }
        }
        
        return result
    }

    // Список смежности
    func adjacency_list(i: Int) -> [Int] {
        return graph[i].keys.sorted()
    }

    // Список рёбер
    func list_of_edges() -> [Edge] {
        var result: [Edge] = []
        for i in (0..<graph.count) {
            let adjacent = graph[i].keys.sorted()
            for vertex in adjacent {
                result.append(Edge(i: i, j: vertex, weight: graph[i][vertex]!))
            }
        }
        return result
    }
    
    // Список всех рёбер графа, инцидентных вершине
    func list_of_edges(i: Int) -> [Edge] {
        graph[i].sorted{ a, b in
            return a.key < b.key
        }.map { vertex -> Edge in
            return Edge(i: i, j: vertex.key, weight: vertex.value)
        }
    }

    // Ориентированный ли граф
    private static func is_directed(_ graph: [Dictionary<Int, Int>]) -> Bool {
        for i in (0..<graph.count) {
            for (adjacency, weight) in graph[i] {
                if let a = graph[adjacency][i], a == weight {
                    continue
                } else {
                    return true
                }
            }
        }
        return false
    }

    func printGraph() {
        let adjacencyMatrix = self.adjacency_matrix()
        for line in adjacencyMatrix {
            for vertex in line {
                print(vertex, terminator: " ")
            }
            print("\n", terminator: "")
        }
    }
    
}

enum FileType {
    case adjacencyList
    case adjacencyMatrix
    case edgesList
}

struct Edge : Hashable, Comparable, CustomStringConvertible {
    let description: String
    
    
    static func < (lhs: Edge, rhs: Edge) -> Bool {
        return lhs.weight < rhs.weight
    }

    init(i: Int, j: Int, weight: Int) {
        self.i = i
        self.j = j
        self.weight = weight
        self.description = "(\(i + 1), \(j + 1), \(weight))"
    }
    
    init?(_ array: [Int]) {
        
        if array.count < 3 {
            return nil
        }
        
        i = array[0]
        j = array[1]
        weight = array[2]
        self.description = "(\(i + 1), \(j + 1), \(weight))"
    }
    
    let id = UUID().uuidString
    let i: Int
    let j: Int
    let weight: Int
}


extension [Int] : Comparable {
    
    public static func < (lhs: Array<Element>, rhs: Array<Element>) -> Bool {
        if lhs.count < rhs.count {
            return true
        } else if lhs.count == rhs.count && lhs[0] < rhs[0] {
            return true
        }
        return false
    }
    
}
