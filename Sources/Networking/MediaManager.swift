//
//  MediaManager.swift
//  ios-core-mvvm
//
//  Created by Admin on 1/26/22.
//
/**
 Usage
 
 let media = Media(withImage: UIImage, forKey: String)
 MediaManager.shared.requestUploadMedia(mediaImage: media, parameters: nil) { result in
 switch result {
 case .success(let data):
 break
 case .failure(let errror):
 break
 default:
 print("not found")
 }
 }
 
 */

import UIKit

public class MediaManager: NSObject {
    
    public var shared = MediaManager()
    
    func requestUploadMedia<T:Codable>(mediaImage: Media, parameters: [String: String]? = [:],completionHandler: @escaping (Result<T, NetworkError>) -> Void) {
        
        let url = URL(string: "")!
        let boundary = generateBoundary()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "X-User-Agent": "ios",
            "Accept-Language": "en",
            "Accept": "application/json",
            "Content-Type": "multipart/form-data; boundary=\(boundary)",
        ]
        let dataBody = createDataBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
        request.httpBody = dataBody
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let body = data {
                let bodyString = String(data: body, encoding: String.Encoding.utf8) ?? "Can't render body; not utf8 encoded";
//                self.log(tag: "bodyString", msg: bodyString)
            }
            
//            self.log(tag: "MediaManager", msg: response?.description ?? "empty")
            if let error = error {
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
            
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                completionHandler(.success(result))
            } catch {
                completionHandler(.failure(.decodingError(error)))
            }
            
        }.resume()
    }
    
    
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createDataBody(withParameters params: [String: String]?, media: [Media]?, boundary: String) -> Data {
        
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }
        
        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.fileName)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}


struct Media: Codable {
    let key: String
    let fileName: String
    let data: Data
    let mimeType: String
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        self.mimeType = "image/jpg"
        self.fileName = "\(arc4random()).jpeg"
        
        guard let data = image.jpegData(compressionQuality: 0.5) else { return nil }
        self.data = data
    }
}

