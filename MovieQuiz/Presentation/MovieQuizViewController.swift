import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionAmout: Int = 10
    private var currentQuestion: QuizQuestion? = nil
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
        
        statisticService = StatisticService()
    }
    
    //MARK: Question Factory Delegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        
        guard let question = question else {
            return
        }
         
        self.currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
        initImageView()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        
        guard let question = currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: question.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        
        guard let question = currentQuestion else {
            return
        }
        
        showAnswerResult(isCorrect: !question.correctAnswer)
    }
    
    private func initImageView() {
        imageView.layer.borderWidth = 0
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(),
                          question: model.text,
                          questionNumber: "\(currentQuestionIndex + 1)/\(questionAmout)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultViewModel) {
        
        let alertViewModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
            
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        AlertPresenter.showAlert(model: alertViewModel, viewController: self)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        if isCorrect {
            correctAnswers += 1
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        changeButtonsEnabled(enabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            self.showNextQuestionOrResults()
        }
    }
    
    private func changeButtonsEnabled(enabled: Bool) {
        yesButton.isEnabled = enabled
        noButton.isEnabled = enabled
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionAmout - 1 {
            
            initImageView()
            
            self.statisticService?.store(correct: correctAnswers, total: questionAmout)
            
            let gameCount = statisticService?.gameCount ?? 0
            let bestGameResult = statisticService?.bestGame.correct ?? 0
            let date = statisticService?.bestGame.date.dateTimeString ?? Date().dateTimeString
            let accuracy = "\(String(format: "%.2f", statisticService?.totalAccuracy ?? 0))%"
            let text = "Ваш результат \(correctAnswers)/10\nКоличество сыгранных квизов:\(gameCount)\nРекорд: \(bestGameResult)/10(\(date))\nСредняя точность:\(accuracy)"
            let quizResultModel = QuizResultViewModel(title: "Этот раунд окончен",
                                                      text: text,
                                                      buttonText: "Сыграть ещё раз?")
            
            show(quiz: quizResultModel)
            
        } else {
            currentQuestionIndex += 1
            initImageView()
            questionFactory?.requestNextQuestion()
        }
        changeButtonsEnabled(enabled: true)
    }
}
