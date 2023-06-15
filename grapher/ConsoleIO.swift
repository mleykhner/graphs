//
//  ConsoleIO.swift
//  grapher
//
//  Created by Максим Лейхнер on 12.04.2023.
//

import Foundation
import Rainbow

class ConsoleIO {
    static func printHelp () {
        print("       _         _   _               ")
        print(" _____| |___ _ _| |_| |_ ___ ___ ___ ")
        print("|     | | -_| | | '_|   |   | -_|  _|")
        print("|_|_|_|_|___|_  |_,_|_|_|_|_|___|_|  ")
        print(" github.com/".cyan.bold + "|___|                    ")
        print("                                     ")
        print("Автор: ".cyan.bold + "Лейхнер Максим".cyan)
        print("Группа: ".cyan.bold + "М3О–225Бк–21".cyan)
        print("")
        print("Справка:")
//        print("")
//        print(".\grapher [задание] [способ ввода, путь]")
//        print("")
        print("-e\t".bold.cyan + "\"edges_list_file_path\"\t" + "Ввод графа с помощью списка рёбер".italic)
        print("-m\t".bold.cyan + "\"adjacency_matrix_file_path\"\t" + "Ввод графа с помощью матрицы смежности".italic)
        print("-l\t".bold.cyan + "\"adjacency_list_file_path\"\t" + "Ввод графа с помощью списка смежности".italic)
        print("Опционально:".dim)
        print("-o\t".bold.cyan + "\"output_file_path\"\t" + "Ввод графа с помощью списка смежности".italic)
    }
    
    
}


