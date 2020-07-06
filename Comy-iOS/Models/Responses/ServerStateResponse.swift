//
//  ServerStateResponse.swift
//  Comy-iOS
//
//  Created by Quentin on 12/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation

struct ServerStateResponse: Response{
    let type: String
    let name: String
    let commands: [Command]
    let authError: AuthenticationResponse?
}
