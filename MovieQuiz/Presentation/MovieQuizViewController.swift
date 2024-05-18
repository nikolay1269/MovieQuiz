import UIKit

private struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}

private struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

private struct QuizResultViewModel {
    let title: String
    let text: String
    let buttonText: String
}

final class MovieQuizViewController: UIViewController {
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)]
    
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showFirstQuestion()
        initImageView()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let question = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: question.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let question = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: !question.correctAnswer)
    }
    
    private func showFirstQuestion() {
        let firstQuestion = questions[currentQuestionIndex]
        let firstStep = convert(model: firstQuestion)
        show(quiz: firstStep)
    }
    
    private func initImageView() {
        imageView.layer.borderWidth = 0
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(),
                          question: model.text,
                          questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultViewModel) {
        let alert = UIAlertController(title: result.title,
                                      message: result.text,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.showFirstQuestion()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true)
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
        if currentQuestionIndex == questions.count - 1 {
            
            initImageView()
            
            let quizResultModel = QuizResultViewModel(title: "Этот раунд окончен",
                                                      text: "Ваш результат \(correctAnswers)/10",
                                                      buttonText: "Сыграть ещё раз?")
            
            show(quiz: quizResultModel)
            
        } else {
            currentQuestionIndex += 1
            initImageView()
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            show(quiz: viewModel)
        }
        changeButtonsEnabled(enabled: true)
    }
}
