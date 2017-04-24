//
//  StudentLocation.swift
//  Surlacarte
//
//  Created by Anindya Sengupta on 3/31/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import CoreLocation

struct StudentLocations {
    public var studentLocations = [StudentLocation]()
}

struct StudentLocation {
    public private(set) var firstName: String
    public private(set) var lastName: String
    public var latitude: Double
    public var longitude: Double
    public var mapString: String
    public var mediaURL: String
    public private(set) var objectId: String
    public private(set) var uniqueKey: String
    public private(set) var updatedAt: Date
}

extension StudentLocation {
    public var fullName: String {
        return firstName + " " + lastName
    }

    public var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}


