//
//  Endpoint.swift
//  ios-core-mvvm
//
//  Created by Admin on 1/26/22.
//

import Foundation

extension Endpoint {
    /**
     Post Method
     */
    static func register(_ body: HTTPBody) -> Self {
        Endpoint(path: "/users/register", method: .post(body))
    }
    /**
     Query
     */
    public static func getTestCert(idType: String,idNumber: String) -> Self {
        Endpoint(path: "/users/result", queryItems: [URLQueryItem(name: "idType", value: idType),URLQueryItem(name: "idNumber", value: idNumber)], method: .get)
    }
    
    public static func getTodoList(id: Int) -> Self {
        Endpoint(path: "/todos/\(id)", method: .get)
    }
    
    
}


public struct Endpoint {
    private let path: String
    private let queryItems: [URLQueryItem]
    let method: HTTPMethod
    
    init(path: String, method: HTTPMethod) {
        self.path = path
        self.queryItems = []
        self.method = method
    }
    
    init(path: String, queryItems: [URLQueryItem], method: HTTPMethod) {
        self.path = path
        self.queryItems = queryItems
        self.method = method
    }
    
    private var localUrl: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "jsonplaceholder.typicode.com"
       // components.port = 8181
        components.path = path
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        return components
    }
    private var productionUrl: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "reqres.in"
//        components.port = 8080
        components.path = "/api/" + path
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        return components
    }
    
    /**
        Base url where app will connect to
     */
    var url: URL {
        return localUrl.url!
    }
}
//https://jsonplaceholder.typicode.com/todos/1
