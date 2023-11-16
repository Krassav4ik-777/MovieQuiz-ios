
import Foundation
import UIKit

protocol AlertPresenter {
    func show(alertModel: AlertModel)
}

final class AlertPresenterImpl {
   private weak var viewController: UIViewController?
    
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
}

     // MARK: - AlertPresenter
extension AlertPresenterImpl: AlertPresenter {
    func show(alertModel: AlertModel) {
        // создаём объект всплывающего окна
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )
    // создаём для алерта кнопку с действием
        // в замыкании пишем,что должно происходить при нажатии кнопки
    let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
        alertModel.buttonAction()
    }
        
    //добавляем в алерт кнопку
    alert.addAction(action)
        
    // показываем всплывающее окно
        viewController?.present(alert, animated: true)
    }
}
