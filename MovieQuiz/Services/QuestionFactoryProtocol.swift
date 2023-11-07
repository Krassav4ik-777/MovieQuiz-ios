//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by KraSSavchiK on 05.11.2023.
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    var delegate: QuestionFactoryDelegate? { get set }
}
