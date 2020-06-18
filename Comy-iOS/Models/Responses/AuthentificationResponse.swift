//
//  AuthentificationResponse.swift
//  Comy-iOS
//
//  Created by Quentin on 18/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation

struct AuthentificationResponse: Response{
    let type: String = "AuthentificationResponse"
    let token: String?
    let refreshToken: String?
    let userId: String?
    let message: String
    let code: Int
    let tokenExpiredError: Bool
    let wrongCredentialsError: Bool
}
