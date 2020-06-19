//
//  CommandResponse.swift
//  Comy-iOS
//
//  Created by Quentin on 16/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation

struct CommandResponse: Response {
    let type: String
    let commandName: String
    let result: CommandResult
    let authError: AuthentificationResponse?
}
