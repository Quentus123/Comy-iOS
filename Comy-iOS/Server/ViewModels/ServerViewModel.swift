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
    
    let serverInfo: BehaviorSubject<ServerInfoResponse> = BehaviorSubject(value: ServerInfoResponse(serverName: "", isSecured: false))
    let commands: BehaviorSubject<[Command]> = BehaviorSubject(value: [])
    let imagesData: BehaviorSubject<[String : Data?]> = BehaviorSubject(value: [:])
    let commandsLoading: BehaviorSubject<[String]> = BehaviorSubject(value: [])
    let isConnected: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    var connectionSuccess: Bool = false
    var isConnectionCancelled: Bool = false
    let commandResponse: PublishSubject<CommandResponse> = PublishSubject()
    var services: ServerServices
    
    init(request: URLRequest){
        services = ServerServices(request: request)
        services.delegate = self
        services.connect()
    }
    
    func executeCommand(command: Command){
        let commandsLoadingValue = (try? commandsLoading.value()) ?? []
        guard !commandsLoadingValue.contains(command.name) else { return }
        commandsLoading.onNext(commandsLoadingValue + [command.name])
        services.executeCommand(command: command)
    }
    
    func disconnect() {
        isConnectionCancelled = true
        services.disconnect()
    }
    
}

extension ServerViewModel: ServerServicesDelegate {
    
    func onConnected() {
        connectionSuccess = true
        isConnected.onNext(true)
        services.refreshState()
    }
    
    func onDisconnected(reason: String, code: UInt16) {
        isConnected.onNext(false)
    }
    
    func didReceiveServerInfo(infos: ServerInfoResponse) {
        serverInfo.onNext(infos)
    }
    
    func didReceiveNewState(state: ServerStateResponse) {
        commands.onNext(state.commands)
        for command in state.commands {
            command.downloadImageData { (data) in
                var dict = (try? self.imagesData.value()) ?? [:]
                dict[command.name] = data
                self.imagesData.onNext(dict)
            }
        }
    }
    
    func didReceiveCommandResult(response: CommandResponse) {
        var commandsLoadingValue = (try? commandsLoading.value()) ?? []
        commandsLoadingValue.removeAll(where: {$0 == response.commandName})
        commandsLoading.onNext(commandsLoadingValue)
        commandResponse.onNext(response)
    }
    
}
