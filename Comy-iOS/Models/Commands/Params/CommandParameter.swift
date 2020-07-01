//
//  Parameter.swift
//  Comy-iOS
//
//  Created by Quentin on 23/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation

struct CommandParameter: Codable {
    
    let name: String
    let typeCode: Int
    let defaultValue: String
    let groupIndex: Int
    
}
