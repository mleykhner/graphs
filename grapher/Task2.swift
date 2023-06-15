//
//  Task2.swift
//  grapher
//
//  Created by Максим Лейхнер on 18.04.2023.
//

import Foundation

class Task2 : TaskProtocol {
    required init(graph: Graph, args: [String]) {
        self.myGraph = graph
        self.count = self.myGraph.getGraph().count
    }
    
    private let myGraph: Graph
    private let count: Int
    
    public func run() -> String{
        
        // Переменная, хранящая результат
        var result = ""
        
        // Ориентированность графа
        let directed = myGraph.isDirected()
        
        // Получение компонент сильной свзяности
        let stronglyConnectedComponents = Kosaraju(myGraph)
        
        switch directed {
            // Если граф неориентированный...
        case false:
            // ...проверяем количество компонент сильной связности
            switch stronglyConnectedComponents.count {
                // Если есть только одна компонента – граф связан
            case 1:
                result += "Graph is connected.\n"
                // Иноче – граф состоит из нескольких компонент связности
            default:
                result += "Graph is not connected and contains \(stronglyConnectedComponents.count) connected components.\n"
            }
            
            // Выводим компоненты связности
            result += "Connected components:\n"
            result += "\(stronglyConnectedComponents.sorted())\n"
            
            // Если же граф ориентирован...
        case true:
            
            // Составляем соотнесенный граф
            let correlated = Graph(myGraph.adjacency_matrix().correlated())
            
            // Находим компоненты слабой связности
            let weaklyConnectedComponents = weaklyConnectedComponents(correlated)
            
            
            switch weaklyConnectedComponents.count {
            case 1:
                result += "Digraph is connected.\n"
            default:
                result += "Digraph is not connected and contains \(weaklyConnectedComponents.count) connected components.\n"
            }
            
            result += "Connected components:\n"
            result += "\(weaklyConnectedComponents.sorted())\n"
            
            switch stronglyConnectedComponents.count {
            case 1:
                result += "Digraph is strongly connected.\n"
            default:
                result += "Digraph is weakly connected and contains \(stronglyConnectedComponents.count) strongly connected components.\n"
            }
            
            result += "Strongly connected components:\n"
            result += "\(stronglyConnectedComponents.sorted())\n"
        }
        
        return result
    }
    
    private func weaklyConnectedComponents(_ graph: Graph) -> [[Int]] {
        var visited = Array(repeating: false, count: graph.getGraph().count)
        var components: [[Int]] = []
        
        while let vertex = visited.firstIndex(of: false) {
            var component: [Int] = []
            DFS(graph, v: vertex, visited: &visited, component: &component)
            components.append(component)
        }
        
        return components
    }
    
    private func DFS(_ graph: Graph, v: Int, visited: inout [Bool], component: inout [Int]) {
        visited[v] = true
        component.append(v)
        for (vertex, _) in graph.getGraph()[v] {
            if !visited[vertex] {
                DFS(graph, v: vertex, visited: &visited, component: &component)
            }
        }
    }
    
    // Обход в глубину с замером времени выхода выхода из рекурсии
    private func timerDFS(_ graph: Graph, v: Int, vertices: inout [Int], timer: inout Int) {
        vertices[v] = timer
        timer += 1
        for (vertex, _) in graph.getGraph()[v] {
            if vertices[vertex] == 0 {
                timerDFS(graph, v: vertex, vertices: &vertices, timer: &timer)
                vertices[v] = timer
                timer += 1
            }
        }
        
    }
    
    // Обход в глубину для алгритма Косараджу
    private func KosarajuDFS(_ graph: Graph, v: Int, component: inout [Int], vertices: inout [Int]) {
        vertices[v] = Int.min
        for (vertex, _) in graph.getGraph()[v] {
            if vertices[vertex] != Int.min {
                KosarajuDFS(graph, v: vertex, component: &component, vertices: &vertices)
            }
        }
        component.append(v + 1)
    }
    
    // Поиск компонент сильной свзяности
    private func Kosaraju(_ graph: Graph) -> [[Int]]{
        // Создаем инвертированный граф из транспонированной матрицы смежности
        let reversed = Graph(graph.adjacency_matrix().transposed())
        
        // Переменные для работы алгоритма
        var vertices = Array(repeating: 0, count: count)
        var timer = 1
        
        // Пока в массиве есть непосещенные рёбра...
        while let zero = vertices.firstIndex(of: 0) {
            // ...запускаем для них обход в глубину
            timerDFS(reversed, v: zero, vertices: &vertices, timer: &timer)
        }
        
        // Массив с компонентами связности
        var components: [[Int]] = []
        
        // Находим
        while let maxNum = vertices.max(), maxNum >= 0, let newV = vertices.firstIndex(of: maxNum) {
            var component: [Int] = []
            KosarajuDFS(graph, v: newV, component: &component, vertices: &vertices)
            component.sort()
            components.append(component)
        }
        return components
    }
}

extension [[Int]] {
    
    func transposed() -> [[Int]] {
        let size = self.count
        var res: [[Int]] = []
        for i in (0..<size) {
            var line: [Int] = []
            for j in (0..<size) {
                line.append(self[j][i])
            }
            res.append(line)
        }
        
        return res
    }
    
    func correlated() -> [[Int]] {
        let size = self.count
        var res: [[Int]] = (0..<size).map { _ -> [Int] in
            return (0..<size).map { _ -> Int in
                return 0
            }
        }
        for i in (0..<(size - 1)) {
            for j in ((i + 1)..<size) {
                if self[i][j] != 0 || self[j][i] != 0 {
                    res[i][j] = 1
                    res[j][i] = 1
                }
            }
        }
        
        return res
    }
    
    func weightedCorrelated() -> [[Int]] {
        let size = self.count
        var res: [[Int]] = (0..<size).map { _ -> [Int] in
            return (0..<size).map { _ -> Int in
                return 0
            }
        }
        for i in (0..<(size - 1)) {
            for j in ((i + 1)..<size) {
                if self[i][j] != 0 || self[j][i] != 0 {
                    let weight = [self[i][j], self[j][i]].filter({ 0 < $0 }).min() ?? 1
                    res[i][j] = weight
                    res[j][i] = weight
                }
            }
        }
        
        return res
    }
}
