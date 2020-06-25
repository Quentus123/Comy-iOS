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
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var selectorContainer: UIView!
    @IBOutlet weak var integerSelector: IntegerSelector!
    
    var selectorType: SelectorType = .None
    var isSettingsButtonEnabled = false {
        didSet {
            settingsButton.isHidden = !isSettingsButtonEnabled
            settingsButton.isEnabled = isSettingsButtonEnabled
        }
    }
    
    var onTouch: PublishSubject<Void> = PublishSubject()
    var valueChanged: PublishSubject<String> = PublishSubject()
    var onTapSetting: PublishSubject<Void> = PublishSubject()
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
        
        createRxSubscriptions()
        settingsButton.imageView?.contentMode = .scaleAspectFit
        isSettingsButtonEnabled = false
        
        layoutIfNeeded()
    }
    
    private func createRxSubscriptions() {
        integerSelector.valueChanged
        .subscribe(onNext: { [weak self] intValue in
            guard let self = self else { return }
            self.valueChanged.onNext(String(intValue))
        })
        .disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
        mainContainer.layer.masksToBounds = true
        mainContainer.layer.cornerRadius = 10
    }
    
    @IBAction func onTapSettingsAction(_ sender: Any) {
        onTapSetting.onNext(())
    }
    
    func setSelectorType(type: SelectorType) {
        selectorContainer.isHidden = type == .None
        selectorContainer.isUserInteractionEnabled = type != .None
        integerSelector.isHidden = true
        integerSelector.isUserInteractionEnabled = false
        
        switch type {
        case .Integer:
            integerSelector.isHidden = false
            integerSelector.isUserInteractionEnabled = true
        default:
            break
        }
        
        selectorType = type
    }
    
    
    func changeValueOfMainParameter(value: String) {
        switch selectorType {
        case .Integer:
            integerSelector.label.text = String(Int(value) ?? 0)
        default:
            break //None (or type not implemented yet)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch = touches.first!
        let touchLocation = touch.location(in: self)
        let selectorContainerRect = selectorContainer.superview!.convert(selectorContainer.frame, to: self)
        let settingsButtonRect = settingsButton.superview!.convert(settingsButton.frame, to: self)
        
        if ((!selectorContainerRect.contains(touchLocation)) || (selectorType == .None)) && (!settingsButtonRect.contains(touchLocation) || !isSettingsButtonEnabled) {
            onTouch.onNext(())
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        createRxSubscriptions()
    }
}
