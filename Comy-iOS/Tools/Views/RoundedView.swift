//
//  RoundedView.swift
//  Comy-iOS
//
//  Created by Quentin on 22/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import UIKit

class RoundedView: UIView {
    
    var roundedCoef: CGFloat = 15
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.masksToBounds = true
        layer.cornerRadius = roundedCoef
    }
    
}
