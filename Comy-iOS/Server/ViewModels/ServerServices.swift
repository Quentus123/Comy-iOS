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
    private var token: String?
    private var refreshToken: String?
    private var currentExecutionCommands: [Command] = []
    private var waitingRefreshTokenCommands: [Command] = []
    weak var delegate: ServerServicesDelegate?
    
    init(request: URLRequest){
        socket = WebSocket(request: request)
        socket.delegate = self
    }
    
    func connect() {
        socket.connect()
    }
    
    func authentificate(id: String, password: String) {
        socket.write(string: String(data: try! JSONEncoder().encode(AuthentificationUserMessage(id: id, password: password)), encoding: .utf8)!)
    }
    
    private func handleAuthResponse(response: AuthentificationResponse) {
        if let token = response.token {
            self.token = token
            if let refreshToken = response.refreshToken { //auth came from username and password
                self.refreshToken = refreshToken
                delegate?.onAuthentification(success: true)
            } else if response.message == "refreshed token" { //we need to reexecute commands
                for command in waitingRefreshTokenCommands {
                    executeCommand(command: command)
                }
            }
        } else {
            delegate?.onAuthentification(success: false)
        }
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func refreshState() {
        socket.write(string: String(data: try! JSONEncoder().encode(NeedStateMessage()), encoding: .utf8)!)
    }
    
    func refreshAuthToken() {
        guard let refreshToken = refreshToken else { return }
        socket.write(string: String(data: try! JSONEncoder().encode(RefreshTokenMessage(refreshToken: refreshToken)), encoding: .utf8)!)
    }
    
    func executeCommand(command: Command) {
        currentExecutionCommands.append(command)
        socket.write(string: String(data: try! JSONEncoder().encode(ExecuteCommandMessage(commandName: command.name, token: token)), encoding: .utf8)!)
    }
    
}

extension ServerServices: WebSocketDelegate {
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        print(event)
        switch event {
        case .text(let stringEvent):
            if let dataEvent = stringEvent.data(using: .utf8){
                if let serverInfoResponse = try? JSONDecoder().decode(ServerInfoResponse.self, from: dataEvent) {
                    delegate?.didReceiveServerInfo(infos: serverInfoResponse)
                } else if let authResponse = try? JSONDecoder().decode(AuthentificationResponse.self, from: dataEvent) {
                    handleAuthResponse(response: authResponse)
                }
                else if let serverStateResponse = try? JSONDecoder().decode(ServerStateResponse.self, from: dataEvent){
                    delegate?.didReceiveNewState(state: serverStateResponse)
                } else if let commandResponse = try? JSONDecoder().decode(CommandResponse.self, from: dataEvent){
                    if let auth = commandResponse.auth, auth.tokenExpiredError, !waitingRefreshTokenCommands.map(\.name).contains(commandResponse.commandName) { //need to refresh token and restart command
                        guard let commandToReexecuteAfterRefresh = currentExecutionCommands.first(where: {$0.name == commandResponse.commandName}) else { return }
                        waitingRefreshTokenCommands.append(commandToReexecuteAfterRefresh)
                        self.refreshAuthToken()
                    } else { //Command execution completed (successfully or not)
                        currentExecutionCommands.removeAll(where: {$0.name == commandResponse.commandName})
                        waitingRefreshTokenCommands.removeAll(where: {$0.name == commandResponse.commandName})
                        delegate?.didReceiveCommandResult(response: commandResponse)
                    }
                    
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
    func onAuthentification(success: Bool)
    func onDisconnected(reason: String, code: UInt16)
    func didReceiveServerInfo(infos: ServerInfoResponse)
    func didReceiveNewState(state: ServerStateResponse)
    func didReceiveCommandResult(response: CommandResponse)
}
