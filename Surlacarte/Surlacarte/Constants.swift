//
//  Constants.swift
//  Surlacarte
//
//  Created by Anindya Sengupta on 3/21/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import Foundation

enum MethodType: String {
    case delete = "DELETE"
    case post = "POST"
    case get = "GET"
    case put = "PUT"
}

enum ContentType: String {
    case map = "Map"
    case list = "List"
}

struct Constants {
    static let applicationJSON = "application/json"
    static let contentType = "Content-Type"
    static let accept = "Accept"
    static let username = "username"
    static let password = "password"
    static let udacity = "udacity"
}

struct Parse {
    static let applicationIdKey = "X-Parse-Application-Id"
    static let restapi = "X-Parse-REST-API-Key"
    static let appId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let restApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
}

enum CopyText: String {
    case login = "Login"
    case loginProgress = "Please wait. Logging you in..."
    case loginErrorMessage = "Error : Username and/or password incorrect. Please try again!"
    case loginInvalid = "Username and/or password can not be blank"
    case savingSuccess = "Success saving student location"
    case savingError = "Error saving student location"
    case connectivityErrorMessage = "Could not connect to internet. Please try again when connectivity resumes."
    case studentLocationFetchError = "Failed to fetch student locations"
    case linkInvalid = "The link appears to be invalid and could not be opened"
    case geocodeFailed = "Unable to determine the coordinates of the location entered"
}

struct URLs {
    static let udacityBaseURL = "https://www.udacity.com"
    static let parseUdacityBaseURL = "https://parse.udacity.com"
}

struct Endpoints {
    static let createSession = "/api/session"
    static let signup = "/account/auth#!/signup"
    static let getUserInfo = "/api/users/"
    static let getStudentLocations = "/parse/classes/StudentLocation"
    static let updateStudentLocations = "/parse/classes/StudentLocation/{objectId}"
}

struct Keys {
    static let kSessionKey = "kSessionKey"
    static let kStudentLocationsKey = "kStudentLocationsKey"
    static let kUserDataKey = "kUserDataKey"
}
