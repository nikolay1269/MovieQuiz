//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Nikolay on 27.05.2024.
//

import UIKit

class AlertPresenter {
    
    static func showAlert(model: AlertModel, viewController: UIViewController) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        alert.addAction(action)
        
        viewController.present(alert, animated: true)
    }
}
