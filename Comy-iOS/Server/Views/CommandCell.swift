//
//  CommandCell.swift
//  Comy-iOS
//
//  Created by Quentin on 15/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class CommandCell: UITableViewCell {
    
    enum SelectorType: Int {
        case None = -1
        case Boolean = 0
        case Integer = 1
    }
    
    @IBOutlet var xibView: UIView!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var selectorContainer: UIView!
    @IBOutlet weak var integerSelector: IntegerSelector!
    
    var selectorType: SelectorType = .None
    
    var onTouch: PublishSubject<Void> = PublishSubject()
    var valueChanged: PublishSubject<String> = PublishSubject()
    private var disposeBag = DisposeBag() //will be reset in prepareForReuse
    
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
        
        selectorContainer.backgroundColor = selectorContainer.backgroundColor?.withAlphaComponent(0.7)
        
        integerSelector.valueChanged
            .subscribe(onNext: { [weak self] intValue in
                guard let self = self else { return }
                self.valueChanged.onNext(String(intValue))
            })
            .disposed(by: disposeBag)
        
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
        mainContainer.layer.masksToBounds = true
        mainContainer.layer.cornerRadius = 10
    }
    
    func setSelectorType(type: SelectorType, defaultValue: String? = nil) {
        selectorContainer.isHidden = type == .None
        selectorContainer.isUserInteractionEnabled = type != .None
        integerSelector.isHidden = true
        integerSelector.isUserInteractionEnabled = false
        
        switch type {
        case .Integer:
            integerSelector.isHidden = false
            integerSelector.isUserInteractionEnabled = true
            let numberDefaultValue = Int(defaultValue ?? "0")
            integerSelector.value = numberDefaultValue ?? 0
        default:
            break
        }
        
        selectorType = type
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch = touches.first!
        let touchLocation = touch.location(in: self)
        let selectorContainerRect = selectorContainer.superview!.convert(selectorContainer.frame, to: self)
        
        if (!selectorContainerRect.contains(touchLocation)) || (selectorType == .None) {
            onTouch.onNext(())
        } else {
            print("selector touched")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
