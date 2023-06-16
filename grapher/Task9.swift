//
//  Task9.swift
//  grapher
//
//  Created by Максим Лейхнер on 05.06.2023.
//

import Foundation

class Task9 : TaskProtocol {
    required init(graph: Graph, args: [String]) {
        self.graph = graph
        matrix = graph.adjacency_matrix()
        for i in (0..<matrix.count) {
            matrix[i][i] = Int.max
        }
    }
    
    var matrix: [[Int]]
    var graph: Graph
    
    func run() -> String {
        return Ants()
    }
    
    func Ants() -> String {
        let alfa = 1.0
        let beta = 2.5
        let Q = 10.0
        let p = 0.9
        
        var feromones = matrix.map { $0.map { $0 != 0 ? 0.2 : 0 }}
        var ants: [Ant] = []
        
        for i in (0..<matrix.count) {
            for _ in (0..<5) {
                ants.append(Ant(cities: matrix.count, starting: i))
            }
        }
        
        //let ants = (0..<matrix.count).map{Ant(cities: matrix.count, starting: $0)}
        
        var shortestPath: [Edge] = []
        var shortestLength: Int = Int.max
        
        for _ in (0..<250) {
            for ant in ants {
                while !ant.citiesToVisit.isEmpty {
                    let edges = graph.getGraph()[ant.currentCity].filter{ ant.citiesToVisit.contains($0.key) }
                    let attractivness = edges.map{ pow(feromones[ant.currentCity][$0.key], alfa) * pow(1.0 / Double($0.value), beta) }
                    let summ = attractivness.reduce(0.0, +)
                    
                    let dice = Double.random(in: 0.0...1.0)
                    
                    var i = -1
                    var currentSumm = 0.0
                    repeat {
                        i += 1
                        currentSumm += attractivness[i] / summ
                    } while attractivness[i] / summ + currentSumm < dice
                    let nextCity = edges.map { $0.key }[i]
                    
                    ant.edgesVisited.append(Edge(i: ant.currentCity, j: nextCity, weight: graph.weight(i: ant.currentCity, j: nextCity)))
                    ant.citiesToVisit.remove(at: ant.citiesToVisit.firstIndex(of: nextCity)!)
                    ant.currentCity = nextCity
                }
                ant.edgesVisited.append(Edge(i: ant.currentCity, j: ant.edgesVisited.first!.i, weight: graph.weight(i: ant.currentCity, j: ant.edgesVisited.first!.i)))
                ant.currentCity = ant.edgesVisited.first!.i
                
                let length = ant.edgesVisited.reduce(0) { partialResult, edge in partialResult + edge.weight }
                
                if length < shortestLength {
                    shortestLength = length
                    shortestPath = ant.edgesVisited
                }
                
            }
            
            for ant in ants {
                let dT = Q / ant.edgesVisited.reduce(0.0) { partialResult, edge in partialResult + Double(edge.weight) }
                for edge in ant.edgesVisited {
                    feromones[edge.i][edge.j] = feromones[edge.i][edge.j] * (1 - p) + dT
                }
            }
        }
        
        let pathLength = shortestPath.reduce(0) { partialResult, edge in
            partialResult + edge.weight
        }
        return "Hamiltonian cycle has length \(pathLength).\n\(shortestPath.map{"\($0.i+1) - \($0.j+1) : (\($0.weight))"}.joined(separator: "\n"))"
        
    }
    
//    func branchAndBound() {
//        // Копируем матрицу
//        var operatedMatrix = matrix
//        // Редукция строк
//        let lineMin = operatedMatrix.map { line -> Int in line.min() ?? 0 }
//        for i in (0..<operatedMatrix.count) {
//            for j in (0..<operatedMatrix.count) {
//                operatedMatrix[i][j] -= lineMin[i]
//            }
//        }
//        // Редукция столбцов
//        let columnMin = operatedMatrix.minColumns()
//        for i in (0..<operatedMatrix.count) {
//            for j in (0..<operatedMatrix.count) {
//                operatedMatrix[j][i] -= columnMin[i]
//            }
//        }
//        // Корневая нижняя граница
//        let H = lineMin.reduce(0, +) + columnMin.reduce(0, +)
//        // Вычисление оценок нулевых клеток
//        var P: [Edge] = []
//        for i in (0..<operatedMatrix.count) {
//            for j in (0..<operatedMatrix.count) {
//                if operatedMatrix[i][j] == 0 {
//                    var minL = Int.max
//                    var minC = Int.max
//                    for u in (0..<(operatedMatrix.count - 1)) {
//                        minL = min(minL, operatedMatrix[i][u < j ? u : u + 1])
//                        minC = min(minC, operatedMatrix[u < i ? u : u + 1][j])
//                    }
//                    P.append(Edge(i: i, j: j, weight: minC + minL))
//                }
//            }
//        }
//        // Находим максимальную оценку
//        let maxP = P.max()!
//
//        // Вычеркиваем строку и столбец, а стоимость обратного пути устанавливаем бесконечной
//
//
//    }
//

    
    class Ant {
        var edgesVisited: [Edge] = []
        var citiesToVisit: [Int]
        var currentCity: Int
        init(cities: Int, starting: Int) {
            citiesToVisit = Array(0..<cities)
            citiesToVisit.remove(at: starting)
            currentCity = starting
        }
    }
}

extension Int {
    static func -(lhs: Int, rhs: Int) -> Int{
        if lhs == Int.max || rhs == Int.max {
            return Int.max
        }
        
        return lhs.advanced(by: -rhs)
    }
}

extension [[Int]] {
    func minColumns() -> [Int] {
        var result: [Int] = []
        for i in (0..<self.count) {
            var minNum = Int.max
            for j in (0..<self.count) {
                minNum = Swift.min(minNum, self[j][i])
            }
            result.append(minNum)
        }
        return result
    }

    mutating func reduct() {
        let lineMin = self.map { line -> Int in line.min() ?? 0 }
        for i in (0..<self.count) {
            for j in (0..<self.count) {
                self[i][j] -= lineMin[i]
            }
        }
        let columnMin = self.minColumns()
        for i in (0..<self.count) {
            for j in (0..<self.count) {
                self[j][i] -= columnMin[i]
            }
        }
    }
}
