import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // шрифты для объектов экрана
        buttonNo.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        buttonYes.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        imageView.layer.cornerRadius = 20
        questionFactory?.delegate = self
        // вызов первого вопроса
        questionFactory?.requestNextQuestion()
        alertPresenter = AlertPresenterImpl(viewController: self)
//TODO   statisticService = StatisticServiceIml
// Файлы которые лежат в приложении print(NSHomeDirectory())
// Содержание исполняемых файлов  print(Bundle.main.bundlePath)
        
    }
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // проверка, что вопрос не nil
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // Outlet для ViewModel
    @IBOutlet private weak var buttonNo: UIButton!
    @IBOutlet private weak var buttonYes: UIButton!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    
    // Общее количество вопросов для квиза
    private let questionsAmount: Int = 10
    
    // Фабрика вопросов.Контроллер будет обращаться за вопросами к ней.
    private var questionFactory: QuestionFactoryProtocol? = QuestionFactory()
    
    private var alertPresenter: AlertPresenter?
    
//TODO    private var statisticService: StatisticService?
    
    // вопрос,который видит пользователь
    private var currentQuestion: QuizQuestion?
    
    // переменная с индексом текущего вопроса,начальное 0 так-как индекс массива начинается с 0
    private var currentQuestionIndex = 0
    
    //  переменная с счётчиком правильных ответов
    private var correctAnswers = 0
    
    // cостояние "Результата ответа"
    private var responseResult: Bool = true
    
    // приватный метод который меняет цвет рамки и вызывает метод перехода,и обрабатывает результат ответа
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionResults()
        }
    }
    
    // метод конвертации который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1) / \(questionsAmount)")
        return questionStep
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        indexLabel.text = step.questionNumber
    }
    
    // приватный метод который содержит логику перехода в один из сценариев
    private func showNextQuestionResults() {
        imageView.layer.borderWidth = 0
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultViewModel(title: "Этот раунд окончен!",
                                                text: text,
                                                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel) // идём в состояние "Результат квиза"
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }
    // приватный метод для показа результатов раунда квиза
    private func show(quiz result: QuizResultViewModel) {
// TODO        statisticService?.store
        let alertModel = AlertModel(
            title: "Игра окончена",
            message: "Вы ответили на \(correctAnswers) из 10",
            buttonText: "Cыграть ещё раз!",
            buttonAction: { [ weak self ] in
                self?.currentQuestionIndex = 0
                // сбрасываем переменную с количеством правильных ответов
                self?.correctAnswers = 0
                // заново показываем первый вопрос
                self?.questionFactory?.requestNextQuestion()
            }
        )
        
        alertPresenter?.show(alertModel: alertModel)
}

    // метод вызывается при нажатии кнопки Нет
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // метод вызывается при нажатии кнопки Да
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
}






/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
