//
//  CommandsViewModel.swift
//  Comy-iOS
//
//  Created by Quentin on 12/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import RxSwift

class CommandsViewModel {
    
    var commands: BehaviorSubject<[Command]> = BehaviorSubject(value: [])
    let commandResult: PublishSubject<CommandResult> = PublishSubject()
    var services: ServerServices
    
    init(request: URLRequest){
        services = ServerServices(request: request)
        services.delegate = self
        services.connect()
    }
    
}

extension CommandsViewModel: ServerServicesDelegate {
    
    func didReceiveNewState(state: [Command]) {
        commands.onNext(state)
    }
    
    func didReceiveCommandResult(result: CommandResult) {
        commandResult.onNext(result)
    }
    
}
