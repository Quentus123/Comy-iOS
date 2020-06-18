//
//  RefreshTokenMessage.swift
//  Comy-iOS
//
//  Created by Quentin on 18/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation

struct RefreshTokenMessage: Message {
    let type: String = "RefreshTokenMessage"
    let refreshToken: String
}
