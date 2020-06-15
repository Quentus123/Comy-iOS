//
//  Command.swift
//  Comy-iOS
//
//  Created by Quentin on 11/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation

class Command: Codable {
    let name: String
    let imageURL: String?
}

extension Command {
    func downloadImageData(completion: @escaping (Data?) -> ()) {
        
        func completionInMainThread(_ data: Data?) {
            DispatchQueue.main.async {
                completion(data)
            }
        }
        
        guard let imageURL = imageURL else {
            completionInMainThread(nil)
            return
        }
        guard let url = URL(string: imageURL) else {
            completionInMainThread(nil)
            return
        }
        
        let request = URLRequest(url: url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completionInMainThread(nil)
                return
            }
            completionInMainThread(data)
        }.resume()
    }
}
