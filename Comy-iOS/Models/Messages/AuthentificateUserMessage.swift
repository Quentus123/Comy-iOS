//
//  AuthentificateUserMessage.swift
//  Comy-iOS
//
//  Created by Quentin on 18/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation

struct AuthentificationUserMessage: Message {
    let type: String = "AuthentificateUserMessage"
    let id: String
    let password: String
}
