//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Nikolay on 25.05.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromSever()
    func didFailToLoadData(with error: Error)
}


