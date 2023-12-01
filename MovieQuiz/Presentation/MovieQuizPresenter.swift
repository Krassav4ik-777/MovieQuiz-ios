//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by KraSSavchiK on 01.12.2023.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    let questionsCount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsCount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // метод конвертации который принимает моковый вопрос и возвращает вью модель для главного экрана
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsCount)")
    }
}
