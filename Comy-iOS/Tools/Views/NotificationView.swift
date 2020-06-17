//
//  NotificationView.swift
//  Comy-iOS
//
//  Created by Quentin on 16/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class NotificationView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle(for: type(of: self)).loadNibNamed("NotificationView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 10
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
        contentView.prepareForInterfaceBuilder()
    }
    
    func switchToErrorState(content: String?) {
        mainContainer.backgroundColor = UIColor.systemRed
        iconImageView.image = UIImage(systemName: "multiply.circle")
        contentLabel.text = content ?? "Unexpected error"
    }
    
    func switchToSuccessState(content: String?) {
        mainContainer.backgroundColor = UIColor.systemGreen
        iconImageView.image = UIImage(systemName: "info.circle")
        contentLabel.text = content ?? "Success"
    }
    
}
