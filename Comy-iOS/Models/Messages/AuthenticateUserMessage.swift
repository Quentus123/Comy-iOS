//
//  AuthentificateUserMessage.swift
//  Comy-iOS
//
//  Created by Quentin on 18/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation

struct AuthenticationUserMessage: Message {
    let type: String = "AuthenticateUserMessage"
    let username: String
    let password: String
}
