//
//  CommandCell.swift
//  Comy-iOS
//
//  Created by Quentin on 15/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import UIKit

class CommandCell: UITableViewCell {
    
    @IBOutlet var xibView: UIView!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("CommandCell", owner: self, options: nil)
        contentView.addSubview(xibView)
        xibView.frame = contentView.bounds
        xibView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
        mainContainer.layer.masksToBounds = true
        mainContainer.layer.cornerRadius = 10
    }
    
}
