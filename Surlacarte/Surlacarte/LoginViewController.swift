//
//  LoginViewController.swift
//  Surlacarte
//
//  Created by Anindya Sengupta on 3/21/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

enum ContentType: String {
    case map = "Map"
    case list = "List"
}

class LoginViewController: UIViewController {

    let notificationManager = KeyboardNotificationManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        notificationManager.viewController = self
        hideKeyboardWhenTappedAround()
        setNeedsStatusBarAppearanceUpdate()
        // Do any additional setup after loading the view.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notificationManager.subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationManager.unsubscribeFromAllKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapLoginButton(_ sender: UIButton) {
        performSegue(withIdentifier: "showContent", sender: ContentType.map)
    }

    @IBAction func didTapSignupButton(_ sender: UIButton) {
        if let udacitySignupURL = URL(string: "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.shared.open(udacitySignupURL, options: [String: Any](), completionHandler: nil)
        }
    }

    @IBAction func didTapFBButton(_ sender: UIButton) {
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
