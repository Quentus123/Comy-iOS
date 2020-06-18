//
//  ServerInfoResponse.swift
//  Comy-iOS
//
//  Created by Quentin on 18/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation

struct ServerInfoResponse: Response{
    let type: String = "ServerInfoResponse"
    let serverName: String
    let isSecured: Bool
}
