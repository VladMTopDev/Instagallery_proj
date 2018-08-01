//
//  UIViewController+AlertAdditions.swift
//

import Foundation
import UIKit
import Rswift

typealias AlertDummyCompletion = () -> Void

extension UIViewController {

    // Shows alert with error and title
    func showAlertWithError(error: Error?, title: String?) {
        let alert = UIAlertController(title: title, message: error?.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.ok(), style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    // Shows alert with ok and cancel buttons
    func showOkCancelAlert(withTitle title: String?, message: String?, completion: ((Bool) -> Void)?) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: R.string.localizable.cancel(), style: .cancel, handler: { _ in
            if let compl = completion {
                compl(false)
            }
        }))
        alert.addAction(UIAlertAction.init(title: R.string.localizable.ok(), style: .default, handler: { _ in
            if let compl = completion {
                compl(true)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // Shows alert with ok button
    func showOkAlert(withTitle title: String?, message: String?, completion: ((Bool) -> Void)?) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title:R.string.localizable.ok(), style: .default, handler: { _ in
            if let compl = completion {
                compl(true)
            }
        }))
        present(alert, animated: true, completion: nil)
    }

}
