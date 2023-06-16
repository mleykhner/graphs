//
// Created by Максим Лейхнер on 15.06.2023.
//

import Foundation

class Task8 {
    init(map: Map, args: [String]) {
        myMap = map
        if args.count != 6 {
            fatalError("Wrong set of args")
        }
        if args[0] == "-n" {
            if let x = Int(args[1]), let y = Int(args[2]) {
                startCell = Cell(x: x, y: y, height: 0)
            } else {
                fatalError("Unable to get starting cell")
            }
            if let x = Int(args[4]), let y = Int(args[5]){
                endCell = Cell(x: x, y: y, height: 0)
            } else {
                fatalError("Unable to get ending cell")
            }
        } else if args[0] == "-d" {
            if let x = Int(args[4]), let y = Int(args[5]) {
                startCell = Cell(x: x, y: y, height: 0)
            } else {
                fatalError("Unable to get starting cell")
            }
            if let x = Int(args[1]), let y = Int(args[2]){
                endCell = Cell(x: x, y: y, height: 0)
            } else {
                fatalError("Unable to get ending cell")
            }
        } else {
            fatalError("Wrong set of args")
        }

    }

    var myMap: Map
    let startCell: Cell
    let endCell: Cell

    func run() -> String {
        startCell.path = 0
        //let _ = AStar(start: startCell, heuristics: Cell.ManhattanDistance)
        let _ = AStar(heuristics: Cell.ManhattanDistance)
        var path: [Cell] = []
        //var sum = 0
        var currentCell: Cell? = myMap.map[endCell.y][endCell.x]
        while currentCell != nil {
            path.insert(currentCell!, at: 0)
            currentCell = currentCell!.cameFrom
        }
        print ("\(path[path.count - 1].path)\n\(path)")
        return "Hello"
    }
    
    func AStar(heuristics: ((Cell, Cell) -> Int)) -> Bool {
        var computing: [Cell] = [startCell]

        while !computing.isEmpty {
            let c = computing.min(by: { $0.path + heuristics($0, endCell) < $1.path + heuristics($1, endCell)})!
            computing.remove(at: computing.firstIndex(where: { $0 == c })!)
            if c == endCell {
                return true
            }
            c.computed = true
            let neighbors = myMap.neighbors(c)
            
            for i in (0..<neighbors.count) {
                if neighbors[i].computed { continue }
                let dist = c.path + abs(c.height - neighbors[i].height) + 1
                var isBest = false
                if !computing.contains(where: { cc in cc == neighbors[i] }) {
                    isBest = true
                    computing.append(neighbors[i])
                } else if dist < neighbors[i].path {
                    isBest = true
                }
                
                if isBest {
                    neighbors[i].cameFrom = c
                    neighbors[i].path = dist
                }
            }
            
//            neighbors.forEach {
//                let dist = c.path + abs(c.height - $0.height) + 1
//                if !$0.computed && $0.path > dist {
//                    $0.cameFrom = c
//                    $0.path = dist
//                    computing.append($0)
//                }
//            }
        }
        return false
    }

    func AStar(start: Cell, heuristics: ((Cell, Cell) -> Int)) -> Bool {
        if start.computed { return false }
        start.computed = true
        if start == endCell { return true }
        
        let neighbors = myMap.neighbors(start)
        neighbors.filter { !$0.computed }.forEach {
            let dist = start.path + abs(start.height - $0.height) + 1
            if dist < $0.path {
                $0.cameFrom = start
                $0.path = dist
            }
        }
        let distances = neighbors.map { heuristics($0, endCell) + $0.path }
        
        while neighbors.contains(where: { !$0.computed }) {
            var minPath = Int.max
            var minCell = neighbors[0]
            for i in (0..<neighbors.count) {
                if !neighbors[i].computed && distances[i] < minPath {
                    minPath = distances[i]
                    minCell = neighbors[i]
                }
            }
            if AStar(start: minCell, heuristics: heuristics) {
                return true
            }
        }
        return false
    }
}

class Cell : CustomStringConvertible {
    var description: String {
        get {
            return "(\(x), \(y))"
        }
    }
    
    var x: Int
    var y: Int
    var height: Int
    var cameFrom: Cell?
    var computed = false
    var path = Int.max
    
    init(x: Int, y: Int, height: Int, from: Cell? = nil) {
        self.x = x
        self.y = y
        self.height = height
        cameFrom = from
    }
    
    static func == (_ lhs: Cell, _ rhs: Cell) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
}

struct Map {
    private(set) var map: [[Cell]] = []

    init(path: String) {
        if !FileManager.default.fileExists(atPath: path) {
            fatalError("No such file: \(path)")
        }
        do {
            let data = try String(contentsOfFile: path)
            let lines = data.split(separator: "\n")
            for i in (0..<lines.count) {
                map.append([])
                let cells = lines[i].split(separator: " ")
                for j in (0..<cells.count) {
                    map[i].append(Cell(x: j, y: i, height: Int(cells[j]) ?? -1))
                }
            }
        } catch {
            fatalError("Unable to read file. Error: \(error)")
        }
    }

    func neighbors(_ cell: Cell) -> [Cell] {
        let delta = [(-1,0), (0,-1), (1,0), (0,1)]
        return delta.filter {
                    cell.x + $0.0 >= 0
                    && cell.x + $0.0 < map[cell.y].count
                    && cell.y + $0.1 >= 0
                    && cell.y + $0.1 < map.count
            }.map { map[cell.y + $0.1][cell.x + $0.0] }
    }
    

    func height(x: Int, y: Int) -> Int {
        map[y][x].height
    }
}

extension Cell {
    static func ManhattanDistance(_ lhs: Cell, _ rhs: Cell) -> Int {
        abs(rhs.x - lhs.x) + abs(rhs.y - lhs.y)
    }

    static func ChebyshevDistance(_ lhs: Cell, _ rhs: Cell) -> Int {
        max(abs(rhs.x - lhs.x), abs(rhs.y - lhs.y))
    }

    static func EuclidDistance(_ lhs: Cell, _ rhs: Cell) -> Int {
        Int(sqrt(Double((rhs.x - lhs.x) * (rhs.x - lhs.x) + (rhs.y - lhs.y) * (rhs.y - lhs.y))))
    }

}
