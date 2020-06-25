//
//  IntegerSettingCell.swift
//  Comy-iOS
//
//  Created by Quentin on 25/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class IntegerSettingCell: UITableViewCell, SettingCell {
    
    @IBOutlet var xibView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var integerSelector: IntegerSelector!
    
    var title: String {
        get {
            return titleLabel.text ?? ""
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    var value: String {
        get {
            return String(integerSelector.value)
        }
        set {
            integerSelector.value = Int(newValue) ?? 0
        }
    }
    
    
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
        Bundle.main.loadNibNamed("IntegerSettingCell", owner: self, options: nil)
        contentView.addSubview(xibView)
        xibView.frame = contentView.bounds
        xibView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        createRxSubscriptions()
        
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
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        createRxSubscriptions()
    }
}


