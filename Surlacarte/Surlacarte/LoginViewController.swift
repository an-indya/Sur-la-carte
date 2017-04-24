//
//  LoginViewController.swift
//  Surlacarte
//
//  Created by Anindya Sengupta on 3/21/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

final class LoginViewController: UIViewController {

    @IBOutlet var errorview: ErrorView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let notificationManager = KeyboardNotificationManager.shared
    let loginManager = LoginManager()
    fileprivate var isUserInputValid : Bool {
        if let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            password.characters.count > 0,
            username.characters.count > 0 {
            return true
        }
        return false
    }

    //MARK: - View Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        notificationManager.viewController = self
        hideKeyboardWhenTappedAround()
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notificationManager.subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationManager.unsubscribeFromAllKeyboardNotifications()
    }

    //MARK: - Event Handlers

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func didTapLoginButton(_ sender: UIButton) {
        guard isUserInputValid else {
            self.displayError(errorMessage: CopyText.loginInvalid)
            return
        }
        sender.setTitle(CopyText.loginProgress, for: .normal)
        sender.isEnabled = false

        _ = loginManager.handleAuthentication(with: UserCredentials(username: usernameTextField.text!, password: passwordTextField.text!)).success { (sessionData) in
            self.loginManager.isUserLoggedIn = true
            _ = self.loginManager.fetchUserData(with: sessionData.accountKey).success(successClosure: { (userData) in
                UserDefaultsManager.setObject(object: userData, for: Keys.kUserDataKey)
                DispatchQueue.main.async {
                    sender.setTitle(CopyText.login, for: .normal)
                    sender.isEnabled = true
                    self.dismiss(animated: true, completion: nil)
                }
            }).failure {
                self.displayError(errorMessage: CopyText.loginErrorMessage)
            }}.failure {
                self.displayError(errorMessage: CopyText.loginErrorMessage)
            }
    }

    @IBAction func didTapSignupButton(_ sender: UIButton) {
        if let udacitySignupURL = URL(string: "\(URLs.udacityBaseURL)\(Endpoints.signup)") {
            UIApplication.shared.open(udacitySignupURL, options: [String: Any](), completionHandler: nil)
        }
    }

    @IBAction func didTapFBButton(_ sender: UIButton) {
    }

    func displayError(errorMessage: String) {
        MessageManager.display(type: .error, message: errorMessage, in: self, with: errorview)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let selectedTextField = TextFieldTag(rawValue: textField.tag) else {
            return false
        }
        notificationManager.selectedTextField = selectedTextField
        return true
    }
}
