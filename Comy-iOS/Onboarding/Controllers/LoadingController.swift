//
//  LoadingController.swift
//  Comy-iOS
//
//  Created by Quentin on 30/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

class LoadingController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private let onboardingViewModel = OnBoardingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let lastUrlString = UserDefaults.standard.string(forKey: OnboardingController.USER_DEFAULT_LAST_URL) else {
            self.presentOnboardingController()
            return
        }
        guard let lastUrl = URL(string: lastUrlString) else {
            self.presentOnboardingController()
            return
        }
        guard let credentials = ServerCredentials.from(url: lastUrlString) else {
            self.presentOnboardingController()
            return
        }
        
        onboardingViewModel.needToGoOnServerController
            .subscribe(onNext: { [weak self] serverViewModel in
                guard let self = self else { return }
                let controller = self.storyboard!.instantiateViewController(identifier: "ServerCommandsController") as! ServerCommandsController
                controller.serverViewModel = serverViewModel
                
                self.navigationController!.setViewControllers([self.storyboard?.instantiateViewController(identifier: "OnboardingController") as! OnboardingController, controller], animated: true)
            })
            .disposed(by: disposeBag)
        
        Observable.merge(onboardingViewModel.authentificationError, onboardingViewModel.isAuthentificationNeeded, onboardingViewModel.isTimedOut)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.presentOnboardingController()
            })
            .disposed(by: disposeBag)
        
        onboardingViewModel.connectWithCredentials(request: URLRequest(url: lastUrl), accessToken: credentials.accessToken!, refreshToken: credentials.refreshToken!)
    }
    
    private func presentOnboardingController() {
        self.navigationController!.setViewControllers([self.storyboard?.instantiateViewController(identifier: "OnboardingController") as! OnboardingController], animated: true)
    }
    
}
