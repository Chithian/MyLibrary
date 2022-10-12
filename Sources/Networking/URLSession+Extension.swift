//
//  URLSession+Extension.swift
//  ios-core-mvvm
//
//  Created by Admin on 1/26/22.
//

import UIKit

extension URLSession {
    /**
     Call this method to request to server
     
     - Parameters:
     - url: The URL for the request.
     - body: The data sent as the message body of a request, such as for an HTTP POST request.
     - timeoutInterval: The timeout interval for the request. The default is 60.0. See the commentary for the timeoutInterval for more information on timeout intervals.
     
     */
public func request<T:Codable>(_ endpoint: Endpoint, headers: [String: String] = [:], cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, timeoutInterval: TimeInterval = 60.0,completionHandler: @escaping (Result<T, NetworkError>) -> Void) {
        print("\(endpoint.method.description) : url \(endpoint.url)")
        var request = URLRequest(url: endpoint.url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        request.httpMethod = endpoint.method.description
        request.allHTTPHeaderFields = headers
        
        switch endpoint.method {
        case .post(let body), .put(let body):
            if let body = body {
                let jsonData = try? JSONSerialization.data(withJSONObject: body.body, options: [])
                request.httpBody = jsonData
            }
        default: break
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            //check for errors
            if let error = error {
                print("Error loading data! \n\(error.localizedDescription)")
                completionHandler(.failure(.transportError(error)))
                return
            }
            
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                completionHandler(.failure(.serverError(statusCode: response.statusCode)))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(.noData))
                return
            }
            
            do{
                //print("Data \(String(describing: String(data: data!, encoding: .utf8)))")
                let result = try JSONDecoder().decode(T.self, from: data)
                completionHandler(.success(result))
            }catch{
                print("Decode failed", error, separator: " ")
                completionHandler(.failure(.decodingError(error)))
            }
            
        }
        task.resume()
    }
    
}
