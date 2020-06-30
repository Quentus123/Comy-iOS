//
//  OnboardingViewModel.swift
//  Comy-iOS
//
//  Created by Quentin on 19/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import RxSwift

class OnBoardingViewModel {
    
    private var services: ServerServices?
    var isTimedOut: PublishSubject<Bool> = PublishSubject()
    var isAuthentificationNeeded: PublishSubject<Bool> = PublishSubject()
    var authentificationError: PublishSubject<Bool> = PublishSubject()
    var needToGoOnServerController: PublishSubject<ServerViewModel> = PublishSubject()
    private var timedOutTimer: Timer?
    
    func connect(request: URLRequest) {
        timedOutTimer?.invalidate()
        
        services = ServerServices(request: request)
        services?.delegate = self
        services?.connect()
        
        timedOutTimer = Timer.scheduledTimer(withTimeInterval: request.timeoutInterval + 0.2, repeats: false, block: { [weak self] _ in
            guard let self = self else { return }
            self.isTimedOut.onNext(true)
        })
    }
    
    func authentificate(id: String, password: String) {
        services?.authentificate(id: id, password: password)
    }
    
    func connectWithCredentials(request: URLRequest, accessToken: String, refreshToken: String) {
        timedOutTimer?.invalidate()
        
        services = ServerServices(request: request)
        services?.token = accessToken
        services?.refreshToken = refreshToken
        services?.delegate = self
        services?.connect()
        
        timedOutTimer = Timer.scheduledTimer(withTimeInterval: request.timeoutInterval + 0.2, repeats: false, block: { [weak self] _ in
            guard let self = self else { return }
            self.isTimedOut.onNext(true)
        })
    }
    
    
}

extension OnBoardingViewModel: ServerServicesDelegate {
    
    func onConnected() {
        timedOutTimer?.invalidate()
    }
    
    func onAuthentification(success: Bool) {
        if let services = services, success {
            let serverViewModel = ServerViewModel(services: services)
            services.delegate = serverViewModel
            needToGoOnServerController.onNext(serverViewModel)
        } else if !success {
            authentificationError.onNext(true)
        }
    }
    
    func onDisconnected(reason: String, code: UInt16) {
        
    }
    
    func didReceiveServerInfo(infos: ServerInfoResponse) {
        guard let services = services else { return }
        if infos.isSecured {
            if (services.token != nil && services.refreshToken != nil) {
                services.refreshState()
            } else {
                isAuthentificationNeeded.onNext(true)
            }
        } else {
            onAuthentification(success: true)
        }
    }
    
    func didReceiveNewState(state: ServerStateResponse) {
        onAuthentification(success: true)
    }
    
    func didReceiveCommandResult(response: CommandResponse) {
        
    }
    
}
