//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Nikolay on 28.05.2024.
//

import Foundation

private enum Keys: String {
    case correct
    case bestGame
    case gamesCount
    case total
    case date
    case correctAnswers
}

protocol StatisticServiceProtocol {
    
    var gameCount: Int { get }
    var bestGame: GameResult  { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}

final class StatisticService: StatisticServiceProtocol {
    
    // MARK: - Public Properties
    var gameCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            let total = storage.integer(forKey: Keys.total.rawValue)
            let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            if gameCount == 0 {
                return 0
            }
            else {
                correctAnswers = storage.integer(forKey: Keys.correctAnswers.rawValue)
                return (Double(correctAnswers) / Double(gameCount * 10)) * 100
            }
        }
    }
    
    // MARK: - Private Properties
    private var correctAnswers: Int = 0
    private let storage: UserDefaults = .standard
    
    // MARK: - Public Methods
    func store(correct count: Int, total amount: Int) {
        
        correctAnswers = storage.integer(forKey: Keys.correctAnswers.rawValue)
        correctAnswers += count
        storage.set(correctAnswers, forKey: Keys.correctAnswers.rawValue)
        gameCount += 1
        let newGameResult = GameResult(correct: count, total: amount, date: Date())
        if newGameResult.isResultBetter(bestGame) {
            bestGame = newGameResult
        }
    }
}
