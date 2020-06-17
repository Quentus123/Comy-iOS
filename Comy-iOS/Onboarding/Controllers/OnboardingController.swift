//
//  OnboardingController.swift
//  Comy-iOS
//
//  Created by Quentin on 16/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxGesture
import UIKit

class OnboardingController: UIViewController {
    
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var notificationView: NotificationView!
    private let disposeBag = DisposeBag()
    
    private var baseNotificationViewBottomConstraintConstant: CGFloat!
    private var timerHideNotification: Timer?
    
    private static let USER_DEFAULT_LAST_URL = "last server url"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseNotificationViewBottomConstraintConstant = view.constraints.filter({$0.firstAnchor == notificationView.bottomAnchor}).first!.constant
        notificationView.isHidden = true //will be set to false in viewDidAppear after first constraints change, it allows to modify bases constraints in storyboard instead of in this file
        
        urlTextField.text = UserDefaults.standard.string(forKey: Self.USER_DEFAULT_LAST_URL)
        urlTextField.delegate = self
        
        notificationView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.hideNotificationView()
            })
            .disposed(by: disposeBag)
        
        connectButton
            .rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self, self.urlTextField.text != nil else { return }
                guard let url = URL(string: self.urlTextField.text!) else { return }
                
                self.urlTextField.resignFirstResponder()
                
                var request = URLRequest(url: url)
                let timeoutInterval = 2.0
                request.timeoutInterval = timeoutInterval
                self.connectButton.isEnabled = false
                let serverViewModel = ServerViewModel(request: request)
                let connectionObservable = serverViewModel.isConnected
                    .filter({$0})
                    .subscribe(onNext: { [weak self] _ in
                        guard let self = self else { return }
                        UserDefaults.standard.set(self.urlTextField.text, forKey: Self.USER_DEFAULT_LAST_URL)
                        let controller = self.storyboard!.instantiateViewController(withIdentifier: "ServerCommandsController") as! ServerCommandsController
                        controller.modalPresentationStyle = .fullScreen
                        controller.serverViewModel = serverViewModel
                        self.present(controller, animated: true)
                    })
                DispatchQueue.main.asyncAfter(deadline: .now() + timeoutInterval + 0.2) { //no need to retain subscription after timeout delay
                    if !serverViewModel.connectionSuccess {
                        self.notificationView.switchToErrorState(content: "Unable to connect to server")
                        self.showNotificationView()
                    }
                    self.connectButton.isEnabled = true
                    connectionObservable.dispose()
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideNotificationView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.notificationView.isHidden = false
        }
    }
    
    private func hideNotificationView() {
        let oldBottomConstraint = self.view.constraints.filter({$0.firstAnchor == notificationView.bottomAnchor}).first!
        guard oldBottomConstraint.constant < 0 else { return }
        let viewHeight = self.notificationView.constraints.filter({$0.firstAttribute == .height && $0.relation == .equal && $0.secondAnchor == nil}).first!.constant
        let newBottomConstraint = NSLayoutConstraint(item: notificationView as Any,
                                                     attribute: .bottom,
                                                     relatedBy: .equal,
                                                     toItem: view,
                                                     attribute: .bottom,
                                                     multiplier: 1,
                                                     constant: -oldBottomConstraint.constant + viewHeight)
        UIView.animate(withDuration: 0.5) {
            self.view.removeConstraint(oldBottomConstraint)
            self.view.addConstraint(newBottomConstraint)
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    private func showNotificationView() {
        timerHideNotification?.invalidate()
        
        let oldBottomConstraint = self.view.constraints.filter({$0.firstAnchor == notificationView.bottomAnchor}).first!
        guard oldBottomConstraint.constant > 0 else { return }
        let newBottomConstraint = NSLayoutConstraint(item: notificationView as Any,
                                                     attribute: .bottom,
                                                     relatedBy: .equal,
                                                     toItem: view,
                                                     attribute: .bottom,
                                                     multiplier: 1,
                                                     constant: baseNotificationViewBottomConstraintConstant)
        UIView.animate(withDuration: 0.5) {
            self.view.removeConstraint(oldBottomConstraint)
            self.view.addConstraint(newBottomConstraint)
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
        
        timerHideNotification = Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { [weak self] timer in
            guard let self = self else { return }
            self.hideNotificationView()
        }
    }
    
}

extension OnboardingController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
