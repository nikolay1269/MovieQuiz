//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Nikolay on 23.06.2024.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func changeButtonsEnabled(enabled: Bool)
}
