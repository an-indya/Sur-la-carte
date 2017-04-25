//
//  NetworkManager.swift
//  Surlacarte
//
//  Created by Anindya Sengupta on 3/21/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

enum ErrorType : Int {
    case userInputError = 0
    case connectionError
    case responseError
}

enum Result<T> {
    case Success(T)
    case Failure(cause:ErrorType)
}

final class NetworkManager {

    func createSession(with credentials: UserCredentials, completion: @escaping (_ sessionInfo: Result<SessionData>) -> Void) {
        var urlComponents = URLComponents()
        let url = URL(string: URLs.udacityBaseURL)!
        urlComponents.scheme = url.scheme
        urlComponents.host = url.host
        urlComponents.path = Endpoints.createSession

        if let url = urlComponents.url {
            let session = URLSession.shared
            var request = URLRequest(url: url)
            request.httpMethod = MethodType.post.rawValue
            request.addValue(Constants.applicationJSON, forHTTPHeaderField: Constants.accept)
            request.addValue(Constants.applicationJSON, forHTTPHeaderField: Constants.contentType)
            request.httpBody = generateQueryString(with: credentials)

            let task = session.dataTask(with: request) {
                (data, response, error) in
                guard let _:Data = data, let _:URLResponse = response, error == nil else {
                    print("error")
                    completion(.Failure(cause: .connectionError))
                    return
                }

                let range = Range(5 ..< data!.count)//Udacity security requires skipping first 5 characters
                if let newData = data?.subdata(in: range) {
                    JSONParser.extractJSON(from: newData, parse: { (jsonObject) in
                        if let dictionary = jsonObject as? [String: Any],
                            let account = dictionary["account"] as? [String: Any],
                            let session = dictionary["session"] as? [String: Any],
                            let key = account["key"] as? String,
                            let id = session["id"] as? String,
                            let expiration = session["expiration"] as? String,
                            let date = expiration.convertToUTC() {
                            let session = SessionData(accountKey: key, sessionId: id, expiration: date)
                            UserDefaultsManager.setObject(object: session, for: Keys.kSessionKey)
                            completion(.Success(session))
                        } else {
                            completion(.Failure(cause: .userInputError))
                        }
                    })
                } else {
                    completion(.Failure(cause: .userInputError))
                }
            }
            task.resume()
        }
    }

    func deleteSession(completion: @escaping (_ status: Bool) -> Void) {
        var urlComponents = URLComponents()
        let url = URL(string: URLs.udacityBaseURL)!
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        urlComponents.scheme = url.scheme
        urlComponents.host = url.host
        urlComponents.path = Endpoints.createSession

        if let url = urlComponents.url {
            let session = URLSession.shared
            var request = URLRequest(url: url)
            request.httpMethod = MethodType.delete.rawValue
            request.addValue(Constants.applicationJSON, forHTTPHeaderField: Constants.accept)
            request.addValue(Constants.applicationJSON, forHTTPHeaderField: Constants.contentType)
            for cookie in sharedCookieStorage.cookies! {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            if let xsrfCookie = xsrfCookie {
                request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            }
            let task = session.dataTask(with: request) {
                (data, response, error) in
                guard let _:Data = data, let _:URLResponse = response, error == nil else {
                    print("error")
                    completion(false)
                    return
                }
                let range = Range(5 ..< data!.count)//Udacity security requires skipping first 5 characters
                if let newData = data?.subdata(in: range) {
                    JSONParser.extractJSON(from: newData, parse: { (jsonObject) in
                        if let dictionary = jsonObject as? [String: Any],
                            let session = dictionary["session"] as? [String: Any],
                            let _ = session["id"] as? String,
                            let expiration = session["expiration"] as? String,
                            let _ = expiration.convertToUTC() {
                            if let bundle = Bundle.main.bundleIdentifier {
                                UserDefaults.standard.removePersistentDomain(forName: bundle)
                            }
                            completion(true)
                        } else {
                            completion(false)
                        }
                    })
                }
                else {
                    completion(false)
                }
            }
            task.resume()
        }
    }

    func getUserInfo(with userId: String, completion: @escaping (_ userData: Result<UserData>) -> Void) {
        var urlComponents = URLComponents()
        let url = URL(string: URLs.udacityBaseURL)!
        urlComponents.scheme = url.scheme
        urlComponents.host = url.host
        urlComponents.path = "\(Endpoints.getUserInfo)\(userId)"

        if let url = urlComponents.url {
            let session = URLSession.shared
            var request = URLRequest(url: url)
            request.httpMethod = MethodType.get.rawValue

            let task = session.dataTask(with: request) {
                (data, response, error) in
                guard let _:Data = data, let _:URLResponse = response, error == nil else {
                    print("error")
                    completion(.Failure(cause: .connectionError))
                    return
                }

                let range = Range(5 ..< data!.count)//Udacity security requires skipping first 5 characters
                if let newData = data?.subdata(in: range) {
                    print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
                    JSONParser.extractJSON(from: newData, parse: { (jsonObject) in
                        if let dictionary = jsonObject as? [String: Any],
                            let user = dictionary["user"] as? [AnyHashable: Any],
                            let lastName = user["last_name"] as? String,
                            let firstName = user["first_name"] as? String,
                            let uniqueId = user["key"] as? String {
                                completion(.Success(UserData(firstName: firstName, lastName: lastName, uniqueId: uniqueId)))
                        } else {
                            completion(.Failure(cause: .userInputError))
                        }
                    })
                }
                else {
                    completion(.Failure(cause: .responseError))
                }
            }
            task.resume()
        }
    }

    func getStudentLocations(completion: @escaping (_ studentLocation: Result<StudentLocations>) -> Void) {
        var urlComponents = URLComponents()
        let url = URL(string: URLs.parseUdacityBaseURL)!
        urlComponents.scheme = url.scheme
        urlComponents.host = url.host
        urlComponents.path = Endpoints.getStudentLocations

        if let url = urlComponents.url {
            let session = URLSession.shared
            var request = URLRequest(url: url)
            request.httpMethod = MethodType.get.rawValue
            request.addValue(Parse.appId, forHTTPHeaderField: Parse.applicationIdKey)
            request.addValue(Parse.restApiKey, forHTTPHeaderField: Parse.restapi)

            let task = session.dataTask(with: request) {
                (data, response, error) in
                guard let _:Data = data, let _:URLResponse = response, error == nil else {
                    print("error")
                    completion(.Failure(cause: .connectionError))
                    return
                }

                if let data = data {
                    print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
                    JSONParser.extractJSON(from: data, parse: { (jsonObject) in
                        if let response = jsonObject as? [String: Any],
                            let dictionary = response["results"] as? [[AnyHashable: Any]] {
                            var locations = [StudentLocation]()
                            dictionary.forEach({ (location) in
                                if let firstName = location["firstName"] as? String,
                                    let latitude = location["latitude"] as? Double,
                                    let longitude = location["longitude"] as? Double,
                                    let mapString = location["mapString"] as? String,
                                    let mediaURL = location["mediaURL"] as? String,
                                    let objectId = location["objectId"] as? String,
                                    let uniqueKey = location["uniqueKey"] as? String,
                                    let updatedAt = location["updatedAt"] as? String,
                                    let date = updatedAt.convertToUTC() {
                                    let lastName = location["lastName"] ?? ""
                                    let studentLocation = StudentLocation(firstName: firstName, lastName : lastName as! String, latitude: latitude, longitude: longitude, mapString: mapString, mediaURL: mediaURL, objectId: objectId, uniqueKey: uniqueKey, updatedAt: date)
                                    locations.append(studentLocation)

                                } else {
                                    print("Error parsing student location item")
                                }
                            })
                            let studentLocations = StudentLocations(studentLocations: locations)
                            completion(.Success(studentLocations))
                        }
                    })} else {
                    completion(.Failure(cause: .responseError))
                }
            }
            task.resume()
        }
    }

    func submitStudentLocation(shouldUpdate: Bool, studentLocation: StudentLocation, completion: @escaping (_ studentLocation: Result<StudentLocation>) -> Void) {
        var urlComponents = URLComponents()
        let url = URL(string: URLs.parseUdacityBaseURL)!
        urlComponents.scheme = url.scheme
        urlComponents.host = url.host
        urlComponents.path = shouldUpdate ? Endpoints.updateStudentLocations.replacingOccurrences(of: "{objectId}", with: studentLocation.objectId) : Endpoints.getStudentLocations

        if let url = urlComponents.url {
            let session = URLSession.shared
            var request = URLRequest(url: url)
            request.httpMethod = shouldUpdate ? MethodType.put.rawValue : MethodType.post.rawValue
            request.addValue(Parse.appId, forHTTPHeaderField: Parse.applicationIdKey)
            request.addValue(Parse.restApiKey, forHTTPHeaderField: Parse.restapi)
            request.addValue(Constants.applicationJSON, forHTTPHeaderField: Constants.contentType)
            let bodyDict = ["uniqueKey" : studentLocation.uniqueKey,
                            "firstName" : studentLocation.firstName,
                            "lastName" : studentLocation.lastName,
                            "mapString" : studentLocation.mapString,
                            "mediaURL" : studentLocation.mediaURL,
                            "latitude" : studentLocation.latitude,
                            "longitude" : studentLocation.longitude] as [String : Any]            
            let postData = try? JSONSerialization.data(withJSONObject: bodyDict, options: [])
            request.httpBody = postData
            let task = session.dataTask(with: request) {
                (data, response, error) in
                guard let _:Data = data, let _:URLResponse = response, error == nil else {
                    print("error")
                    completion(.Failure(cause: .connectionError))
                    return
                }

                if let data = data {
                    JSONParser.extractJSON(from: data, parse: { (jsonObject) in
                        if let response = jsonObject as? [String: Any] {
                            if shouldUpdate {
                                if let objectId = response["objectId"] as? String {
                                    let studentLocation = StudentLocation(firstName: studentLocation.firstName, lastName : studentLocation.lastName, latitude: studentLocation.latitude, longitude: studentLocation.longitude, mapString: studentLocation.mapString, mediaURL: studentLocation.mediaURL, objectId: objectId, uniqueKey: studentLocation.uniqueKey, updatedAt: studentLocation.updatedAt)
                                    completion(.Success(studentLocation))
                                }
                            } else {
                                if let _ = response["updatedAt"] as? String {
                                    completion(.Success(studentLocation))
                                }
                            }

                        } else {
                            print("Error parsing student location item")
                        }
                    })
                } else {
                    completion(.Failure(cause: .responseError))
                }

            }
            task.resume()
        }
    }

    private func generateQueryString (with credentials: UserCredentials) -> Data? {
        let credentialsDictionary = [Constants.username: credentials.username, Constants.password : credentials.password]
        let wrapperDictionary = [Constants.udacity : credentialsDictionary]
        return JSONParser.parseJSON(from: wrapperDictionary)
    }
    
}
