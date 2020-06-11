//
//  Message.swift
//  Comy-iOS
//
//  Created by Quentin on 11/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation

protocol Message: Codable{
    var type: String { get }
}
