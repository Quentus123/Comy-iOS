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
    private let disposeBag = DisposeBag()
    
    private static let USER_DEFAULT_LAST_URL = "last server url"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlTextField.text = UserDefaults.standard.string(forKey: Self.USER_DEFAULT_LAST_URL)
        
        connectButton
            .rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self, self.urlTextField.text != nil else { return }
                guard let url = URL(string: self.urlTextField.text!) else { return }
                
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
                    if !((try? serverViewModel.isConnected.value()) ?? false) {
                        print("Unable to connect to server")
                    }
                    self.connectButton.isEnabled = true
                    connectionObservable.dispose()
                }
            })
            .disposed(by: disposeBag)
    }
    
}
