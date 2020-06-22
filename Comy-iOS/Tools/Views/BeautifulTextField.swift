//
//  BeautifulTextField.swift
//  Comy-iOS
//
//  Created by Quentin on 22/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class BeautifulTextField: UIView {
    
    @IBInspectable var title: String = "" {
       didSet {
        titleLabel.text = title
        textField.placeholder = title
       }
    }
    @IBInspectable var textFieldRoundedCoef: CGFloat = 10
    @IBInspectable var titleFontSize: CGFloat = 20 {
        didSet {
            titleLabel.font = UIFont.systemFont(ofSize: titleFontSize, weight: .semibold)
        }
    }
    @IBInspectable var textFieldFontSize: CGFloat = 20 {
        didSet {
            textField.font = UIFont.systemFont(ofSize: textFieldFontSize, weight: .regular)
        }
    }
    
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textFieldContainer: UIView!
    @IBOutlet weak var textField: UITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle(for: type(of: self)).loadNibNamed("BeautifulTextField", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        textField.delegate = self
        
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textFieldContainer.layer.masksToBounds = true
        textFieldContainer.layer.cornerRadius = textFieldRoundedCoef
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
        
        titleLabel.text = title
        textField.placeholder = title
        titleLabel.font = UIFont.systemFont(ofSize: titleFontSize, weight: .semibold)
        textField.font = UIFont.systemFont(ofSize: textFieldFontSize, weight: .regular)
        textFieldContainer.layer.masksToBounds = true
        textFieldContainer.layer.cornerRadius = textFieldRoundedCoef
        
        contentView.prepareForInterfaceBuilder()
    }
    
}

extension BeautifulTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
