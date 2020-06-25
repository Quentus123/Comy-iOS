//
//  SettingCell.swift
//  Comy-iOS
//
//  Created by Quentin on 25/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import RxSwift

protocol SettingCell: class {
    var valueChanged: PublishSubject<String> { get }
    var title: String { get set }
    var value: String { get set }
}
