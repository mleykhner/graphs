//
//  TaskProtocol.swift
//  grapher
//
//  Created by Максим Лейхнер on 09.05.2023.
//

import Foundation

protocol TaskProtocol {
    init(graph: Graph, args: [String])
    func run() -> String
}
