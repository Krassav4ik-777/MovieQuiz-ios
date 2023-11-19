import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonNo.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        buttonYes.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenterImpl(viewController: self)
        statisticService = StatisticServiceImpl()
        showLoadingIndicator()
        questionFactory?.loadData()
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
    
    // MARK: - IB Outlets
    @IBOutlet private weak var buttonNo: UIButton!
    @IBOutlet private weak var buttonYes: UIButton!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private variables
    // Общее количество вопросов для квиза
    private let questionsCount: Int = 10
    // Фабрика вопросов.Контроллер будет обращаться за вопросами к ней.(???)
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    // вопрос,который видит пользователь
    private var currentQuestion: QuizQuestion?
    // переменная с индексом текущего вопроса,начальное 0 так-как индекс массива начинается с 0
    private var currentQuestionIndex: Int = 0
    //  переменная с счётчиком правильных ответов
    private var correctAnswers: Int = 0
    // cостояние "Результата ответа"
    private var responseResult: Bool = true
    
    // MARK: - Private Methods
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
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsCount)")
//        let questionStep = QuizStepViewModel(
//            image: UIImage(named: model.image) ?? UIImage(),
//            question: model.text,
//            questionNumber: "\(currentQuestionIndex + 1) / \(questionsCount)")
//        return questionStep
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
        if currentQuestionIndex == questionsCount - 1 {
            showFinalResults()
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func showFinalResults() {
        statisticService?.store(correct: correctAnswers, total: questionsCount)
        
        let alertModel = AlertModel(
            title: "Игра окончена",
            message: makeResultMessage() ,
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
    
    private func makeResultMessage() -> String {
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            assertionFailure("error message")
            return ""
        }
        
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsCount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString)) "
        let averageAccuracyLine = " Средняя точность: \(accuracy)%"
        
        let components: [String] = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ]
        
        let resultMessage = components.joined(separator: "\n")
        
        return resultMessage
        
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: String) {
//        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.show(alertModel: model)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - IB Actions
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


