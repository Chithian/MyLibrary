//
//  NetworkResponse.swift
//  ios-core-mvvm
//
//  Created by Admin on 1/26/22.
//

import Foundation

struct Response: Codable {
    let code: Int
    let message: String
}

struct ResponseModel: Codable {
    let response: Response
}
