//
//  NeedStateMessage.swift
//  Comy-iOS
//
//  Created by Quentin on 11/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation

struct NeedStateMessage: Message {
    let type: String = "Need refresh"
    let token: String?
}
