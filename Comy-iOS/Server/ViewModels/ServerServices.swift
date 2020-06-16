//
//  ServerServices.swift
//  Comy-iOS
//
//  Created by Quentin on 12/06/2020.
//  Copyright © 2020 Quentin. All rights reserved.
//

import Foundation
import Starscream

class ServerServices {
    
    private var socket: WebSocket
    weak var delegate: ServerServicesDelegate?
    
    init(request: URLRequest){
        socket = WebSocket(request: request)
        socket.delegate = self
    }
    
    func connect() {
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func refreshState() {
        socket.write(string: String(data: try! JSONEncoder().encode(NeedStateMessage()), encoding: .utf8)!)
    }
    
    func executeCommand(command: Command) {
        socket.write(string: String(data: try! JSONEncoder().encode(ExecuteCommandMessage(commandName: command.name)), encoding: .utf8)!)
    }
    
}

extension ServerServices: WebSocketDelegate {
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        print(event)
        switch event {
        case .text(let stringEvent):
            if let dataEvent = stringEvent.data(using: .utf8){
                if let serverStateResponse = try? JSONDecoder().decode(ServerStateResponse.self, from: dataEvent){
                    delegate?.didReceiveNewState(state: serverStateResponse)
                } else if let commandResponse = try? JSONDecoder().decode(CommandResponse.self, from: dataEvent){
                    delegate?.didReceiveCommandResult(response: commandResponse)
                }
            }
        case .connected(_):
            delegate?.onConnected()
        case .disconnected(let reason, let code):
            delegate?.onDisconnected(reason: reason, code: code)
        case .cancelled:
            delegate?.onDisconnected(reason: "Cancelled", code: 200)
        default:
            return
        }
    }
    
}

protocol ServerServicesDelegate: class {
    func onConnected()
    func onDisconnected(reason: String, code: UInt16)
    func didReceiveNewState(state: ServerStateResponse)
    func didReceiveCommandResult(response: CommandResponse)
}
