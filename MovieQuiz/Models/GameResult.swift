//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Nikolay on 28.05.2024.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isResultBetter(_ another: GameResult) -> Bool {
        return self.correct > another.correct
    }
}
