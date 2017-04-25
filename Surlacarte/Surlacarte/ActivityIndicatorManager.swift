//
//  ActivityIndicatorManager.swift
//  Surlacarte
//
//  Created by Anindya Sengupta on 4/24/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

final class ActivityManager {
    static let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)


    class func showActivityIndicator (in view: UIView) {
        DispatchQueue.main.async {
            view.addSubview(activity)
            activity.center = view.center
            activity.startAnimating()
        }
    }

    class func hideActivityIndicator () {
        DispatchQueue.main.async {
            activity.stopAnimating()
        }
    }


}
