//
//  MessageManager.swift
//  Surlacarte
//
//  Created by Anindya Sengupta on 3/22/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

enum MessageType : String {
    case error = "Error"
    case warning = "Warning"
    case success = "Success"
}

final class MessageManager {

    static func displayError(errorMessage: CopyText, errorType: ErrorType, errorView: ErrorView, viewController: UIViewController) {
        switch errorType {
        case .responseError:
            fallthrough
        case .userInputError:
            MessageManager.display(type: .error, message: errorMessage, in: viewController, with: errorView)
            break
        case .connectionError:
            MessageManager.display(type: .error,  message: .connectivityErrorMessage, in: viewController, with: errorView)
            break
        }
    }

    static func display(type: MessageType, message: CopyText, in viewController: UIViewController, with errorview: ErrorView) {
        DispatchQueue.main.async {
            let padding : CGFloat = 6
            let minimumHeight: CGFloat = 44
            let msg = message.rawValue
            var messageBoxHeight = msg.height(withConstrainedWidth: UIScreen.main.bounds.width, font: applicationBodyFont) + padding
            messageBoxHeight = messageBoxHeight < minimumHeight ? minimumHeight : messageBoxHeight
            errorview.frame = CGRect(x: 0, y: -messageBoxHeight, width: UIScreen.main.bounds.width, height: messageBoxHeight)
            errorview.errorMessage.text = msg
            errorview.backgroundColor = getBackgroundColor(for: type)
            viewController.view.addSubview(errorview)
            viewController.view.bringSubview(toFront: errorview)
            animateIn(view: errorview) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                    animateOut(view: errorview, offset: messageBoxHeight)
                }
            }
        }

    }

    static func getBackgroundColor(for messageType: MessageType) -> UIColor {
        switch messageType {
        case .error:
            return #colorLiteral(red: 0.9520179629, green: 0.4614810944, blue: 0.3206613064, alpha: 1)
        case .success:
            return #colorLiteral(red: 0.6121523976, green: 0.7787978053, blue: 0.3688580692, alpha: 1)
        case .warning:
            return #colorLiteral(red: 1, green: 0.8138826489, blue: 0.2301810384, alpha: 1)
        }
    }

    static func animateIn(view: UIView, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2, animations: { 
            view.frame.origin.y = 0
        }) { (_) in
            completion()
        }
    }

    static func animateOut(view: UIView, offset: CGFloat) {
        UIView.animate(withDuration: 0.2, animations: {
            view.frame.origin.y = -offset
        }) { (_) in
            view.removeFromSuperview()
        }
    }
}
