//
//  UserData.swift
//  Surlacarte
//
//  Created by Anindya Sengupta on 3/31/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

final class UserData: NSObject, NSCoding {
    public private(set) var firstName: String
    public private(set) var lastName: String
    public private(set) var uniqueId: String


    init(firstName: String, lastName: String, uniqueId: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.uniqueId = uniqueId
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        firstName = aDecoder.decodeObject(forKey: "firstName") as! String
        lastName = aDecoder.decodeObject(forKey: "lastName") as! String
        uniqueId = aDecoder.decodeObject(forKey: "uniqueId") as! String
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(firstName, forKey: "firstName")
        aCoder.encode(lastName, forKey: "lastName")
        aCoder.encode(uniqueId, forKey: "uniqueId")
    }
}
