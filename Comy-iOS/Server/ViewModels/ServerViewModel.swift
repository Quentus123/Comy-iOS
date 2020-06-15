//
//  CommandsViewModel.swift
//  Comy-iOS
//
//  Created by Quentin on 12/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import RxSwift

class ServerViewModel {
    
    let serverName: BehaviorSubject<String> = BehaviorSubject(value: "")
    let commands: BehaviorSubject<[Command]> = BehaviorSubject(value: [])
    let imagesData: BehaviorSubject<[String : Data]> = BehaviorSubject(value: [:])
    let isConnected: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    let commandResult: PublishSubject<CommandResult> = PublishSubject()
    var services: ServerServices
    
    init(request: URLRequest){
        services = ServerServices(request: request)
        services.delegate = self
        services.connect()
    }
    
}

extension ServerViewModel: ServerServicesDelegate {
    
    func onConnected() {
        isConnected.onNext(true)
    }
    
    func onDisconnected(reason: String, code: UInt16) {
        isConnected.onNext(false)
    }
    
    func didReceiveNewState(state: ServerStateResponse) {
        serverName.onNext(state.name)
        commands.onNext(state.commands)
        for command in state.commands {
            command.downloadImageData { (data) in
                if let data = data {
                    var dict = (try? self.imagesData.value()) ?? [:]
                    dict[command.name] = data
                    self.imagesData.onNext(dict)
                }
            }
        }
    }
    
    func didReceiveCommandResult(result: CommandResult) {
        commandResult.onNext(result)
    }
    
}
