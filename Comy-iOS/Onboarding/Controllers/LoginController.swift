//
//  LoginController.swift
//  Comy-iOS
//
//  Created by Quentin on 22/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxGesture
import UIKit

class LoginController: UIViewController {
    
    @IBOutlet weak var darkBackground: UIView!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var usernameTextField: BeautifulTextField!
    @IBOutlet weak var passwordTextField: BeautifulTextField!
    @IBOutlet weak var mainContainer: RoundedView!
    
    weak var delegate: LoginControllerDelegate?
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        darkBackground.alpha = 0.7
        
        usernameTextField.textField.textContentType = .username
        passwordTextField.textField.textContentType = .password
        passwordTextField.textField.isSecureTextEntry = true
        
        logInButton.rx
            .tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.dismiss(animated: true) {
                    self.delegate?.connect(with: self.usernameTextField.textField.text ?? "", password: self.passwordTextField.textField.text ?? "")
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first! as UITouch
        let touchLocation = touch.location(in: self.view)
        
        let mainContainerRect = mainContainer.superview!.convert(mainContainer.frame, to: self.view)
        if !mainContainerRect.contains(touchLocation) {
            self.dismiss(animated: true) {
                self.delegate?.onLoginCancelled()
            }
        }
    }
    
}

protocol LoginControllerDelegate: class {
    func onLoginCancelled()
    func connect(with username: String, password: String)
}
