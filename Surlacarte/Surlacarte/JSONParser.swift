//
//  JSONParser.swift
//  Surlacarte
//
//  Created by Anindya Sengupta on 3/21/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import Foundation

final class JSONParser {
    static func parseJSON(from dictionary: [String: Any]) -> Data? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            return jsonData

        } catch {
            print("JSON Serialization failed")
            return nil
        }
    }

    static func extractJSON(from data: Data, parse: ((Any) -> Void)){
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            parse(jsonObject)

        } catch {
            print("JSON Extraction failed")
        }
    }
}
