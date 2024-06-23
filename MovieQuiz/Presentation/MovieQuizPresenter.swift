//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Nikolay on 21.06.2024.
//

import UIKit

final class MovieQuizPresenter {
    
    // MARK: - Private Properties
    private let statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var currentQuestion: QuizQuestion? = nil
    private let questionsAmount: Int = 10
    private var correctAnswers = 0
    private var currentQuestionIndex: Int = 0
    
    // MARK: - Initializer
    init(viewController: MovieQuizViewControllerProtocol) {
        
        self.viewController = viewController
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - Public Methods
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        self.viewController?.showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex+=1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func proceedNextQuestionOrResults() {
        if isLastQuestion() {
            
            let text = correctAnswers == self.questionsAmount ? "Поздравляем, вы ответили на 10 из 10!" : "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"

            let quizResultModel = QuizResultViewModel(title: "Этот раунд окончен",
                                                      text: text,
                                                      buttonText: "Сыграть ещё раз?")

            self.viewController?.show(quiz: quizResultModel)

        } else {
            
            self.viewController?.showLoadingIndicator()
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
        self.viewController?.changeButtonsEnabled(enabled: true)
    }
    
    func makeResultMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gameCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)" + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность \(String(format: "%.2f", statisticService.totalAccuracy))"

        let resultMessage = [currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
        return resultMessage
    }
    
    
    // MARK: - Private Methods
    private func didAnswer(isYes: Bool) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }

        let givenAnswer = isYes

        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        
        didAnswer(isCorrectAnswer: isCorrect)
        
        self.viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        self.viewController?.changeButtonsEnabled(enabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            
            guard let self  = self else { return }
            self.proceedNextQuestionOrResults()
        }
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        
        self.viewController?.hideLoadingIndicator()
        
        guard let question = question else {
            return
        }
         
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromSever() {
        
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        self.viewController?.showNetworkError(message: error.localizedDescription)
    }
}
