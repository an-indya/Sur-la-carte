//
//  StudentLocationManager.swift
//  Surlacarte
//
//  Created by Anindya Sengupta on 4/1/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

final class StudentLocationManager: NSObject {

    static let shared = StudentLocationManager()
    private override init() {}

    let networkManager = NetworkManager()
    var downloadedLocations: StudentLocations?

    func fetchStudentLocations() -> ResultHandler<StudentLocations> {
        let resultHandler = ResultHandler<StudentLocations>()
        networkManager.getStudentLocations(completion: resultHandler.invokeCallbacks)
        return resultHandler
    }

    func submitStudentLocation(shouldUpdate: Bool, studentLocation: StudentLocation) -> ResultHandler<StudentLocation> {
        let resultHandler = ResultHandler<StudentLocation>()
        networkManager.submitStudentLocation(shouldUpdate: shouldUpdate, studentLocation: studentLocation, completion: resultHandler.invokeCallbacks)
        return resultHandler
    }
}
