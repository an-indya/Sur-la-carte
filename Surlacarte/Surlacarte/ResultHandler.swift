//
//  ResultHandler.swift
//  Surlacarte
//
//  Created by Anindya Sengupta on 4/5/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

final class ResultHandler <T> {
    typealias FailureClosure = (Void)->Void
    typealias SuccessClosure = (T)->Void

    private var _failures = [FailureClosure]()
    private var _successes = [SuccessClosure]()

    /// Invoke all the stored callbacks with a given callback result
    func invokeCallbacks(result:Result<T>) {
        switch result {
        case .Success(let output):
            _successes.forEach{$0(output)}
        case .Failure:
            _failures.forEach{$0()}
        }
    }

    /// appends a new success callback to the result handler's successes array
    func success(successClosure:@escaping SuccessClosure) -> Self {
        _successes.append(successClosure)
        return self
    }

    /// appends a new failure callback to the result handler's failures array
    func failure(closure:@escaping FailureClosure) -> Self {
        _failures.append(closure)
        return self
    }
}

