//
//  Response.swift
//  Comy-iOS
//
//  Created by Quentin on 11/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation

protocol Response: Codable {
    var type: String { get }
}

enum ResponseType: String {
    case ServerState = "ServerStateResponse"
    case CommandResult = "CommandResult"
}
