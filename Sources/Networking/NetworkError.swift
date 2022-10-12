//
//  NetworkError.swift
//  ios-core-mvvm
//
//  Created by Admin on 1/26/22.
//

import Foundation

public enum NetworkError: Error {
    case transportError(Error)
    case serverError(statusCode: Int)
    case noData
    case decodingError(Error)
    case encodingError(Error)
}
