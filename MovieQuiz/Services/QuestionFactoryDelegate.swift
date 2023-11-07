//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by KraSSavchiK on 06.11.2023.
//

import Foundation


protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
