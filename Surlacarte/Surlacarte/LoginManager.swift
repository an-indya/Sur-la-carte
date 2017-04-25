//
//  LoginHelper.swift
//  Surlacarte
//
//  Created by Anindya Sengupta on 3/21/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

final class LoginManager {

    let networkManager = NetworkManager()
    var isUserLoggedIn  = false

    func dismiss (viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }

    func handleAuthentication(with credentials: UserCredentials) -> ResultHandler<SessionData> {
        let resultHandler = ResultHandler<SessionData>()
        networkManager.createSession(with: credentials, completion: resultHandler.invokeCallbacks)
        return resultHandler
    }

    func fetchUserData(with userId: String) -> ResultHandler<UserData> {
        let resultHandler = ResultHandler<UserData>()
        networkManager.getUserInfo(with: userId, completion: resultHandler.invokeCallbacks)
        return resultHandler
    }

    static func initiateAuthentication() {
        let session : SessionData? = UserDefaultsManager.getObject(for: Keys.kSessionKey)
        if session == nil {
            DispatchQueue.main.async {
                let loginViewController = StoryboardManager.instantiateViewController(with: "LoginViewController")
                StoryboardManager.getTopViewController().present(loginViewController, animated: true, completion: nil)
            }
        }
    }

    static func logout () {
        NetworkManager().deleteSession { (status) in
            UserDefaultsManager.clearAllData()
            initiateAuthentication()
        }
    }
}
