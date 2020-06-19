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
    
    private var onboardingViewModel = OnBoardingViewModel()
    
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
                guard let self = self else { return }
                guard let url = URL(string: self.urlTextField.text!) else { return }
                
                self.connectButton.isEnabled = false
                
                self.urlTextField.resignFirstResponder()
                
                var request = URLRequest(url: url)
                let timeoutInterval = 2.0
                request.timeoutInterval = timeoutInterval
                self.onboardingViewModel.connect(request: request)
            })
            .disposed(by: disposeBag)
        
        onboardingViewModel.isTimedOut
            .filter({$0})
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.connectButton.isEnabled = true
                self.notificationView.switchToErrorState(content: "Unable to connect to server")
                self.showNotificationView()
            })
            .disposed(by: disposeBag)
        
        onboardingViewModel.isAuthentificationNeeded
            .filter({$0})
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let authAlert = UIAlertController(title: "Authentification required", message: nil, preferredStyle: .alert)
                authAlert.addTextField(configurationHandler: nil)
                authAlert.addTextField(configurationHandler: nil)
                authAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                    guard let self = self else { return }
                    let username = authAlert.textFields![0].text ?? ""
                    let password = authAlert.textFields![1].text ?? ""
                    self.onboardingViewModel.authentificate(id: username, password: password)
                }))
                authAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                    self.connectButton.isEnabled = true
                }))
                self.present(authAlert, animated: true)
            })
            .disposed(by: disposeBag)
        
        onboardingViewModel.authentificationError
            .filter({$0})
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.connectButton.isEnabled = true
                self.notificationView.switchToErrorState(content: "Authentification Error")
                self.showNotificationView()
            })
            .disposed(by: disposeBag)
        
        onboardingViewModel.needToGoOnServerController
            .subscribe(onNext: { [weak self] serverViewModel in
                guard let self = self else { return }
                self.connectButton.isEnabled = true
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "ServerCommandsController") as! ServerCommandsController
                controller.modalPresentationStyle = .fullScreen
                controller.serverViewModel = serverViewModel
                self.present(controller, animated: true)
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
