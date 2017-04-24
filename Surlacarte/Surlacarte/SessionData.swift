//
//  SessionData.swift
//  Surlacarte
//
//  Created by Anindya Sengupta on 3/21/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import Foundation

final class SessionData: NSObject, NSCoding {
    public private(set) var accountKey: String
    public private(set) var sessionId: String
    public private(set) var expiration: Date

    init(accountKey: String, sessionId: String, expiration: Date) {
        self.accountKey = accountKey
        self.sessionId = sessionId
        self.expiration = expiration
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        accountKey = aDecoder.decodeObject(forKey: "accountKey") as! String
        sessionId = aDecoder.decodeObject(forKey: "sessionId") as! String
        expiration = aDecoder.decodeObject(forKey: "expiration") as! Date
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(accountKey, forKey: "accountKey")
        aCoder.encode(sessionId, forKey: "sessionId")
        aCoder.encode(expiration, forKey: "expiration")
    }
}
