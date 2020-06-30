//
//  ServerCredentials.swift
//  Comy-iOS
//
//  Created by Quentin on 30/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ServerCredentials: NSManagedObject {
    
    static func from(url: String) -> ServerCredentials? {
        let request: NSFetchRequest<ServerCredentials> = ServerCredentials.fetchRequest()
        guard let credentialsArray = try? (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.fetch(request) else {
            return nil
        }
        guard let serverCredentials = credentialsArray.filter({$0.url == url}).first, serverCredentials.url != nil, serverCredentials.accessToken != nil, serverCredentials.refreshToken != nil else {
            return nil
        }
        return serverCredentials
    }
    
    static func saveCredentials(url: String, accessToken: String, refreshToken: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let credentials = from(url: url) ?? ServerCredentials(context: context)
        credentials.url = url
        credentials.accessToken = accessToken
        credentials.refreshToken = refreshToken
        try? context.save()
    }
    
    static func deleteCredentials(url: String) {
        guard let credentials = from(url: url) else { return }
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        context.delete(credentials)
        try? context.save()
    }
    
}
