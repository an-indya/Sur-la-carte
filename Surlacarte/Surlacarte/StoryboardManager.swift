//
//  StoryboardManager.swift
//  Surlacarte
//
//  Created by Anindya Sengupta on 3/22/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

final class StoryboardManager: NSObject {

    static func instantiateViewController<T>(with identifier: String) -> T where T: UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("Could not instantiate view controller. Set the identifier in storyboard may be?")
        }
        return viewController
    }

    static func getTopViewController () -> UIViewController {
        guard var topController = UIApplication.shared.keyWindow?.rootViewController else {
            fatalError("Failed to retrieve the root viewcontroller of the window")
        }
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
}


public protocol SegueHandler {
    associatedtype SegueIdentifier: RawRepresentable
}


extension SegueHandler where Self: UIViewController, SegueIdentifier.RawValue == String {
    public func segueIdentifier(for segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier,
            let segueIdentifier = SegueIdentifier(rawValue: identifier)
            else { fatalError("Unknown segue: \(segue))") }
        return segueIdentifier
    }

    public func performSegue(withIdentifier segueIdentifier: SegueIdentifier, sender: Any?) {
        performSegue(withIdentifier: segueIdentifier.rawValue, sender: sender)
    }
}
