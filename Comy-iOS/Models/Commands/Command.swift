//
//  Command.swift
//  Comy-iOS
//
//  Created by Quentin on 11/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation

struct Command: Codable, Hashable {
    
    //In Comy Server framework we cannot launch server if two commands have the same name
    static func == (lhs: Command, rhs: Command) -> Bool {
        return lhs.name == rhs.name
    }
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    let name: String
    let imageURL: String?
    let mainParameter: CommandParameter?
    let secondariesParameters: [CommandParameter]
    
    enum CodingKeys: String, CodingKey {
        case name
        case imageURL
        case mainParameter
        case secondariesParameters
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        imageURL = try values.decodeIfPresent(String.self, forKey: .imageURL)
        mainParameter = try values.decodeIfPresent(CommandParameter.self, forKey: .mainParameter)
        secondariesParameters = try values.decodeIfPresent([CommandParameter].self, forKey: .secondariesParameters) ?? []
    }
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
