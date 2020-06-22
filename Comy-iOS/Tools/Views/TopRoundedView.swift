//
//  TopRoundedView.swift
//  Comy-iOS
//
//  Created by Quentin on 22/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import UIKit

class TopRoundedView: UIView {
    
    var roundedCoef: CGFloat = 15
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10)).cgPath
        layer.mask = maskLayer
    }
    
}
