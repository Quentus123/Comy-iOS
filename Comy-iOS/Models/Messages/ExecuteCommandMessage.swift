//
//  ExecuteCommandMessage.swift
//  Comy-iOS
//
//  Created by Quentin on 11/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation

struct ExecuteCommandMessage: Message {
    let type: String = "ExecuteCommand"
    let commandName: String
    let token: String?
}
