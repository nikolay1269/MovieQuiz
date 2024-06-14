//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Nikolay on 21.05.2024.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    // MARK: - Public Properties
    weak var delegate: QuestionFactoryDelegate?
    
    // MARK: - Private Properties
    private let movieLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    
    // MARK: - Initializers
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate? = nil) {
        
        self.movieLoader = moviesLoader
        self.delegate = delegate
    }
    
    // MARK: - Public Methods
    func requestNextQuestion() {
        
        DispatchQueue.global().async { [weak self] in
            
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else { return }
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func loadData() {
        
        movieLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromSever()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}
