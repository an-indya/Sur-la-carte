//
//  UserDefaultsManager.swift
//  Surlacarte
//
//  Created by Anindya Sengupta on 3/22/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import Foundation

final class UserDefaultsManager {

    static func setObject<T>(object: T, for key: String) where T: NSCoding {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: object)
        UserDefaults.standard.set(encodedData, forKey: key)
    }

    static func getObject<T>(for key: String) -> T? where T: NSCoding {
        guard let object = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObject(with: object) as? T
    }

    static func clearAllData () {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }

    static func isDataAvailable(for key: String) -> Bool {
        return UserDefaults.standard.value(forKey: key) != nil
    }
}
