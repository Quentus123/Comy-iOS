//
//  IntegerSelector.swift
//  Comy-iOS
//
//  Created by Quentin on 24/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

@IBDesignable
class IntegerSelector: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    var valueChanged: PublishSubject<Int> = PublishSubject()
    var value: Int {
        get {
            return Int(label.text ?? "0") ?? 0
        }
        set {
            label.text = String(newValue)
            valueChanged.onNext(newValue)
        }
    }
    
    @IBInspectable var color: UIColor = .link {
        didSet {
            minusButton.tintColor = color
            label.textColor = color
            plusButton.tintColor = color
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle(for: type(of: self)).loadNibNamed("IntegerSelector", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        minusButton.addTarget(self, action: #selector(minusTouched), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plusTouched), for: .touchUpInside)
        
        layoutIfNeeded()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
        
        minusButton.tintColor = color
        plusButton.tintColor = color
        
        contentView.prepareForInterfaceBuilder()
    }
    
    @objc private func minusTouched() {
        value = value - 1
    }
    
    @objc private func plusTouched() {
        value = value + 1
    }
    
}
