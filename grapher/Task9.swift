//
//  Task9.swift
//  grapher
//
//  Created by Максим Лейхнер on 05.06.2023.
//

import Foundation

class Task9 : TaskProtocol {
    required init(graph: Graph, args: [String]) {
        matrix = graph.adjacency_matrix()
        for i in (0..<matrix.count) {
            matrix[i][i] = Int.max
        }
    }
    
    var matrix: [[Int]]
    
    func run() -> String {
        return ""
    }
    
    func branchAndBound() {
        // Копируем матрицу
        var operatedMatrix = matrix
        // Редукция строк
        let lineMin = operatedMatrix.map { line -> Int in line.min() ?? 0 }
        for i in (0..<operatedMatrix.count) {
            for j in (0..<operatedMatrix.count) {
                operatedMatrix[i][j] -= lineMin[i]
            }
        }
        // Редукция столбцов
        let columnMin = operatedMatrix.minColumns()
        for i in (0..<operatedMatrix.count) {
            for j in (0..<operatedMatrix.count) {
                operatedMatrix[j][i] -= columnMin[i]
            }
        }
        // Корневая нижняя граница
        let H = lineMin.reduce(0, +) + columnMin.reduce(0, +)
        // Вычисление оценок нулевых клеток
        var P: [Edge] = []
        for i in (0..<operatedMatrix.count) {
            for j in (0..<operatedMatrix.count) {
                if operatedMatrix[i][j] == 0 {
                    var minL = Int.max
                    var minC = Int.max
                    for u in (0..<(operatedMatrix.count - 1)) {
                        minL = min(minL, operatedMatrix[i][u < j ? u : u + 1])
                        minC = min(minC, operatedMatrix[u < i ? u : u + 1][j])
                    }
                    P.append(Edge(i: i, j: j, weight: minC + minL))
                }
            }
        }
        // Находим максимальную оценку
        let maxP = P.max()!

        // Вычеркиваем строку и столбец, а стоимость обратного пути устанавливаем бесконечной


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
