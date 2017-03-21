//
//  NotificationManager.swift
//  MemeMe
//
//  Created by Anindya Sengupta on 2/21/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import Foundation
import UIKit

enum TextFieldTag: Int {
    case topTextField = 1
    case bottomTextField = 2
}

final class KeyboardNotificationManager : NSObject {
    static let shared = KeyboardNotificationManager()
    private override init() {}
    var selectedTextField: TextFieldTag = .topTextField
    var viewController: UIViewController?


    func subscribeToKeyboardNotifications () {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: .UIKeyboardWillHide,
                                               object: nil)
    }

    func unsubscribeFromAllKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
}

extension KeyboardNotificationManager {
    func keyboardWillShow(_ notification:Notification) {
        guard let viewController = viewController else {
            return
        }
        if self.selectedTextField == .bottomTextField {
            viewController.view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
        else {
            viewController.view.frame.origin.y = 0
        }
    }

    func keyboardWillHide(_ notification:Notification) {
        guard let viewController = viewController else {
            return
        }
        viewController.view.frame.origin.y = 0
    }

    private func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}
